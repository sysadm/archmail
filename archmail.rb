#!/usr/bin/env ruby -W0
require './environment'

class Archmail
  attr_reader :options, :env
  attr_accessor :message, :state

  def define_context
    @options = CMD_LINE_OPTIONS
    @state = State.open
    @env = Env.new
  end

  def run
    define_context
    define_backup_path
    if @options.continue
      create_folder_structure unless @state.folder_structure_complete
      @message = Message.new
      create_message_structure_continue unless @state.message_structure_complete
    else
      clean_all
      create_folder_structure
      @message = Message.new
      create_message_structure
    end
    save_messages
    create_html_indexes
  end

  def create_message_structure
    if @options.folders == :all
      Folder.all.each do |folder|
        arch_logger "Folder: #{folder.id} - #{folder.imap_name}"
        @message.fetch_all_headers(folder)
        @message.create_messages_tree_in_folder(folder)
      end
      @state.message_structure_complete = true
      @state.save
    else
      folder = Folder.find_by(imap_name: @options.folder)
      if folder
        arch_logger "Folder: #{folder.id} - #{folder.imap_name}"
        @message.fetch_all_headers(folder)
        @message.create_messages_tree_in_folder(folder)
        folder.clean_up_except_folder
        @state.message_structure_complete = true
        @state.save
      else
        arch_logger "Folder: #{@options.folder.split('.').join('/')} doesn't exist on imap server"
        exit 1
      end
    end
  end

  def create_message_structure_continue

  end

  def create_folder_structure
    @folder = Folder.new
    arch_logger "Create folder structure..."
    @folder.create_root_structure
    @state.folder_structure_complete = true
    @state.save
    arch_logger "done"
  end

  def save_messages
    messages = Message.where(export_complete: false)
    arch_logger "Fetch and save #{messages.count} message(s)"
    messages.each{|m| @message.backup(m); ".".print_and_flush }
    arch_logger " done"
  end

  def clean_all
    File.open("./lib/db/mailbox.db", "w+b", 0644) {|f| f.write ''}
    FileUtils.rm_rf @env.arch_path
    Db.migrate :up
  end

  def create_html_indexes
    arch_logger "Run html generators..."
    html_generator = HtmlGenerator.new
    html_generator.generate_all
    arch_logger "Backup complete."
  end

  def self.debug
    pp @options
    pp @state
    exit
  end
end

archmail = Archmail.new
archmail.run

#Archmail.debug