class Message < ActiveRecord::Base
  acts_as_tree
  belongs_to :folder
  has_many :attachments

end
