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

silence_warnings do
  OpenSSL::SSL.const_set(:VERIFY_PEER, OpenSSL::SSL::VERIFY_NONE)
end

I18n.enforce_available_locales = false
Slim::Engine.set_default_options(:format => :xhtml)

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
  attr_accessor :folders
  def initialize
    @folders = Folder.roots
  end
end

def define_context
  @view = Class.new(ActionView::Base).new("lib/views/templates")
  @env = Env.new
end

def print_and_flush(str)
  print str
  $stdout.flush
end
