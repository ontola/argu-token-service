# frozen_string_literal: true
module TestMocks
  include UrlHelper

  def current_user_guest_mock
    stub_request(:get, argu_url('/spi/current_user'))
      .to_return(
        status: 401,
        headers: {'Content-Type' => 'application/json'}
      )
  end

  def current_user_user_mock(id = 1, email: nil, secondary_emails: [])
    stub_request(:get, argu_url('/spi/current_user'))
      .to_return(
        status: 200,
        headers: {'Content-Type' => 'application/json'},
        body: {
          data: {
            id: id,
            type: 'users',
            attributes: {
              '@context': {
                schema: 'http://schema.org/',
                hydra: 'http://www.w3.org/ns/hydra/core#',
                argu: 'https://argu.co/ns/core#',
                createdAt: 'http://schema.org/dateCreated',
                updatedAt: 'http://schema.org/dateModified',
                displayName: 'schema:name',
                about: 'schema:description',
                '@vocab': 'http://schema.org/'
              },
              '@type': 'schema:Person',
              potentialAction: nil,
              displayName: "User#{id}",
              about: '',
              url: "user#{id}",
              email: email || "user#{id}@email.com",
              secondary_emails: secondary_emails
            },
            relationships: {
              profilePhoto: {
                data: {
                  id: '2407',
                  type: 'photos'
                },
                links: {
                  self: {
                    meta: {'@type': 'http://schema.org/image'}
                  },
                  related: {
                    href: 'https://argu.local/photos/2407',
                    meta: {'@type': 'http://schema.org/ImageObject'}
                  }
                }
              }
            },
            links: {
              self: 'https://argu.local/u/95'
            }
          }
        }.to_json
      )
  end

  def create_membership_mock(opts = {})
    stub_request(:post, argu_url("/g/#{opts[:group_id]}/memberships"))
      .with(
        body: {
          shortname: "user#{opts[:user_id]}",
          token: opts[:secret]
        }
      ).to_return(status: opts[:response] || 201, body: '')
  end

  def emails_mock(type, id, event = 'create')
    stub_request(
      :get,
      argu_url('/email/emails', event: event, resource_id: id, resource_type: type)
    ).to_return(status: 200, body: [].to_json)
  end

  def authorized_mock(type, id, action)
    stub_request(
      :get,
      argu_url('/spi/authorize', authorize_action: action, resource_id: id, resource_type: type)
    ).to_return(status: 200)
  end

  def unauthorized_mock(type, id, action)
    url = if id.present?
            argu_url('/spi/authorize', authorize_action: action, resource_id: id, resource_type: type)
          else
            argu_url('/spi/authorize', authorize_action: action, resource_type: type)
          end
    stub_request(:get, url).to_return(status: 403)
  end

  private

  def host_name
    Rails.application.config.host_name
  end
end
