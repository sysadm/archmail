class Message < ActiveRecord::Base
  attr_reader :env
  acts_as_tree
  belongs_to :folder
  has_many :attachments
  after_initialize :define_context

  def define_context
    @env ||= Env.new
  end

  def fetch_all_headers(folder)
    @env.imap_connect unless @env.imap
    @env.imap.select(folder.imap_name)
    queue = @env.imap.search(['ALL'])
    p "Fetch headers for #{queue.count} message(s)"
    queue.each{|seqno| fetch_message_headers(folder, seqno); ".".print_and_flush }
    puts " done"
  end

  def create_messages_tree_in_folder(folder)
    @env.imap_connect unless @env.imap
    @env.imap.select(folder.imap_name)
    p "Create message tree in folder #{folder.name}"
    threaded_list=@env.imap.thread("REFERENCES", 'ALL', 'UTF-8')
    threaded_list.each do |thread_member|
      if thread_member.children.count > 0
        parent = find_stored_msg_by_seqno thread_member.seqno if thread_member.seqno
        create_message_branch(thread_member, parent)
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
    subject = envelope.subject.decode unless envelope.subject.nil?
    from = envelope.from[0].name.decode unless envelope.from[0].name.nil?
    from = mail.from[0] unless from
    Message.create(flags: data.attr["FLAGS"].join(","),
                   size: data.attr["RFC822.SIZE"],
                   created_at: data.attr["INTERNALDATE"].to_datetime,
                   subject: subject,
                   from: from,
                   uid: data.attr["UID"],
                   message_id: mail.message_id,
                   in_reply_to: mail.in_reply_to,
                   folder: folder,
                   rfc_header: data.attr["RFC822.HEADER"]
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
    if @mail.html_part
      begin
        body = @mail.html_part.decoded.to_utf8(@mail.text_part.charset)
        File.open(file, "w+b", 0644) {|f| f.write "<div id='rfc'>#{header}</div><br />#{body}"}
      rescue => e
        puts "Unable to save data for #{file} because #{e.message}"
      end
    elsif @mail.text_part and @mail.text_part.body.decoded.size > 0
      begin
        body = @mail.text_part.decoded.to_utf8(@mail.text_part.charset).body_to_html
        File.open(file, "w+b", 0644) {|f| f.write "<div id='rfc'>#{header}</div><br />#{body}"}
      rescue => e
        puts "Unable to save data for #{file} because #{e.message}"
      end
    else
      begin
        if @mail.body.multipart?
          @content = []
          extract_inline_messages_from_multipart_mail(@mail)
          body = @content.join('==<br />')
        else
          body = @mail.body.decoded.to_utf8(@mail.charset).body_to_html
        end
        File.open(file, "w+b", 0644) {|f| f.write "<div id='rfc'>#{header}</div><br />#{body}"}
      rescue => e
        puts "Unable to save data for #{file} because #{e.message}"
      end
    end
    unless @mail.attachments.empty?
      message.update_attribute(:has_attachment, true)
      path = FileUtils.mkdir_p(([@env.arch_path] + message.folder.ancestry_path + [message.id]).join('/'))[0] + "/"
      @mail.attachments.each_with_index do | attachment, index |
        content_type = attachment.content_type.split(";")[0]
        content_type == "message/rfc822" ? filename = "attach_#{index}.eml" : filename = attachment.filename
        begin
          file = File.open(path + filename, "w+b", 0644) {|f| f.write attachment.body.decoded}
          Attachment.create(message: message, filename: filename, content_type: content_type, size: file) if file
        rescue => e
          puts "Unable to save data for #{filename} because #{e.message}"
        end
      end
    end
    message.update_attribute(:export_complete, true)
  end

  def extract_inline_messages_from_multipart_mail(mail)
    mail.parts.each do |part|
      unless part.body.decoded.empty?
        if part.content_type.start_with?('message/rfc822')
          inline_mail = Mail.read_from_string part.body.to_s
          extract_inline_messages_from_multipart_mail(inline_mail)
        else
          @content << part.body.decoded.to_utf8(part.charset).body_to_html
        end
      end
    end
  end

end
