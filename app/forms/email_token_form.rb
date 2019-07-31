# frozen_string_literal: true

class EmailTokenForm < ApplicationForm
  include RegexHelper

  fields [
    {addresses: {max_length: 5000, pattern: /\A(#{RegexHelper::SINGLE_EMAIL.source},?\s?)+\z/}},
    {
      message: {
        default_value: lambda do
          I18n.t(
            'email_tokens.form.message.default_message',
            group: target.group.display_name
          )
        end,
        max_length: 5000
      }
    },
    {
      redirect_url: {
        default_value: -> { "https://#{ActsAsTenant.current_tenant.iri_prefix}" }
      }
    },
    :hidden,
    :footer
  ]

  property_group(
    :hidden,
    iri: NS::ONTOLA[:hiddenGroup],
    properties: [
      {send_mail: {default_value: true}},
      {
        root_id: {
          default_value: -> { target.group.organization.uuid }
        }
      }
    ]
  )

  property_group(
    :footer,
    iri: NS::ONTOLA[:footerGroup],
    properties: [
      creator: actor_selector
    ]
  )
end
