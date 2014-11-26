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
    if @options.continue
    else
      clean_up
      @folder = Folder.new
      logger "Create folder structure..."
      @folder.create_root_structure
      logger "done"
      @message = Message.new
      if @options.folders == :all
        Folder.all.each do |folder|
          logger "Folder: #{folder.id} - #{folder.imap_name}"
          @message.fetch_all_headers(folder)
          @message.create_messages_tree_in_folder(folder)
        end
      else
        folder = Folder.find_by(imap_name: @options.folder)
        if folder
          logger "Folder: #{folder.id} - #{folder.imap_name}"
          @message.fetch_all_headers(folder)
          @message.create_messages_tree_in_folder(folder)
        else
          logger "Folder: #{folder.split('.').join('/')} doesn't exist on imap server"
          exit 1
        end
      end
    end
    messages = Message.all
    logger "Fetch and save #{messages.count} message(s)"
    messages.each{|m| @message.backup(m); ".".print_and_flush }
    logger " done"
    create_html_indexes
  end

  def create_html_indexes
    logger "Run html generators..."
    html_generator = HtmlGenerator.new
    html_generator.generate_all
    logger "Backup complete."
  end
end

@a = Archmail.new
pp @options
# @a.backup
