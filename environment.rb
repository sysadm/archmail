# environment.rb
require 'rubygems'
require 'openssl'
require 'net/imap'
require 'active_record'
require 'active_support'
require 'active_support/all'
require 'action_pack'
require 'action_view'
require 'closure_tree'
require 'mail'
require 'fileutils'
require_relative 'lib/mime_type'
require 'slim'
require 'pp'

silence_warnings do
  OpenSSL::SSL.const_set(:VERIFY_PEER, OpenSSL::SSL::VERIFY_NONE)
end

begin
  CONFIG ||= YAML.load_file("./config.yml")
rescue => e
  puts "Unable to load data from config, you must create it (or copy from config.yml.example and modify it with your own credentials and configuration of mail server)."
  exit 1
end

I18n.enforce_available_locales = false
Slim::Engine.set_default_options(:format => :html5)

module Rails
  def self.env
    ActiveSupport::StringInquirer.new('production')
  end
end

# tells AR what db file to use
ActiveRecord::Base.establish_connection(
    :adapter => 'sqlite3',
    :database => './lib/db/mailbox.db'
)

Dir.glob("./lib/*.rb").each do |file|
  require file
end
Dir.glob("./lib/db/migrations/*.rb").each do |file|
  require file
end

VERSION = "1.0 beta"
ENV['ARCHMAIL_ENV'] ? ENVIRONMENT = ENV['ARCHMAIL_ENV'] : ENVIRONMENT = "production"
CMD_LINE_OPTIONS = CmdLineParser.parse(ARGV)

ActiveRecord::Migration.verbose = CMD_LINE_OPTIONS.verbose

class Env
  attr_accessor :user, :pass, :server, :arch_path, :imap
  def initialize
    @user = CONFIG['login']
    @pass = CONFIG['password']
    @server = CONFIG['server']
    @port = CONFIG['port']
    @arch_path = State.open.arch_path
  end
  def imap_connect
    @imap = Net::IMAP.new(@server, @port, :ssl => { :verify_mode => OpenSSL::SSL::VERIFY_NONE })
    @imap.authenticate('login', @user, @pass)
  end
end

def define_context
  @view = Class.new(ActionView::Base).new("lib/views/templates")
  @env = Env.new
  @user = @env.user
end

def define_backup_path
  if CMD_LINE_OPTIONS.continue # continue exist, but interrupted backup
    begin
      @state = YAML.load_file("./state.yml")
      @state.continue_time = Time.now
      @state.save
    rescue => e
      puts "You can not continue, 'cause you don't have old state of your backup or write permission: #{e.message}"
      exit 1
    end
  else # create new backup
    arch_path = "#{CONFIG['login']}_#{Date.today.to_s}"
    if File.directory? arch_path # backup directory exist
      puts "You want to do new backup of imap server, but folder #{arch_path} already exist."
      puts "If you really want to erase it, type YES:"
      confirmation = gets.chomp
      if confirmation.downcase == "yes"
        @state = State.new(begin_time: Time.now, arch_path: arch_path)
        @state.save
      else
        puts "No confirmation to delete folder #{arch_path}"
        exit 1
      end
    else # backup directory not exist
      @state = State.new(begin_time: Time.now, arch_path: arch_path)
      @state.save
    end
  end
end

def arch_logger(message)
  puts message if CMD_LINE_OPTIONS.verbose
  File.open(CMD_LINE_OPTIONS.logfile, "a+b", 0644) {|f| f.write message} if CMD_LINE_OPTIONS.logfile
end

define_backup_path
