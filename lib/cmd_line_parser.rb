require 'optparse'
require 'optparse/date'
require 'ostruct'

class CmdLineParser
  def self.parse(args)
    # The options specified on the command line will be collected in *options*.
    # We set default values here.
    options = OpenStruct.new
    options.folders = :all
    options.recursive = true
    options.verbose = true
    options.continue = false
    options.unknown = true

    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: ./archmail.rb [options]"

      opts.separator ""
      opts.separator "Specific options:"

      opts.on("-a", "--all", "Backup all folders from imap server") do
        options.unknown = false
        options.folders = :all
      end

      opts.on("-f", "--folder=FOLDER", "Backup specific folder, case sensitive. Example: \"INBOX/Year 2014/Décembre\" (quotes required)") do |folder|
        options.unknown = false
        options.folders = :specific
        options.folder = folder.split('/').join('.')
      end

      # Boolean switch.
      opts.on("-r", "--[no-]recursive", "Backup specific folder with subfolders (default) or without") do |r|
        options.unknown = false
        options.recursive = r
      end

      opts.on("-c", "--continue", "Don't clean database, continue backup for all unsaved messages") do
        options.unknown = false
        options.continue = true
      end

      opts.on("-s", "--silent", "Silent mode (verbose default)") do
        options.unknown = false
        options.verbose = false
      end

      opts.on("-l", "--log=LOGFILE", "Define logfile. Can be combined with silent mode.") do |log|
        options.unknown = false
        begin
          File.open(log, "a+b", 0644) {|f| f.write ""}
        rescue => e
          puts "#{e.message}\n"
          puts "Probably you have no write access for logfile" if e.message.include? "No such file or directory"
          exit
        end
        options.logfile = log
      end

      opts.separator ""
      opts.separator "Common options:"

      opts.on_tail("-h", "--help", "Show this message") do
        options.unknown = false
        puts opts
        exit
      end

      # Another typical switch to print the version.
      opts.on_tail("-v", "--version", "Show version") do
        options.unknown = false
        git = %x{which git}.chomp
        if File.exist? git and File.directory? ".git"
          last_commit = %x{#{git} log -1| head -n 3}.split('\n')
          last_commit[0] = last_commit[0].sub('commit', 'Last commit:')
        end
        puts "Arcmail is #{VERSION}"
        last_commit.each{|string| puts string} if last_commit
        exit
      end

      @opts = opts
    end

    begin
      opt_parser.parse!(args)
    rescue => e
      puts "#{e.message}\n\n"
      puts @opts
      exit
    end
    if options.unknown and ENVIRONMENT == "production"
      puts @opts
      exit
    end

    options
  end
end
