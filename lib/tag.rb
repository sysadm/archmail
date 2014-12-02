class Tag < ActiveRecord::Base
  belongs_to :message

  def self.colorize
    @@color_matrix = []
    @@hcolors = {}
    uniq_tags = Tag.all.map{|tag| [tag.kind, tag.name]}.uniq
    uniq_tags.each do |tag|
      color = generate_color
      Tag.where(kind: tag[0], name: tag[1]).update_all(color: color[0], hcolor: color[1])
    end
    create_stylesheet
  end

  def self.generate_color
    i = 0
    begin
      r = rand(70..215)
      g = rand(60..180)
      b = rand(50..190)
      @color = r.to_s(16) + g.to_s(16) + b.to_s(16)
      @hcolor = (r-30).to_s(16) + (g-30).to_s(16) + (b-30).to_s(16)
      i += 1
    end until color_different_enough?(r, g, b) or i > 50
    @@color_matrix.push [r, g, b]
    @@hcolors[@color] = @hcolor
    [@color, @hcolor]
  end

  def self.color_different_enough?(r, g, b)
    distances = []
    @@color_matrix.each {|color| distances << ( (r-color[0])**2 + (g-color[1])**2 + (b-color[1])**2 ).sqrt }
    distances.min.nil? or distances.min > 80.0 ? true : false
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
      style = ".balloon_#{color} { background-color: ##{color}; }\n.balloon_#{color}:hover { background-color: ##{@@hcolors[color]}; }\n.tag_#{color} { color: ##{color}; }\n.tag_#{color}:hover { color: ##{@@hcolors[color]}; }\n"
      @css.write style
    end
    @css.close
  end
end
