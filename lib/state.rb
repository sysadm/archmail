class State < OpenStruct

  def self.open
    if CMD_LINE_OPTIONS.continue
      begin
        @state = YAML.load_file("./state.yml")
      rescue => e
        if ENVIRONMENT == "production"
          puts "You can not continue, 'cause you don't have old state of your backup: #{e.message}"
          exit 1
        else
          @state = State.new
          @state.begin_time = Time.now
        end
      end
    else
      @state = State.new
      @state.begin_time = Time.now
    end
    @state
  end

  def self.arch_path
    @state = YAML.load_file("./state.yml")
    @state.arch_path
  end

  def save
    begin
      File.open("./state.yml", "w+b", 0644) {|f| f.write self.to_yaml}
    rescue => e
      puts "Can not continue, 'cause can't save state of backup: #{e.message}"
    end
  end

end