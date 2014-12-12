class Db
  def self.create
    %x{createdb -p 5432 -h localhost -U postgres -E UTF-8 archmail}
  end
  def self.drop
    %x{dropdb -p 5432 -h localhost -U postgres archmail}
  end
  def self.migrate(action) # Action must be :up or :down
    InitSchema.migrate(action)
    CreateHierarchiesTable.migrate(action)
  end
end