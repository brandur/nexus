Sequel.migration do
  change do
    create_table(:sources) do
      primary_key :id
      String :name, null: false
      index :name, unique: true
    end
  end
end
