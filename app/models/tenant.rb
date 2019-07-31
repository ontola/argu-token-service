# frozen_string_literal: true

class Tenant
  def self.create(schema)
    Apartment::Tenant.create(schema)
  end
end
