# frozen_string_literal: true
require 'spec_helper'

describe 'Token bearer create' do
  ####################################
  # As Guest
  ####################################
  it 'guest should not create valid bearer token' do
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
  it 'user should not create valid bearer token' do
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
  it 'manager should not create token with wrong type' do
    current_user_user_mock
    unauthorized_mock('Group', '', 'update')
    assert_difference('Token.count', 0) do
      post '/', params: {
        data: {
          type: 'wrongType',
          attributes: {
            group_id: 1
          }
        }
      }

      expect(response.code).to eq('422')
      expect_error_message('found unpermitted parameter: type')
      expect_error_size(1)
    end
  end

  it 'manager should not create without attributes' do
    current_user_user_mock
    assert_difference('Token.count', 0) do
      post '/'

      expect(response.code).to eq('400')
      expect_error_message('param is missing or the value is empty: data')
      expect_error_size(1)
    end
  end

  it 'manager should not create bearer token with invalid attributes' do
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
    expect_token_attributes
    expect(Token.last.secret.length).to eq(24)
  end

  it 'manager should create bearer token with expired_at attribute' do
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
    expect_token_attributes
    expect(Token.last.expires_at).to be_truthy
  end

  private

  def expect_token_attributes(index = nil)
    expect_attributes(
      %w(invitee sendMail groupId usages createdAt expiresAt retractedAt opened status message actorIRI),
      index
    )
  end
end
