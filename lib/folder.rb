class Folder < ActiveRecord::Base
  attr_reader :env
  acts_as_tree
  has_many :messages, dependent: :destroy
  after_initialize :define_context

  def define_context
    @env ||= Env.new
  end

  def generate_safe_name
    safe_name = self.name.gsub(/[^\w]/, '_').upcase
    if self.root?
      full_path = "#{@env.arch_path}/#{safe_name}"
    else
      full_path = "#{@env.arch_path}/#{(self.ancestors.map(&:safe_name).reverse + [safe_name]).join('/')}"
    end
    safe_name += "_#{self.id}" if File.directory? full_path
    self.update_attribute(:safe_name, safe_name)
  end

  def create_root_structure
    @env.imap_connect
    Dir.mkdir @env.arch_path
    %x{cp -r lib/views/assets \"#{@env.arch_path}\" }
    mailboxes = @env.imap.list("", "%").to_a
    mailboxes.each{|mailbox|
      folder = Folder.find_or_create_by(name: mailbox.name, imap_name: mailbox.name, delim: mailbox.delim, attr: mailbox.attr.join(','))
      folder.generate_safe_name
      %x{mkdir -p \"#{@env.arch_path}/#{folder.safe_name}\" }
      if mailbox.attr.include? :Haschildren
        create_subfolder_tree folder
      end
    }
  end

  def create_subfolder_tree(folder)
    mailboxes = @env.imap.list("#{folder.imap_name}#{folder.delim}", "%").to_a
    mailboxes.each{|mailbox|
      name = mailbox.name.gsub("#{folder.imap_name}#{folder.delim}", "")
      subfolder = folder.children.create(name: name, imap_name: mailbox.name, delim: mailbox.delim, attr: mailbox.attr.join(','))
      subfolder.generate_safe_name
      %x{mkdir -p \"#{([@env.arch_path] + subfolder.ancestry_safe_path).join('/')}\" }
      create_subfolder_tree subfolder if mailbox.attr.include? :Haschildren
    }
  end

  def except_clean_up(recursive)
    if recursive
      folders_to_save = self.ancestors + self.self_and_descendants
    else
      folders_to_save = self.self_and_ancestors
    end
    folders_to_clean = Folder.all - folders_to_save
    folders_to_clean.each do |folder|
      %x{rm -rf \"#{([@env.arch_path] + folder.ancestry_safe_path).join('/')}\" }
      folder.destroy
    end
  end

  def tags_with_color(kind='flag')
    tags, tags_with_color = [], {}
    if kind == 'flag'
      combined = self.messages.map(&:flags).uniq.compact
    else
      combined = self.messages.map(&:gm_labels).uniq.compact
    end
    combined.each{|set| tags << set.split(',')} unless combined.empty?
    tags.flatten.uniq.each do |tag|
      color = Tag.where(kind: kind, name: tag).first.color
      tags_with_color["#{tag}"] = color
    end
    tags_with_color
  end

  def ancestry_safe_path
    self.self_and_ancestors.map(&:safe_name).reverse
  end
end
