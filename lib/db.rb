class Db
  def self.migrate(action) # Action must be :up or :down
    InitSchema.migrate(action)
    CreateHierarchiesTable.migrate(action)
  end
end