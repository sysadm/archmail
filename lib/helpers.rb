module ActionView::Helpers::TextHelper
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

  def folder_with_icon(id)
    folder = Folder.find id
    name = folder.name
    prefix = "-"*folder.ancestors.count
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
end
