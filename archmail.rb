#!/usr/bin/env ruby -W0
require './environment'

class Archmail
  def clean_up
    @env = Env.new
    Folder.destroy_all
    FileUtils.rm_rf @env.arch_path
    Db.migrate :down
    Db.migrate :up
  end

  def backup
    clean_up
    @folder = Folder.new
    @folder.create_root_structure
    @message = Message.new
    Folder.all.each do |folder|
      p "Folder: #{folder.id} - #{folder.imap_name}"
      @message.fetch_all_headers(folder)
      @message.create_messages_tree_in_folder(folder)
    end
    messages = Message.all
    p "Fetch and save #{messages.count} message(s)"
    messages.each{|m| @message.backup(m); ".".print_and_flush }
    puts " done"
  end
end
