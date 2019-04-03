# frozen_string_literal: true

class BearerTokenForm < ApplicationForm
  include RegexHelper

  fields [
    {
      redirect_url: {
        default_value: ->(r) { RDF::DynamicURI(r.form.target.group.organization.iri).to_s }
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
          default_value: ->(r) { r.form.target.group.organization.uuid }
        }
      }
    ]
  )
end
