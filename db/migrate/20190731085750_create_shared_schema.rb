class CreateSharedSchema < ActiveRecord::Migration[5.2]
  def change
    ActiveRecord::Base.connection.execute 'CREATE SCHEMA IF NOT EXISTS shared_extensions;'
    ActiveRecord::Base.connection.execute 'GRANT usage ON SCHEMA shared_extensions to public;'

    %w[uuid-ossp].each do |extension|
      ActiveRecord::Base.connection.execute(
        "UPDATE pg_extension SET extrelocatable = TRUE WHERE extname = '#{extension}';"
      )
      ActiveRecord::Base.connection.execute(
        "ALTER EXTENSION \"#{extension}\" SET SCHEMA shared_extensions;"
      )
    end

    Apartment::Tenant.create('argu')

    excluded_tables = %w[ar_internal_metadata schema_migrations]
    public_tables = Apartment.excluded_models.map { |klass| klass.constantize.table_name.split('.').last }

    migrate_tables(ApplicationRecord.connection.tables - public_tables - excluded_tables)
  end

  def migrate_tables(tables)
    tables.each do |table|
      ApplicationRecord.connection.execute("INSERT INTO argu.#{table} SELECT * FROM public.#{table};")
      Apartment::Tenant.switch('argu') do
        ActiveRecord::Base.connection.reset_pk_sequence!(table)
      end
    end
  end
end
