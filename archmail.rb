#!/usr/bin/env ruby
require './environment'

class Archmail
  attr_reader :options, :env
  attr_accessor :message, :state

  def define_context
    @options = CMD_LINE_OPTIONS
    @state = State.open
    @state.interrupts ||= []
    @env = Env.new
  end

  def run
    begin
      define_context
      if @state.interrupts.count > 0
        arch_logger "Program was interrupted #{@state.interrupts.count} times, last time at: #{@state.interrupts.last}\n\n"
      else
        arch_logger "Program can be interrupted any moment with 'ctrl + C'\n\n"
      end
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
      Message.create_tags
      Tag.colorize
      save_messages
      unless @message.conversion_errors.empty?
        arch_logger "This is only warning message(s), not error:"
        @message.conversion_errors.each do |key, value|
          arch_logger " Message #{key}:"
          message_info(Message.find key)
          arch_logger "  probably wasn't converted normally to UTF-8 'cause: #{value}"
        end
      end
      create_html_indexes
      err_code = self_checking
      @state.finish_time = Time.now
      @state.save
      if @state.interrupts.empty?
        estimate = (@state.finish_time - @state.begin_time).human_readable_time_interval
        arch_logger "total time: #{estimate}."
      end
      %x{rm -f ./.lock-ClosureTree*}
      exit err_code
    rescue Interrupt
      @state.interrupts << Time.now
      @state.save
      puts "\n\nInterrupted by user"
      exit 1
    end
  end

  def create_message_structure
    @state.message_structure_complete_in_folder = {}
    if @options.folders == :all
      Folder.all.each do |folder|
        unless folder.attr.downcase.include? "noselect"
          arch_logger "Folder: #{folder.id} - #{folder.self_and_ancestors.map(&:name).reverse.join('/')}"
          @message.fetch_all_headers(folder)
          @message.create_messages_tree_in_folder(folder)
        else
          arch_logger "Folder: #{folder.id} - #{folder.self_and_ancestors.map(&:name).reverse.join('/')} will be ignored, 'cause have attribute 'Noselect'"
        end
        @state.message_structure_complete_in_folder[folder.id] = true
        @state.save
      end
      @state.message_structure_complete = true
      @state.save
    else
      backup_folder = Folder.find_by_path @options.folder.split('/')
      if backup_folder
        CMD_LINE_OPTIONS.recursive ? @folders = backup_folder.self_and_descendants : @folders = [backup_folder]
        @folders.each do |folder|
          unless folder.attr.downcase.include? "noselect"
            arch_logger "Folder: #{folder.id} - #{folder.self_and_ancestors.map(&:name).reverse.join('/')}"
            @message.fetch_all_headers(folder)
            @message.create_messages_tree_in_folder(folder)
          else
            arch_logger "Folder: #{folder.id} - #{folder.self_and_ancestors.map(&:name).reverse.join('/')} will be ignored, 'cause have attribute 'Noselect'"
          end
          @state.message_structure_complete_in_folder[folder.id] = true
          @state.save
        end
        backup_folder.except_clean_up CMD_LINE_OPTIONS.recursive
        @state.message_structure_complete = true
        @state.save
      else
        arch_logger "Folder: #{@options.folder} doesn't exist on imap server"
        exit 1
      end
    end
  end

  def create_message_structure_continue
    @state.message_structure_complete_in_folder ||= {}
    if @options.folders == :all
      Folder.all.each do |folder|
        if @state.message_structure_complete_in_folder[folder.id]
          arch_logger "Pass the folder #{folder.id} - \"#{folder.self_and_ancestors.map(&:name).reverse.join('/')}\", 'cause message structure was saved earlier"
          else
            unless folder.attr.downcase.include? "noselect"
              arch_logger "Folder: #{folder.id} - #{folder.self_and_ancestors.map(&:name).reverse.join('/')}"
              folder.messages.destroy_all #clean all non-complete message structures in folder
              @message.fetch_all_headers(folder)
              @message.create_messages_tree_in_folder(folder)
            else
              arch_logger "Folder: #{folder.id} - #{folder.self_and_ancestors.map(&:name).reverse.join('/')} will be ignored, 'cause have attribute 'Noselect'"
            end
            @state.message_structure_complete_in_folder[folder.id] = true
            @state.save
        end
      end
      @state.message_structure_complete = true
      @state.save
    else
      backup_folder = Folder.find_by_path @options.folder.split('/')
      if backup_folder
        CMD_LINE_OPTIONS.recursive ? @folders = backup_folder.self_and_descendants : @folders = [backup_folder]
        @folders.each do |folder|
          if @state.message_structure_complete_in_folder[folder.id]
            arch_logger "Pass the folder #{folder.id} - \"#{folder.self_and_ancestors.map(&:name).reverse.join('/')}\", 'cause message structure was saved earlier"
          else
            unless folder.attr.downcase.include? "noselect"
              arch_logger "Folder: #{folder.id} - #{folder.self_and_ancestors.map(&:name).reverse.join('/')}"
              folder.messages.destroy_all #clean all non-complete message structures in folder
              @message.fetch_all_headers(folder)
              @message.create_messages_tree_in_folder(folder)
            else
              arch_logger "Folder: #{folder.id} - #{folder.self_and_ancestors.map(&:name).reverse.join('/')} will be ignored, 'cause have attribute 'Noselect'"
            end
            @state.message_structure_complete_in_folder[folder.id] = true
            @state.save
          end
        end
        backup_folder.except_clean_up CMD_LINE_OPTIONS.recursive
        @state.message_structure_complete = true
        @state.save
      else
        arch_logger "Folder: #{@options.folder} doesn't exist on imap server"
        exit 1
      end
    end
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
    CMD_LINE_OPTIONS.continue ? messages = Message.where(export_complete: false) : messages = Message.all
    arch_logger "Fetch and save #{messages.count} message(s)"
    messages.each{|m| @message.backup(m); ".".print_and_flush(CMD_LINE_OPTIONS.verbose) }
    arch_logger " done"
  end

  def clean_all
    #File.open("./lib/db/mailbox.db", "w+b", 0644) {|f| f.write ''}
    %x{rm -rf \"#{@env.arch_path}\"}
    Db.migrate :down
    Db.migrate :up
  end

  def create_html_indexes
    arch_logger "Run html generators..."
    html_generator = HtmlGenerator.new
    html_generator.generate_all
    arch_logger "done"
  end

  def self_checking
    errors, messages, attachments = [], 0, 0
    Message.all.each { |message| errors << message unless File.exist? message.path }
    Attachment.all.each { |attachment| errors << attachment unless File.exist? attachment.path }
    if errors.empty?
      arch_logger "Backup complete"
    else
      arch_logger "Backup complete, but #{errors.count} error(s) occured:"
      errors.each do |err|
        if err.class == Message
          messages += 1
          arch_logger "Message #{err.id} doesn't create:"
          message_info(err)
        elsif err.class == Attachment
          attachments += 1
          arch_logger "Attachment #{err.id} doesn't create:"
          arch_logger "\t original filename: \'#{err.original_filename}\'"
          arch_logger "\t content type: #{err.content_type}"
          arch_logger "\t size: #{err.size}"
          arch_logger "\t attachment belongs to message #{err.message.id}:"
          message_info(err.message)
        end
      end
      arch_logger "Amount of unsaved messages: #{messages} (#{sprintf( "%0.03f", messages.to_f/Message.count*100)}%)" if messages > 0
      arch_logger "Amount of unsaved attachments: #{attachments} (#{sprintf( "%0.03f", attachments.to_f/Attachment.count*100)}%)" if attachments > 0
    end
    errors.empty? ? 0 : 1
  end

  def message_info(message)
    arch_logger "\t folder: #{message.folder.imap_name.split(message.folder.delim).join('/')}"
    arch_logger "\t subject: #{message.subject}"
    arch_logger "\t date: #{message.created_at.to_s}"
    arch_logger "\t from: #{message.from}"
    arch_logger "\t size: #{message.size}"
  end

  def self.debug
    pp @options
    pp @state
    exit
  end
end

archmail = Archmail.new
archmail.run
