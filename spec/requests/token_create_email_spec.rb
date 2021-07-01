# frozen_string_literal: true

require 'spec_helper'

describe 'Token email create' do
  let(:token) { create(:token, email: 'email1@example.com') }
  let(:retracted_token) { create(:retracted_token, email: 'retracted@example.com') }
  let(:expired_token) { create(:expired_token, email: 'expired@example.com') }

  before do
    group_mock(1)
  end

  ####################################
  # As Guest
  ####################################
  it 'guest should not get new email token' do
    as_guest
    get '/argu/tokens/g/1/email/new', headers: service_headers(accept: :nq)

    assert_disabled_form(error: nil)
  end

  it 'guest should not create valid email token' do
    as_guest
    assert_difference('Token.count', 0) do
      post '/argu/tokens/g/1/email', params: {
        email_token: {
          addresses: ['email1@example.com', 'email2@example.com']
        }
      }, headers: service_headers(accept: :nq)
    end

    expect(response.code).to eq('401')
  end

  ####################################
  # As User
  ####################################
  it 'user should not get new email token' do
    as_user
    unauthorized_mock(type: 'Group', id: 1, action: 'update')
    get '/argu/tokens/g/1/email/new', headers: service_headers(accept: :nq)

    assert_disabled_form(error: nil)
  end

  it 'user should not create valid email token' do
    as_user
    unauthorized_mock(type: 'Group', id: 1, action: 'update')
    assert_difference('Token.count', 0) do
      post '/argu/tokens/g/1/email', params: {
        email_token: {
          addresses: ['email1@example.com', 'email2@example.com']
        }
      }, headers: service_headers(accept: :nq)
    end

    expect(response.code).to eq('403')
    expect_ontola_action(snackbar: "You're not authorized for this action. (create)")
  end

  ####################################
  # As Manager
  ####################################
  it 'manager should not get new email token' do
    as_user
    authorized_mock(type: 'Group', action: 'update')
    authorized_mock(type: 'Group', id: 1, action: 'update')
    authorized_mock(type: 'CurrentActor', id: "http://#{ENV['HOSTNAME']}/u/1", action: 'show')
    get '/argu/tokens/g/1/email/new', headers: service_headers(accept: :n3)

    assert_enabled_form
  end

  it 'manager should not create email token request with missing param' do
    as_user
    authorized_mock(type: 'Group', id: 1, action: 'update')
    assert_difference('Token.count', 0) do
      post '/argu/tokens/g/1/email', params: {
        email_token: {}
      }, headers: service_headers(accept: :nq)

      expect(response.code).to eq('422')
      expect_ontola_action(snackbar: 'param is missing or the value is empty: email_token')
    end
  end

  it 'manager should not create bearer token for group_id < 0' do
    as_user
    authorized_mock(type: 'Group', id: -1, action: 'update')
    assert_difference('Token.count', 0) do
      post '/argu/tokens/g/-1/email', params: {
        email_token: {
          addresses: ['email1@example.com', 'email2@example.com']
        }
      }, headers: service_headers(accept: :nq)
    end

    expect(response.code).to eq('422')
  end

  it 'manager should create valid email token request with missing send_mail' do
    as_user
    authorized_mock(type: 'Group', id: 1, action: 'update')
    assert_difference('Token.count', 2) do
      post '/argu/tokens/g/1/email', params: {
        email_token: {
          addresses: ['email1@example.com', 'email2@example.com']
        }
      }, headers: service_headers(accept: :nq)
    end

    expect(response.code).to eq('201')
    expect(Token.last.send_mail).to be_falsey
  end

  it 'manager should create valid email token request' do
    as_user
    authorized_mock(type: 'Group', id: 1, action: 'update')
    assert_difference('Token.count', 2) do
      post '/argu/tokens/g/1/email', params: {
        email_token: {
          addresses: ['email1@example.com', 'email2@example.com'],
          send_mail: true
        }
      }, headers: service_headers(accept: :nq)
    end

    expect(response.code).to eq('201')
    expect(Token.last.secret.length).to eq(171)
  end

  it 'manager should create valid email token request with shortnames without duplicates' do
    as_user
    user_mock('user2', email: 'user2@example.com', token: ENV['SERVICE_TOKEN'])
    user_mock('user3', email: 'user3@example.com', token: ENV['SERVICE_TOKEN'])
    authorized_mock(type: 'Group', id: 1, action: 'update')
    assert_difference('Token.count', 3) do
      post '/argu/tokens/g/1/email', params: {
        email_token: {
          addresses: ['user1@example.com', 'user2', 'user3', 'user3@example.com'],
          send_mail: true
        }
      }, headers: service_headers(accept: :nq)
    end

    expect(response.code).to eq('201')
    expect(Token.last.secret.length).to eq(171)
    expect(Token.last.invitee).to eq('user3')
    expect(Token.last.email).to eq('user3@example.com')
  end

  it 'manager should create email token request with expired_at attribute' do
    as_user
    authorized_mock(type: 'Group', id: 1, action: 'update')
    assert_difference('Token.count', 2) do
      post '/argu/tokens/g/1/email', params: {
        email_token: {
          addresses: ['email1@example.com', 'email2@example.com'],
          expires_at: 1.day.from_now,
          send_mail: true
        }
      }, headers: service_headers(accept: :nq)
    end

    expect(response.code).to eq('201')
    expect(Token.last.expires_at).to be_truthy
  end

  it 'manager should create email token request with redirect_url' do
    as_user
    authorized_mock(type: 'Group', id: 1, action: 'update')
    assert_difference('Token.count', 2) do
      post '/argu/tokens/g/1/email', params: {
        email_token: {
          addresses: ['email1@example.com', 'email2@example.com'],
          redirect_url: 'https://example.com',
          send_mail: true
        }
      }, headers: service_headers(accept: :nq)
    end

    expect(response.code).to eq('201')
    expect(Token.last.redirect_url).to eq('https://example.com')
  end

  it 'manager should create valid email token request with send_mail false' do
    as_user
    authorized_mock(type: 'Group', id: 1, action: 'update')
    assert_difference('Token.count', 2) do
      post '/argu/tokens/g/1/email', params: {
        email_token: {
          addresses: ['email1@example.com', 'email2@example.com'],
          send_mail: false
        }
      }, headers: service_headers(accept: :nq)
    end

    expect(response.code).to eq('201')
    expect(Token.last.send_mail).to be_falsey
  end

  it 'manager should create valid email token request with message' do
    as_user
    authorized_mock(type: 'Group', id: 1, action: 'update')
    assert_difference('Token.count', 2) do
      post '/argu/tokens/g/1/email', params: {
        email_token: {
          addresses: ['email1@example.com', 'email2@example.com'],
          message: 'Hello world.',
          send_mail: true
        }
      }, headers: service_headers(accept: :nq)
    end

    expect(response.code).to eq('201')
    expect(Token.last.message).to eq('Hello world.')
  end

  it 'manager should create valid email token request with valid actor_iri' do
    as_user
    authorized_mock(type: 'Group', id: 1, action: 'update')
    authorized_mock(type: 'CurrentActor', id: 'https://argu.dev/u/1', action: 'show')
    assert_difference('Token.count', 2) do
      post '/argu/tokens/g/1/email', params: {
        email_token: {
          addresses: ['email1@example.com', 'email2@example.com'],
          actor_iri: 'https://argu.dev/u/1',
          send_mail: true
        }
      }, headers: service_headers(accept: :nq)
    end

    expect(response.code).to eq('201')
    expect(Token.last.actor_iri).to eq('https://argu.dev/u/1')
  end

  it 'manager should not create valid email token request with invalid actor_iri' do
    as_user
    authorized_mock(type: 'Group', id: 1, action: 'update')
    unauthorized_mock(type: 'CurrentActor', id: 'https://argu.dev/u/1', action: 'show')
    assert_difference('Token.count', 0) do
      post '/argu/tokens/g/1/email', params: {
        email_token: {
          addresses: ['email1@example.com', 'email2@example.com'],
          actor_iri: 'https://argu.dev/u/1',
          send_mail: true
        }
      }, headers: service_headers(accept: :nq)
    end

    expect(response.code).to eq('403')
    expect_ontola_action(snackbar: "You're not authorized for this action. (create)")
  end

  it 'manager should create valid email token request without duplicates' do
    token
    as_user
    authorized_mock(type: 'Group', id: 1, action: 'update')
    assert_difference('Token.count', 1) do
      post '/argu/tokens/g/1/email', params: {
        email_token: {
          addresses: ['email1@example.com', 'email2@example.com', 'email2@example.com'],
          send_mail: true
        }
      }, headers: service_headers(accept: :nq)
    end

    expect(response.code).to eq('201')
    expect(Token.last.secret.length).to eq(171)
  end

  it 'manager should duplicate retracted and expired tokens' do
    retracted_token
    expired_token
    as_user
    authorized_mock(type: 'Group', id: 1, action: 'update')
    assert_difference('Token.count', 2) do
      post '/argu/tokens/g/1/email', params: {
        email_token: {
          addresses: ['retracted@example.com', 'expired@example.com'],
          send_mail: true
        }
      }, headers: service_headers(accept: :nq)
    end

    expect(response.code).to eq('201')
    expect(Token.last.secret.length).to eq(171)
  end

  it 'manager should duplicate with different redirect_url' do
    token
    as_user
    authorized_mock(type: 'Group', id: 1, action: 'update')
    assert_difference('Token.count', 1) do
      post '/argu/tokens/g/1/email', params: {
        email_token: {
          addresses: [token.email],
          redirect_url: 'https://example.com',
          send_mail: true
        }
      }, headers: service_headers(accept: :nq)
    end

    expect(response.code).to eq('201')
    expect(Token.last.secret.length).to eq(171)
  end

  it 'manager should create email tokens on root collection' do
    as_user
    authorized_mock(type: 'Group', id: 1, action: 'update')
    assert_difference('Token.count', 1) do
      post '/argu/tokens/email', params: {
        email_token: {
          addresses: ['email1@example.com'],
          group_id: LinkedRails.iri(path: 'argu/g/1'),
          send_mail: true
        }
      }, headers: service_headers(accept: :nq)
    end

    expect(response.code).to eq('201')
    expect(Token.last.group_id).to eq(1)
    expect(Token.last.secret.length).to eq(171)
  end

  it 'manager should not create email tokens on root collection without group_id' do
    as_user
    authorized_mock(type: 'Group', id: 1, action: 'update')
    assert_difference('Token.count', 0) do
      post '/argu/tokens/email', params: {
        email_token: {
          addresses: ['email1@example.com'],
          send_mail: true
        }
      }, headers: service_headers(accept: :nq)
    end

    expect(response.code).to eq('422')
  end
end
