# frozen_string_literal: true

class BearerTokenForm < ApplicationForm
  include RegexHelper

  fields [
    {
      redirect_url: {
        default_value: -> { "https://#{ActsAsTenant.current_tenant.iri_prefix}" }
      }
    },
    :hidden
  ]

  property_group(
    :hidden,
    iri: NS::ONTOLA[:hiddenGroup],
    properties: [
      {
        root_id: {
          default_value: -> { target.group.organization.uuid }
        }
      }
    ]
  )
end
