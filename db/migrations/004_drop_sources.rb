Sequel.migration do
  up do
    add_column :events, :source, String
    run %{
UPDATE events SET source = (
  SELECT name FROM sources WHERE id = events.source_id
)
    }
    drop_column :events, :source_id
    drop_table :sources
  end
end
