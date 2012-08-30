Sequel.migration do
  up do
    run "CREATE EXTENSION IF NOT EXISTS hstore"
    run "ALTER TABLE events ADD COLUMN metadata hstore"
  end

  down do
    run "ALTER TABLE events DROP COLUMN metadata hstore"
    run "DROP EXTENSION hstore"
  end
end
