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
  puts "Unable to load data from config, you must create it (or copy from config.yml.example and modify it)."
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

class Env
  attr_accessor :user, :pass, :server, :arch_path, :imap
  def initialize
    @user = CONFIG['login']
    @pass = CONFIG['password']
    @server = CONFIG['server']
    @port = CONFIG['port']
    @arch_path = "#{@user}_#{Date.today.to_s}"
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
