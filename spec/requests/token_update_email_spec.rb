# frozen_string_literal: true

require 'spec_helper'

describe 'Token email update' do
  let(:token) { create(:token, email: 'email1@example.com') }

  before do
    group_mock(1)
  end

  ####################################
  # As Guest
  ####################################
  it 'guest should not put update email token' do
    as_guest
    put "/argu#{token_path(token)}", params: {
      data: {
        id: resource_iri(token),
        type: 'token',
        attributes: {
          redirect_url: 'https://example.com'
        }
      }
    }, headers: service_headers(accept: :json_api)
    expect(response.code).to eq('401')
    expect_error_message('Please sign in to continue')
    expect_error_size(1)
    expect(token.reload.redirect_url).to be_nil
  end

  ####################################
  # As User
  ####################################
  it 'user should not put update email token' do
    as_user
    unauthorized_mock(type: 'Group', id: 1, action: 'update')
    put "/argu#{token_path(token)}", params: {
      data: {
        id: resource_iri(token),
        type: 'token',
        attributes: {
          redirect_url: 'https://example.com'
        }
      }
    }, headers: service_headers(accept: :json_api)

    expect(response.code).to eq('403')
    expect_error_message("You're not authorized for this action. (update)")
    expect_error_size(1)
  end

  ####################################
  # As Manager
  ####################################
  it 'manager should put update email token' do
    as_user
    emails_mock('tokens', token.id)
    authorized_mock(type: 'Group', id: 1, action: 'update')
    put "/argu#{token_path(token)}", params: {
      token: {redirect_url: 'https://example.com'}
    }, headers: service_headers(accept: :nq)
    expect(response.code).to eq('200')
    expect(token.reload.redirect_url).to eq('https://example.com')
  end
end
