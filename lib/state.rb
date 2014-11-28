class State < OpenStruct
  def self.open
    begin
      @state = YAML.load_file("./state.yml")
    rescue
      if ENVIRONMENT == "development"
        puts "Remember, that you haven't ./state.yml yet."
      else
        puts "Can't load ./state.yml"
        exit 1
      end
    end
  end

  def save
    begin
      File.open("./state.yml", "w+b", 0644) {|f| f.write self.to_yaml}
    rescue => e
      puts "Can not continue, 'cause can't save state of backup: #{e.message}"
    end
  end
end
