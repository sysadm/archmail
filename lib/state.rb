class State < OpenStruct
  def self.open
    @state = YAML.load_file("./state.yml")
  end

  def save
    begin
      File.open("./state.yml", "w+b", 0644) {|f| f.write self.to_yaml}
    rescue => e
      puts "Can not continue, 'cause can't save state of backup: #{e.message}"
    end
  end
end
