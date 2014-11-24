class HtmlGenerator

  def initialize
    define_context
  end

  def index_pages
    folders = Folder.roots.order(:name)
    file = "#{@env.arch_path}/index.html"
    File.open(file, "w+b", 0644) {|f| f.write @view.render(template: "index", :locals => { :folders => folders })}
    file = "#{@env.arch_path}/statistic.html"
    File.open(file, "w+b", 0644) {|f| f.write @view.render(template: "statistic")}
    file = "#{@env.arch_path}/about.html"
    File.open(file, "w+b", 0644) {|f| f.write @view.render(template: "about")}
    file = "#{@env.arch_path}/license.html"
    File.open(file, "w+b", 0644) {|f| f.write @view.render(template: "license")}
  end

  def folder_index_pages
    folders = Folder.all
    folders.each do |folder|
      path = ([@env.arch_path] + folder.ancestry_path).join('/')
      file = "#{path}/threaded.html"
      File.open(file, "w+b", 0644) {|f| f.write @view.render(template: "threaded", :locals => { :folder => folder })}
      file = "#{path}/date.html"
      File.open(file, "w+b", 0644) {|f| f.write @view.render(template: "date", :locals => { :folder => folder })}
      file = "#{path}/subject.html"
      File.open(file, "w+b", 0644) {|f| f.write @view.render(template: "subject", :locals => { :folder => folder })}
      file = "#{path}/author.html"
      File.open(file, "w+b", 0644) {|f| f.write @view.render(template: "author", :locals => { :folder => folder })}
      file = "#{path}/attachment.html"
      File.open(file, "w+b", 0644) {|f| f.write @view.render(template: "attachment", :locals => { :folder => folder })}
    end
  end

end
