# environment.rb
require 'rubygems'
require 'openssl'
require 'net/imap'
require 'active_record'
require 'active_support'
require 'active_support/all'
require 'closure_tree'
require 'mail'
require 'fileutils'
require 'erb'

I18n.enforce_available_locales = false

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

silence_warnings do
  OpenSSL::SSL.const_set(:VERIFY_PEER, OpenSSL::SSL::VERIFY_NONE)
end
