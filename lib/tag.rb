class Tag < ActiveRecord::Base
  belongs_to :message

  def self.colorize
    uniq_tags = Tag.all.map{|tag| [tag.kind, tag.name]}.uniq
    uniq_tags.each do |tag|
      color = generate_uniq_color
      Tag.where(kind: tag[0], name: tag[1]).update_all(color: color)
    end
    create_stylesheet
  end

  def self.generate_uniq_color
    begin
      r = rand(120..230).to_s(16)
      g = rand(70..150).to_s(16)
      b = rand(80..164).to_s(16)
      @color = r+g+b
    end until color_uniq? @color
    @color
  end

  def self.color_uniq?(rgb)
    Tag.all.map(&:color).uniq.exclude? rgb
  end

  def self.create_stylesheet
    @env ||= Env.new
    begin
      file = @env.arch_path+"/assets/css/tags.css"
      @css = File.open(file, "w+b", 0644)
    rescue => e
      arch_logger "Unable to save data to #{file} because #{e.message}"
    end
    Tag.all.map(&:color).uniq.each do |color|
      style = ".balloon_#{color} { background-color: ##{color}; }\n.tag_#{color} a { color: ##{color}; }\n.tag_#{color} a:hover { color: ##{color}; }\n"
      @css.write style
    end
    @css.close
  end
end
