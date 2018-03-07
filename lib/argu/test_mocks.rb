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

  def current_user_user_mock(id = 1, email: nil, confirmed: true, secondary_emails: [])
    url = argu_url('/spi/current_user')
    user_mock(id, email: email, confirmed: confirmed, secondary_emails: secondary_emails, url: url)
  end

  def guest_without_account_mock(email)
    current_user_guest_mock
    stub_request(:post, argu_url('/users'))
      .to_return(
        status: 201,
        body: {
          data: user_data(1, email)
        }.to_json
      )
  end

  def guest_with_account_mock
    current_user_guest_mock
    stub_request(:post, argu_url('/users'))
      .to_return(
        status: 422,
        body: {
          code: 'VALUE_TAKEN',
          message: 'Email has already been taken',
          notifications: [
            {
              type: 'error',
              message: 'Email has already been taken'
            }
          ]
        }.to_json
      )
  end

  def user_mock(id = 1, email: nil, confirmed: true, secondary_emails: [], url: nil)
    url ||= argu_url("/u/#{id}")
    email ||= "user#{id}@email.com"
    stub_request(:get, url)
      .to_return(
        status: 200,
        headers: {'Content-Type' => 'application/json'},
        body: {
          data: user_data(id, email, secondary_emails),
          included: [email: email, confirmed: confirmed]
                      .concat(secondary_emails)
                      .each_with_index
                      .map do |e, i|
                      {
                        id: "https://argu.dev/u/#{id}/email/#{i}",
                        type: 'emailAddresses',
                        attributes: {
                          '@type' => 'argu:Email',
                          email: e[:email],
                          primary: i.zero?,
                          confirmedAt: e[:confirmed] ? Time.current : nil
                        }
                      }
                    end
        }.to_json
      )
  end

  def create_membership_mock(opts = {})
    stub_request(:post, argu_url("/g/#{opts[:group_id]}/memberships"))
      .with(
        body: {
          token: opts[:secret]
        }
      )
      .to_return(
        status: opts[:response] || 201,
        headers: {location: argu_url('/group_memberships/1')},
        body: {
          data: {
            id: 1,
            type: 'group_memberships',
            attributes: {
            },
            relationships: {
              group: {
                data: {
                  id: 1,
                  type: 'groups'
                }
              }
            }
          },
          included: [
            {
              id: 1,
              type: 'groups',
              attributes: {
                display_name: 'group_name'
              }
            }
          ]
        }.to_json
      )
  end

  def create_favorite_mock(opts = {})
    stub_request(:post, argu_url('/favorites'))
      .with(body: {iri: opts[:iri]})
      .to_return(status: opts[:status] || 201)
  end

  def emails_mock(type, id, event = 'create')
    stub_request(
      :get,
      argu_url('/email/emails', event: event, resource_id: id, resource_type: type)
    ).to_return(status: 200, body: [].to_json)
  end

  def confirm_email_mock(email)
    stub_request(:put, argu_url('/users/confirm'))
      .with(body: {email: email}, headers: {'Accept' => 'application/json'})
      .to_return(status: 200)
  end

  def authorized_mock(type: nil, id: nil, iri: nil, action: nil)
    params = {
      authorize_action: action,
      resource_id: id,
      resource_iri: iri,
      resource_type: type
    }.delete_if { |_k, v| v.nil? }
    stub_request(:get, argu_url('/spi/authorize', params)).to_return(status: 200)
  end

  def unauthorized_mock(type: nil, id: nil, iri: nil, action: nil)
    params = {
      authorize_action: action,
      resource_id: id,
      resource_iri: iri,
      resource_type: type
    }.delete_if { |_k, v| v.nil? }
    stub_request(:get, argu_url('/spi/authorize', params)).to_return(status: 403)
  end

  private

  def host_name
    Rails.application.config.host_name
  end

  def user_data(id, email, secondary_emails = [])
    {
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
        email: email
      },
      relationships: {
        profilePhoto: {
          data: {
            id: '1',
            type: 'photos'
          },
          links: {
            self: {
              meta: {'@type': 'http://schema.org/image'}
            },
            related: {
              href: 'https://argu.dev/photos/1',
              meta: {'@type': 'http://schema.org/ImageObject'}
            }
          }
        },
        email_addresses: {
          data: Array.new((secondary_emails.count + 1)) do |i|
            {id: "https://argu.dev/u/#{id}/email/#{i}", type: 'emailAddresses'}
          end
        }
      },
      links: {
        self: "https://argu.dev/u/#{id}"
      }
    }
  end
end
