class HtmlGenerator

  def initialize
    define_context
  end

  def generate_all
    index_pages
    folder_index_pages
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
    jspath = @env.arch_path + "/assets/js/pathes.js"
    @js = File.open(jspath, "w+b", 0644)
    @js.write "var folder_path=[];\n"
    folders.each do |folder|
      path = ([@env.arch_path] + folder.ancestry_path).join('/')
      @js.write "folder_path['folder_#{folder.id}']='#{URI.escape folder.ancestry_path.join('/')}/'\n"
      if folder.messages.count > 1
        first = folder.messages.order(:created_at).first.created_at.to_date
        last = folder.messages.order(:created_at).last.created_at.to_date
        time_range = first..last
      end
      file = "#{path}/threaded.html"
      File.open(file, "w+b", 0644) {|f| f.write @view.render(template: "threaded",
                                                             locals: { folder: folder, time_range: time_range })}
      file = "#{path}/date.html"
      messages = folder.messages.order(:created_at)
      File.open(file, "w+b", 0644) {|f| f.write @view.render(template: "date",
                                                             locals: { folder: folder, time_range: time_range, messages: messages })}
      file = "#{path}/subject.html"
      messages = folder.messages.order(:subject)
      File.open(file, "w+b", 0644) {|f| f.write @view.render(template: "subject",
                                                             locals: { folder: folder, time_range: time_range, messages: messages })}
      file = "#{path}/author.html"
      messages = folder.messages.order(:from)
      File.open(file, "w+b", 0644) {|f| f.write @view.render(template: "author",
                                                             locals: { folder: folder, time_range: time_range, messages: messages })}
      file = "#{path}/attachment.html"
      messages = folder.messages.where(has_attachment: true).order(:created_at)
      File.open(file, "w+b", 0644) {|f| f.write @view.render(template: "attachment",
                                                             locals: { folder: folder, time_range: time_range, messages: messages })}
    end
    @js.close
  end

end
