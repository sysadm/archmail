class Folder < ActiveRecord::Base
  attr_reader :env
  acts_as_tree
  has_many :messages, dependent: :destroy
  after_initialize :define_context

  def define_context
    @env ||= Env.new
  end

  def create_root_structure
    @env.imap_connect
    Dir.mkdir @env.arch_path
    FileUtils.cp_r "lib/views/assets", "#{@env.arch_path}"
    mailboxes = @env.imap.list("", "%").to_a
    mailboxes.each{|mailbox|
      folder = Folder.find_or_create_by(name: mailbox.name, imap_name: mailbox.name)
      FileUtils.mkdir_p "#{@env.arch_path}/#{folder.name}"
      if mailbox.attr.include? :Haschildren
        create_subfolder_tree folder
      end
    }
  end

  def create_subfolder_tree(folder)
    mailboxes = @env.imap.list("#{folder.imap_name}.", "%").to_a
    mailboxes.each{|mailbox|
      name = mailbox.name.gsub("#{folder.imap_name}.", "")
      subfolder = folder.children.create(name: name, imap_name: mailbox.name)
      FileUtils.mkdir_p ([@env.arch_path] + subfolder.ancestry_path).join('/')
      create_subfolder_tree subfolder if mailbox.attr.include? :Haschildren
    }
  end

  def clean_up_except_folder
    folders_to_save = self.self_and_ancestors
    folders_to_clean = Folder.all - folders_to_save
    folders_to_clean.each do |folder|
      FileUtils.rm_rf ([@env.arch_path] + folder.ancestry_path).join('/')
      folder.destroy
    end
  end
end
