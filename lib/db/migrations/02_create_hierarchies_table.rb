class CreateHierarchiesTable < ActiveRecord::Migration
  def up
    create_table :folder_hierarchies, id: false do |t|
      t.integer :ancestor_id, null: false
      t.integer :descendant_id, null: false
      t.integer :generations, null: false
    end
    create_table :message_hierarchies, id: false do |t|
      t.integer :ancestor_id, null: false
      t.integer :descendant_id, null: false
      t.integer :generations, null: false
    end
    add_index :folder_hierarchies, [:ancestor_id, :descendant_id, :generations],
              unique: true,
              name: "folder_anc_desc_idx"
    add_index :folder_hierarchies, [:descendant_id],
              name: "folder_desc_idx"

    add_index :message_hierarchies, [:ancestor_id, :descendant_id, :generations],
              unique: true,
              name: "message_anc_desc_idx"

    add_index :message_hierarchies, [:descendant_id],
              name: "message_desc_idx"
  end

  def down
    drop_table :folder_hierarchies
    drop_table :message_hierarchies
  end
end
