class CreateHierarchiesTable < ActiveRecord::Migration
  def change
    create_table :folder_hierarchies, id: false do |t|
      t.integer :ancestor_id, null: false
      t.integer :descendant_id, null: false
      t.integer :generations, null: false
      # add_index :folder_hierarchies, [:ancestor_id, :descendant_id, :generations],
      #           unique: true,
      #           name: "anc_desc_idx"
      #
      # add_index :folder_hierarchies, [:descendant_id],
      #           name: "desc_idx"
    end
    create_table :message_hierarchies, id: false do |t|
      t.integer :ancestor_id, null: false
      t.integer :descendant_id, null: false
      t.integer :generations, null: false
    end
  end
end

