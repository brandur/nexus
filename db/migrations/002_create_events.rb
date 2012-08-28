Sequel.migration do
  change do
    create_table(:events) do
      primary_key :id
      foreign_key :source_id, :sources, null: false

      String :title
      String :content
      String :tag, null: false
      String :url
      DateTime :published_at, null: false

      index :tag, unique: true
    end
  end
end
