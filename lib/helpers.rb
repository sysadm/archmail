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

  def attachment_icon(type)
    case type
      when /word/i
        '<i class="fa fa-file-word-o fa-2x"></i>'
      when /excel/i
        '<i class="fa fa-file-excel-o fa-2x"></i>'
      when /powerpoint/i
        '<i class="fa fa-file-powerpoint-o fa-2x"></i>'
      when /x-tar|zip/i
        '<i class="fa fa-file-archive-o fa-2x"></i>'
      when /pdf/i
        '<i class="fa fa-file-pdf-o fa-2x"></i>'
      when /text/i
        '<i class="fa fa-file-text-o fa-2x"></i>'
      when /rfc822/i
        '<i class="fa fa-file-code-o fa-2x"></i>'
      when /image/i
        '<i class="fa fa-file-image-o fa-2x"></i>'
      when /audio/i
        '<i class="fa fa-file-audio-o fa-2x"></i>'
      else
        '<i class="fa fa-file fa-2x"></i>'
    end
  end

  def oddclass(counter=nil)
    @@counter = counter if counter
    @@counter.odd? ? oddclass="odd" : oddclass="even"
    @@counter += 1
    oddclass
  end
end
