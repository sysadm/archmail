class Message < ActiveRecord::Base
  acts_as_tree
  belongs_to :folder

end
