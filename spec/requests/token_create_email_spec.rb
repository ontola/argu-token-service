# frozen_string_literal: true
require 'spec_helper'

describe 'Token email create' do
  let(:token) { create(:token, email: 'email1@example.com') }
  let(:retracted_token) { create(:retracted_token, email: 'retracted@example.com') }
  let(:expired_token) { create(:expired_token, email: 'expired@example.com') }

  ####################################
  # As Guest
  ####################################
  it 'guest should not create valid email token' do
    current_user_guest_mock
    assert_difference('Token.count', 0) do
      post '/', params: {
        data: {
          type: 'emailTokenRequest',
          attributes: {
            group_id: 1,
            addresses: ['email1@example.com', 'email2@example.com']
          }
        }
      }
    end

    expect(response.code).to eq('401')
    expect_error_message('Please sign in to continue')
    expect_error_size(1)
  end

  ####################################
  # As User
  ####################################
  it 'user should not create valid email token' do
    current_user_user_mock
    unauthorized_mock('Group', 1, 'update')
    assert_difference('Token.count', 0) do
      post '/', params: {
        data: {
          type: 'emailTokenRequest',
          attributes: {
            group_id: 1,
            addresses: ['email1@example.com', 'email2@example.com']
          }
        }
      }
    end

    expect(response.code).to eq('403')
    expect_error_message('You are not authorized for this action')
    expect_error_size(1)
  end

  ####################################
  # As Manager
  ####################################
  it 'manager should not create email token request with invalid attributes' do
    current_user_user_mock
    unauthorized_mock('Group', '', 'update')
    assert_difference('Token.count', 0) do
      post '/', params: {
        data: {
          type: 'emailTokenRequest',
          attributes: {
            addresses: ['email1@example.com', 'email2@example.com'],
            bla: 'blabla'
          }
        }
      }

      expect(response.code).to eq('400')
      expect_error_message('param is missing or the value is empty: group_id')
      expect_error_size(1)
    end
  end

  it 'manager should create valid email token request with missing send_mail' do
    current_user_user_mock
    authorized_mock('Group', 1, 'update')
    assert_difference('Token.count', 0) do
      post '/', params: {
        data: {
          type: 'emailTokenRequest',
          attributes: {
            group_id: 1,
            addresses: ['email1@example.com', 'email2@example.com']
          }
        }
      }
    end

    expect(response.code).to eq('400')
    expect_error_message('param is missing or the value is empty: send_mail')
    expect_error_size(1)
  end

  it 'manager should create valid email token request' do
    current_user_user_mock
    authorized_mock('Group', 1, 'update')
    assert_difference('Token.count', 2) do
      post '/', params: {
        data: {
          type: 'emailTokenRequest',
          attributes: {
            group_id: 1,
            addresses: ['email1@example.com', 'email2@example.com'],
            send_mail: true
          }
        }
      }
    end

    expect(response.code).to eq('201')
    expect(response.headers['location']).to be_nil
    expect_data_size(2)
    expect_token_attributes
    expect(Token.last.secret.length).to eq(171)
  end

  it 'manager should create email token request with expired_at attribute' do
    current_user_user_mock
    authorized_mock('Group', 1, 'update')
    assert_difference('Token.count', 2) do
      post '/', params: {
        data: {
          type: 'emailTokenRequest',
          attributes: {
            group_id: 1,
            addresses: ['email1@example.com', 'email2@example.com'],
            expires_at: 1.day.from_now,
            send_mail: true
          }
        }
      }
    end

    expect(response.code).to eq('201')
    expect(response.headers['location']).to be_nil
    expect_token_attributes
    expect(Token.last.expires_at).to be_truthy
  end

  it 'manager should create valid email token request with send_mail false' do
    current_user_user_mock
    authorized_mock('Group', 1, 'update')
    assert_difference('Token.count', 2) do
      post '/', params: {
        data: {
          type: 'emailTokenRequest',
          attributes: {
            group_id: 1,
            addresses: ['email1@example.com', 'email2@example.com'],
            send_mail: false
          }
        }
      }
    end

    expect(response.code).to eq('201')
    expect(response.headers['location']).to be_nil
    expect_data_size(2)
    expect_token_attributes
    expect(Token.last.send_mail).to be_falsey
  end

  it 'manager should create valid email token request with message' do
    current_user_user_mock
    authorized_mock('Group', 1, 'update')
    assert_difference('Token.count', 2) do
      post '/', params: {
        data: {
          type: 'emailTokenRequest',
          attributes: {
            group_id: 1,
            addresses: ['email1@example.com', 'email2@example.com'],
            message: 'Hello world.',
            send_mail: true
          }
        }
      }
    end

    expect(response.code).to eq('201')
    expect(response.headers['location']).to be_nil
    expect_data_size(2)
    expect_token_attributes
    expect(Token.last.message).to eq('Hello world.')
  end

  it 'manager should create valid email token request with valid actor_iri' do
    current_user_user_mock
    authorized_mock('Group', 1, 'update')
    authorized_mock('CurrentActor', 'https://argu.dev/u/1', 'show')
    assert_difference('Token.count', 2) do
      post '/', params: {
        data: {
          type: 'emailTokenRequest',
          attributes: {
            group_id: 1,
            addresses: ['email1@example.com', 'email2@example.com'],
            actor_iri: 'https://argu.dev/u/1',
            send_mail: true
          }
        }
      }
    end

    expect(response.code).to eq('201')
    expect(response.headers['location']).to be_nil
    expect_data_size(2)
    expect_token_attributes
    expect(Token.last.actor_iri).to eq('https://argu.dev/u/1')
  end

  it 'manager should not create valid email token request with invalid actor_iri' do
    current_user_user_mock
    authorized_mock('Group', 1, 'update')
    unauthorized_mock('CurrentActor', 'https://argu.dev/u/1', 'show')
    assert_difference('Token.count', 0) do
      post '/', params: {
        data: {
          type: 'emailTokenRequest',
          attributes: {
            group_id: 1,
            addresses: ['email1@example.com', 'email2@example.com'],
            actor_iri: 'https://argu.dev/u/1',
            send_mail: true
          }
        }
      }
    end

    expect(response.code).to eq('403')
    expect_error_message('You are not authorized for this action')
    expect_error_size(1)
  end

  it 'manager should create valid email token request without duplicates' do
    token
    current_user_user_mock
    authorized_mock('Group', 1, 'update')
    assert_difference('Token.count', 1) do
      post '/', params: {
        data: {
          type: 'emailTokenRequest',
          attributes: {
            group_id: 1,
            addresses: ['email1@example.com', 'email2@example.com', 'email2@example.com'],
            send_mail: true
          }
        }
      }
    end

    expect(response.code).to eq('201')
    expect(response.headers['location']).to be_nil
    expect_data_size(1)
    expect_token_attributes
    expect(Token.last.secret.length).to eq(171)
  end

  it 'manager should duplicate retracted and expired tokens' do
    retracted_token
    expired_token
    current_user_user_mock
    authorized_mock('Group', 1, 'update')
    assert_difference('Token.count', 2) do
      post '/', params: {
        data: {
          type: 'emailTokenRequest',
          attributes: {
            group_id: 1,
            addresses: ['retracted@example.com', 'expired@example.com'],
            send_mail: true
          }
        }
      }
    end

    expect(response.code).to eq('201')
    expect(response.headers['location']).to be_nil
    expect_data_size(2)
    expect_token_attributes
    expect(Token.last.secret.length).to eq(171)
  end

  private

  def expect_token_attributes(index = 0)
    expect_attributes(
      %w(invitee sendMail groupId usages createdAt expiresAt retractedAt opened status message actorIRI),
      index
    )
  end
end
