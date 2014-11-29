# environment.rb
require 'rubygems'
require 'io/console'
require 'openssl'
require 'net/imap'
require 'active_record'
require 'active_support'
require 'active_support/all'
require 'action_pack'
require 'action_view'
require 'closure_tree'
require 'mail'
require_relative 'lib/mime_type'
require 'slim'
require 'pp'

silence_warnings do
  OpenSSL::SSL.const_set(:VERIFY_PEER, OpenSSL::SSL::VERIFY_NONE)
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

def create_config
  config = {}
  "Gmail account (y/N)? ".print_and_flush(true)
  input = gets.chomp
  input.downcase == "y" ? config[:gmail] = true : config[:gmail] = false
  if config[:gmail]
    config[:server] = "imap.gmail.com"
    config[:port] = 993
    config[:tls_ssl] = true
    "Your full Gmail address (e.g. \"me@gmail.com\"): ".print_and_flush(true)
    config[:login] = gets.chomp
  else
    "IMAP server hostname: ".print_and_flush(true)
    config[:server] = gets.chomp
    "port: ".print_and_flush(true)
    config[:port] = gets.chomp.to_i
    "TLS/SSL required (Y/n)? ".print_and_flush(true)
    input = gets.chomp
    input.downcase == "n" ? config[:tls_ssl] = false : config[:tls_ssl] = true
    "Your login: ".print_and_flush(true)
    config[:login] = gets.chomp
  end
  "Type your password (will be hidden): ".print_and_flush(true)
  config[:password] = STDIN.noecho(&:gets).chomp

  begin
    File.open("config.yml", "w+b", 0644) {|f| f.write config.to_yaml}
    puts ""
    puts "Config created. Now you can backup your imap mailbox."
    exit 0
  rescue => e
    puts ""
    puts "Can't save config, 'cause you probably don't have write permission: #{e.message}"
    exit 1
  end
end

create_config if CMD_LINE_OPTIONS.interactive

begin
  CONFIG ||= YAML.load_file("./config.yml")
rescue => e
  puts "Unable to load data from config, you must create it (or copy from config.yml.example and modify it with your own credentials and configuration of mail server)."
  puts "Eventually you can use option -i to create config interactively."
  exit 1
end

ActiveRecord::Migration.verbose = CMD_LINE_OPTIONS.verbose

class Env
  attr_accessor :user, :pass, :server, :arch_path, :imap
  def initialize
    @user = CONFIG[:login]
    @pass = CONFIG[:password]
    @server = CONFIG[:server]
    @port = CONFIG[:port]
    @arch_path = State.open.arch_path
  end

  def imap_connect
    begin
      @imap = Net::IMAP.new(@server, @port, :ssl => { :verify_mode => OpenSSL::SSL::VERIFY_NONE })
      @imap.authenticate('login', @user, @pass)
    rescue => e
      puts "Can't login to IMAP server: #{e.message}"
      puts "Check your config.yml first."
      exit 1
    end
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
    arch_path = "#{CONFIG[:login]}_#{Date.today.to_s}"
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
