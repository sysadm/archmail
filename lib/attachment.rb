class Attachment < ActiveRecord::Base
  belongs_to :message

  def path
    @env ||= Env.new
    folder = self.message.folder
    message = self.message
    ([@env.arch_path] + folder.ancestry_path).join('/') + "/#{message.id}/#{self.filename}"
  end
end
