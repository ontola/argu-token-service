# frozen_string_literal: true
require 'spec_helper'

describe 'Token create' do
  let(:token) { create(:token) }
  let(:email_token) { create(:token, email: 'email1@example.com') }

  ####################################
  # As Guest
  ####################################
  it 'guest should not create valid' do
    current_user_guest_mock
    assert_difference('Token.count', 0) do
      post '/', params: {
        data: {
          type: 'bearerToken',
          attributes: {
            group_id: 1
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
  it 'user should not create valid' do
    current_user_user_mock
    unauthorized_mock('Group', 1, 'update')
    assert_difference('Token.count', 0) do
      post '/', params: {
        data: {
          type: 'bearerToken',
          attributes: {
            group_id: 1
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
  it 'manager should not create without attributes' do
    current_user_user_mock
    assert_difference('Token.count', 0) do
      post '/'

      expect(response.code).to eq('400')
      expect_error_message('param is missing or the value is empty: data')
      expect_error_size(1)
    end
  end

  it 'manager should not create bearer_token with invalid attributes' do
    current_user_user_mock
    unauthorized_mock('Group', '', 'update')
    assert_difference('Token.count', 0) do
      post '/', params: {
        data: {
          type: 'bearerToken',
          attributes: {
            bla: 'blabla'
          }
        }
      }

      expect(response.code).to eq('400')
      expect_error_message('param is missing or the value is empty: group_id')
      expect_error_size(1)
    end
  end

  it 'manager should create valid bearer token' do
    current_user_user_mock
    authorized_mock('Group', 1, 'update')
    assert_difference('Token.count', 1) do
      post '/', params: {
        data: {
          type: 'bearerToken',
          attributes: {
            group_id: 1
          }
        }
      }
    end

    expect(response.code).to eq('201')
    expect(response.headers['location']).to be_truthy
    expect_attributes(%w(email sendMail groupId usages createdAt expiresAt retractedAt opened status))
    expect(Token.last.secret.length).to eq(24)
  end

  it 'manager should create bearer_token with expired_at attribute' do
    current_user_user_mock
    authorized_mock('Group', 1, 'update')
    assert_difference('Token.count', 1) do
      post '/', params: {
        data: {
          type: 'bearerToken',
          attributes: {
            group_id: 1,
            expires_at: 1.day.from_now
          }
        }
      }
    end

    expect(response.code).to eq('201')
    expect(response.headers['location']).to be_truthy
    expect_attributes(%w(email sendMail groupId usages createdAt expiresAt retractedAt opened status))
    expect(Token.last.expires_at).to be_truthy
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
    expect_attributes(%w(email sendMail groupId usages createdAt expiresAt retractedAt opened status), 0)
    expect(Token.last.secret.length).to eq(171)
  end

  it 'manager should create valid email token request without duplicates' do
    email_token
    current_user_user_mock
    authorized_mock('Group', 1, 'update')
    assert_difference('Token.count', 1) do
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
    expect_data_size(1)
    expect_attributes(%w(email sendMail groupId usages createdAt expiresAt retractedAt opened status), 0)
    expect(Token.last.secret.length).to eq(171)
  end
end
