class Message < ActiveRecord::Base
  attr_reader :env, :view, :conversion_errors
  acts_as_tree
  belongs_to :folder
  has_many :attachments, dependent: :destroy
  has_many :tags, dependent: :destroy
  after_initialize :define_context

  def define_context
    @env ||= Env.new
    @view ||= Class.new(ActionView::Base).new("lib/views/templates")
    @conversion_errors = {}
  end

  def fetch_all_headers(folder)
    @env.imap_connect unless @env.imap
    @env.imap.select(folder.imap_name)
    queue = @env.imap.search(['ALL'])
    arch_logger "Fetch headers for #{queue.count} message(s)"
    if @env.gmail
      queue.each{|seqno| fetch_gmail_message_headers(folder, seqno); ".".print_and_flush(CMD_LINE_OPTIONS.verbose) }
    else
      queue.each{|seqno| fetch_message_headers(folder, seqno); ".".print_and_flush(CMD_LINE_OPTIONS.verbose) }
    end
    arch_logger " done"
  end

  def create_messages_tree_in_folder(folder)
    @env.imap_connect unless @env.imap
    @env.imap.select(folder.imap_name)
    arch_logger "Create message tree in folder #{folder.name}"
    begin
      threaded_list=@env.imap.thread("REFERENCES", 'ALL', 'UTF-8')
      threaded_list.each do |thread_member|
        if thread_member.children.count > 0
          parent = find_stored_msg_by_seqno thread_member.seqno if thread_member.seqno
          create_message_branch(thread_member, parent)
        end
      end
    rescue => e
      if @env.gmail
        folder.messages.each do |message|
          parent = folder.messages.find_by(gm_msgid: message.gm_thrid)
          parent.children << message if parent
        end
      else
        arch_logger "IMAP server doesn't support normal threading: #{e.message}"
        arch_logger "Message tree will be created by 'in_reply_to' field only."
      end
    end
    #thread correction
    folder.messages.each do |message|
      parent = folder.messages.find_by(in_reply_to: message.in_reply_to) if message.in_reply_to
      parent.children << message if parent
    end
  end

  def find_stored_msg_by_seqno(seqno)
    data = @env.imap.fetch(seqno, ["UID", "RFC822.HEADER"])[0]
    mail = Mail.read_from_string data.attr["RFC822.HEADER"]
    uid = data.attr["UID"]
    message_id = mail.message_id
    Message.find_by(uid: uid, message_id: message_id)
  end

  def create_message_branch(parent_branch, parent=nil)
    parent_branch.children.each do |thread_member|
      if parent
        if thread_member.seqno
          message = find_stored_msg_by_seqno thread_member.seqno
          parent.children << message
        end
        create_message_branch(thread_member, message) unless thread_member.children.empty?
      end
    end
  end

  def fetch_message_headers(folder, seqno)
    data = @env.imap.fetch(seqno, ["UID", "ENVELOPE", "RFC822.HEADER", "RFC822.SIZE", "INTERNALDATE", "FLAGS"])[0]
    envelope = data.attr["ENVELOPE"]
    mail = Mail.read_from_string data.attr["RFC822.HEADER"]
    mail.subject ||= envelope.subject.decode unless envelope.subject.nil?
    mail.subject = mail.subject.encode("UTF-8", :invalid => :replace, :undef => :replace, :replace => "") unless mail.subject.nil?
    from = envelope.from[0].name.decode unless envelope.from[0].name.nil?
    from = mail.from[0] unless from
    from = from.encode("UTF-8", :invalid => :replace, :undef => :replace, :replace => "") unless from.nil?
    data.attr["FLAGS"] ? flags = data.attr["FLAGS"].join(",") : flags = ''
    mail.in_reply_to.kind_of?(Array) ? in_reply_to = mail.in_reply_to.last : in_reply_to = mail.in_reply_to
    Message.create(flags: flags,
                   size: data.attr["RFC822.SIZE"],
                   created_at: data.attr["INTERNALDATE"].to_datetime,
                   subject: mail.subject,
                   from: from,
                   uid: data.attr["UID"],
                   message_id: mail.message_id,
                   in_reply_to: in_reply_to,
                   folder: folder,
                   rfc_header: data.attr["RFC822.HEADER"]
    )
  end

  def fetch_gmail_message_headers(folder, seqno)
    data = @env.imap.fetch(seqno, ["UID", "ENVELOPE", "RFC822.HEADER", "RFC822.SIZE", "INTERNALDATE", "FLAGS", "X-GM-LABELS", "X-GM-MSGID", "X-GM-THRID"])[0]
    envelope = data.attr["ENVELOPE"]
    mail = Mail.read_from_string data.attr["RFC822.HEADER"]
    subject = envelope.subject.decode unless envelope.subject.nil?
    from = envelope.from[0].name.decode unless envelope.from[0].name.nil?
    from = mail.from[0] unless from
    mail.in_reply_to.kind_of?(Array) ? in_reply_to = mail.in_reply_to.last : in_reply_to = mail.in_reply_to
    Message.create(flags: data.attr["FLAGS"].join(","),
                   size: data.attr["RFC822.SIZE"],
                   created_at: data.attr["INTERNALDATE"].to_datetime,
                   subject: subject.encode("UTF-8", :invalid => :replace, :undef => :replace, :replace => ""),
                   from: from.encode("UTF-8", :invalid => :replace, :undef => :replace, :replace => ""),
                   uid: data.attr["UID"],
                   message_id: mail.message_id,
                   in_reply_to: in_reply_to,
                   folder: folder,
                   rfc_header: data.attr["RFC822.HEADER"],
                   gm_labels: data.attr["X-GM-LABELS"].join(","),
                   gm_msgid: data.attr["X-GM-MSGID"],
                   gm_thrid: data.attr["X-GM-THRID"]
    )
  end

  def backup(message)
    @env.imap_connect unless @env.imap
    @env.imap.select(message.folder.imap_name)
    seqno = @env.imap.search(["HEADER", "MESSAGE-ID", message.message_id])[0]
    data = @env.imap.fetch(seqno, ["RFC822.HEADER", "RFC822"])[0]
    @mail = Mail.read_from_string data.attr["RFC822"]
    file = ([@env.arch_path] + message.folder.ancestry_path).join('/') + "/#{message.id}.html"
    header = message.rfc_header.rfc_to_html

    unless @mail.attachments.empty?
      message.update_attribute(:has_attachment, true)
      path = ([@env.arch_path] + message.folder.ancestry_path + [message.id]).join('/') + "/"
      %x{mkdir -p \"#{path}\" }
      @mail.attachments.each_with_index do | attachment, index |
        content_type = attachment.content_type.split(";")[0]
        original_filename = attachment.filename.encode("UTF-8", :invalid => :replace, :undef => :replace, :replace => "")
        content_type == "message/rfc822" ? extension = "eml" : extension = original_filename.split('.').last
        filename = "#{message.id}_#{index}.#{extension}"
        attach = save_file_safely(path + filename, attachment.body.decoded)
        Attachment.create(message: message, filename: filename, original_filename: original_filename,
                          content_type: content_type, size: attach) if attach
      end
    end

    if @mail.html_part
      body = decode_message_safely(message.id, @mail.html_part, @mail.html_part.charset)
      html = @view.render(template: 'message', locals: { rfc_header: decode_header_safely(header), body: body, message: message } )
      save_file_safely(file, html)
    elsif @mail.text_part and @mail.text_part.body.decoded.size > 0
      body = decode_message_safely(message.id, @mail.text_part, @mail.text_part.charset).body_to_html
      html = @view.render(template: 'message', locals: { rfc_header: decode_header_safely(header), body: body, message: message } )
      save_file_safely(file, html)
    elsif @mail.text_part and @mail.text_part.body.decoded.size == 0
      message.has_attachment? ? attachments = " and attachment(s)" : attachments = ""
      body = "<h4>This email include only empty text part#{attachments}.</h4>"
      html = @view.render(template: 'message', locals: { rfc_header: decode_header_safely(header), body: body, message: message } )
      save_file_safely(file, html)
    else
      begin
        if @mail.body.multipart?
          @content = []
          extract_inline_messages_from_multipart_mail(message.id, @mail)
          @body = @content.join('==<br />')
        else
          if @mail.body.encoding == "base64"
            content_type = "#{@mail.main_type}/#{@mail.sub_type}"
            original_filename = @mail.content_type_parameters[:name].to_s.encode("UTF-8", :invalid => :replace, :undef => :replace, :replace => "")
            content_type == "message/rfc822" ? extension = "eml" : extension = original_filename.split('.').last
            path = ([@env.arch_path] + message.folder.ancestry_path + [message.id]).join('/') + "/"
            %x{mkdir -p \"#{path}\" }
            filename = "#{message.id}_0.#{extension}"
            body = decode_message_safely(message.id, @mail.body, nil)
            attach = save_file_safely(path + filename, body)
            if attach
              Attachment.create(message: message, filename: filename, original_filename: original_filename,
                                content_type: content_type, size: attach)
              message.update_attribute(:has_attachment, true)
            end
            @body = "<h4>This email include only mime64 encoded file, it was saved like an attachment.</h4>"
          else
            @body = decode_message_safely(message.id, @mail.body, @mail.charset).body_to_html
          end
          html = @view.render(template: 'message', locals: { rfc_header: decode_header_safely(header), body: @body, message: message } )
          save_file_safely(file, html)
        end
      rescue => e
        arch_logger "Unable to save data for #{file} because #{e.message}"
      end
    end
    message.update_attribute(:export_complete, true)
  end

  def decode_header_safely(header)
    begin
      result = header.decode.force_encoding('UTF-8')
    rescue => e
      result = header.encode("UTF-8", :invalid => :replace, :undef => :replace, :replace => "")
    end
    result
  end

  def decode_message_safely(id, mail_part, charset)
    begin
      @str = mail_part.decoded
    rescue => e
      @conversion_errors[id] = e.message
      @str = mail_part.body
    end
    if charset.nil?
      begin
        result = @str.to_s.force_encoding('UTF-8')
      rescue => e
        @conversion_errors[id] = e.message
        return @str.to_s.encode("UTF-8", :invalid => :replace, :undef => :replace, :replace => "")
      end
    else
      begin
        if @str.kind_of? String
          result = @str.to_utf8(charset.charset_alias).encode("UTF-8", :invalid => :replace, :undef => :replace, :replace => "")
        else
          result = @str.decoded.force_encoding(charset.charset_alias).encode("UTF-8", :invalid => :replace, :undef => :replace, :replace => "")
        end
      rescue => e
        @conversion_errors[id] = e.message
        return @str.to_s.encode("UTF-8", :invalid => :replace, :undef => :replace, :replace => "")
      end
    end
    result
  end

  def save_file_safely(file, content)
    begin
      result = File.open(file, "w+b", 0644) {|f| f.write content}
    rescue => e
      arch_logger "Unable to save data for #{file} because #{e.message}"
      return false
    end
    result
  end

  def extract_inline_messages_from_multipart_mail(message_id, mail)
    mail.parts.each do |part|
      unless part.body.decoded.empty?
        if part.content_type.start_with?('message/rfc822')
          inline_mail = Mail.read_from_string part.body.to_s
          extract_inline_messages_from_multipart_mail(message_id, inline_mail)
        else
          @content << decode_message_safely(message_id, part, part.charset).body_to_html
        end
      end
    end
  end

  def path
    folder = self.folder
    ([@env.arch_path] + folder.ancestry_path).join('/') + "/#{self.id}.html"
  end

  def self.create_tags
    Message.all.each do |message|
      flags = message.flags.split(',')
      message.gm_labels ? labels = message.gm_labels.split(',') : labels = []
      flags.each{|flag| Tag.find_or_create_by(message_id: message.id, kind: "flag", name: flag ) }
      labels.each{|label| Tag.find_or_create_by(message_id: message.id, kind: "label", name: label ) }
    end
  end
end
