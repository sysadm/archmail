module ActionView::Helpers::TextHelper
  def current_user
    env = Env.new
    env.user
  end

  def view
    Class.new(ActionView::Base).new("lib/views/templates")
  end
end
