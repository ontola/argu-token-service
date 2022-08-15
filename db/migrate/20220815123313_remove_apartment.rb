class RemoveApartment < ActiveRecord::Migration[7.0]
  def change
    excluded_tables = %w[ar_internal_metadata schema_migrations]

    migrate_tables(ApplicationRecord.connection.tables - excluded_tables)
  end

  def migrate_tables(tables)
    tables.each do |table|
      ApplicationRecord.connection.execute("INSERT INTO public.#{table} SELECT * FROM argu.#{table};")
      ActiveRecord::Base.connection.reset_pk_sequence!(table)
    end
  end
end
