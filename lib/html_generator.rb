class HtmlGenerator

  def initialize
    define_context
  end

  def index_pages
    @folders = Folder.roots.order(:name)
    file = "#{@env.arch_path}/index.html"
    File.open(file, "w+b", 0644) {|f| f.write @view.render(template: "index", :locals => { :folders => @folders })}
    file = "#{@env.arch_path}/statistic.html"
    File.open(file, "w+b", 0644) {|f| f.write @view.render(template: "statistic")}
    file = "#{@env.arch_path}/about.html"
    File.open(file, "w+b", 0644) {|f| f.write @view.render(template: "about")}
    file = "#{@env.arch_path}/license.html"
    File.open(file, "w+b", 0644) {|f| f.write @view.render(template: "license")}
  end

  # def index_page(folder)
  #   layout = File.open("layout.slim", "rb").read
  #   template = Slim::Template.new('views/templates/index.slim').render
  #   file = ([@arch_path] + folder.ancestry_path).join('/') + "/index.html"
  #
  #   File.open(file, "w+b", 0644) {|f| f.write "<div id='rfc'>#{header}</div><br />#{body}"}
  # end

end
