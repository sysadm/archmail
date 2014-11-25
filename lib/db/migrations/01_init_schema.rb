class InitSchema < ActiveRecord::Migration
  def change
    create_table :folders do |t|
      t.string :name
      t.string :imap_name
      t.integer :parent_id

      t.timestamps
    end
    create_table :messages do |t|
      t.integer :uid
      t.string :message_id
      t.string :in_reply_to
      t.string :from
      t.string :subject
      t.string :flags
      t.boolean :has_attachment
      t.boolean :export_complete, default: false
      t.integer :size
      t.integer :parent_id
      t.belongs_to :folder
      t.text :rfc_header

      t.timestamps
    end
    create_table :attachments do |t|
      t.text  :original_filename
      t.string  :filename
      t.string  :content_type
      t.integer :size
      t.belongs_to :message
    end
  end
end
