# frozen_string_literal: true

class Tenant
  def self.create(schema)
    Apartment::Tenant.create(schema) unless ApplicationRecord.connection.schema_exists?(schema)
  end
end
