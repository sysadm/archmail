#!/usr/bin/env ruby -W0
require './environment'

@login = ENV['MAIL_LOGIN']
@pass = ENV['MAIL_PASS']

@arch_path = "#{@login}_#{Date.today.to_s}"

def clean_up
  Folder.destroy_all
  FileUtils.rm_rf @arch_path
end

def imap_connect
  @imap = Net::IMAP.new('pop.multitel.be', 993, :ssl => { :verify_mode => OpenSSL::SSL::VERIFY_NONE })
  @imap.authenticate('login', @login, @pass)
end

imap_connect

def create_folder_root_structure
  Dir.mkdir @arch_path
  mailboxes = @imap.list("", "%").to_a
  mailboxes.each{|mailbox|
    folder = Folder.find_or_create_by(name: mailbox.name, imap_name: mailbox.name)
    FileUtils.mkdir_p "#{@arch_path}/#{folder.name}"
    if mailbox.attr.include? :Haschildren
      create_subfolder_tree folder
    end
  }
end

def create_subfolder_tree(folder)
  mailboxes = @imap.list("#{folder.name}.", "%").to_a
  mailboxes.each{|mailbox|
    name = mailbox.name.gsub("#{folder.imap_name}.", "")
    subfolder = folder.children.create(name: name, imap_name: mailbox.name)
    FileUtils.mkdir_p ([@arch_path] + subfolder.ancestry_path).join('/')
    create_subfolder_tree subfolder if mailbox.attr.include? :Haschildren
  }
end

def fetch_all_headers(folder)
  @imap.search(['ALL']).each{|seqno| fetch_message_headers(folder, seqno) }
end

def create_messages_tree_in_folder(folder)
  p "Create message tree in folder #{folder}"
  threaded_list=@imap.thread("REFERENCES", 'ALL', 'UTF-8')
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
  data = @imap.fetch(seqno, ["UID", "RFC822.HEADER"])[0]
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
  data = @imap.fetch(seqno, ["UID", "ENVELOPE", "RFC822.HEADER", "RFC822.SIZE", "INTERNALDATE", "FLAGS"])[0]
  envelope = data.attr["ENVELOPE"]
  mail = Mail.read_from_string data.attr["RFC822.HEADER"]
  subject = envelope.subject.decode unless envelope.subject.nil?
  from = envelope.from[0].name.decode unless envelope.from[0].name.nil?
  p "Create #{data.attr["UID"]} - from: #{from} subj: #{subject}"
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

def archmail
  clean_up
  create_folder_root_structure
  Folder.all.each do |folder|
    @imap.select(folder.imap_name)
    p "Folder: #{folder.id} - #{folder.imap_name}"
    fetch_all_headers(folder)
    create_messages_tree_in_folder(folder)


  end
end

#imap.disconnect
