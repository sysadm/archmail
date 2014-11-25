module ActionView::Helpers::TextHelper
  @@counter ||= 0

  def current_user
    env = Env.new
    env.user
  end

  def server
    env = Env.new
    env.server
  end

  def view
    Class.new(ActionView::Base).new("lib/views/templates")
  end

  def folder_with_icon(id, with_prefix=false)
    folder = Folder.find id
    name = folder.name
    with_prefix ? prefix = "-"*folder.ancestors.count : prefix = ""
    case name
      when /trash|delete/i
        "#{prefix} <i class='fa fa-trash'></i>#{name}"
      when /inbox/i
        "#{prefix} <i class='fa fa-inbox'></i>#{name}"
      when /draft/i
        "#{prefix} <i class='fa fa-pencil'></i>#{name}"
      when /sent/i
        "#{prefix} <i class='fa fa-paper-plane'></i>#{name}"
      else
        "#{prefix} <i class='fa fa-folder'></i>#{name}"
    end
  end

  def oddclass(counter=nil)
    @@counter = counter if counter
    @@counter.odd? ? oddclass="odd" : oddclass="even"
    @@counter += 1
    oddclass
  end
end
