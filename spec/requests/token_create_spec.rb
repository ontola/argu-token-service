# frozen_string_literal: true
require 'spec_helper'

describe 'Token create' do
  let(:token) { create(:token) }

  ####################################
  # As Guest
  ####################################
  it 'guest should not create valid' do
    current_user_guest_mock
    assert_difference('Token.count', 0) do
      post '/', params: {
        data: {
          type: 'bearer_token',
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
          type: 'bearer_token',
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

  it 'manager should not create with invalid attributes' do
    current_user_user_mock
    unauthorized_mock('Group', '', 'update')
    assert_difference('Token.count', 0) do
      post '/', params: {
        data: {
          type: 'bearer_token',
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

  it 'manager should create valid' do
    current_user_user_mock
    authorized_mock('Group', 1, 'update')
    assert_difference('Token.count', 1) do
      post '/', params: {
        data: {
          type: 'bearer_token',
          attributes: {
            group_id: 1
          }
        }
      }
    end

    expect(response.code).to eq('201')
    expect(response.headers['location']).to be_truthy
    expect_data_keys(%w(id type attributes links))
    expect_data_attributes_keys(%w(usages createdAt expiresAt retractedAt))
  end

  it 'manager should create with expired_at attribute' do
    current_user_user_mock
    authorized_mock('Group', 1, 'update')
    assert_difference('Token.count', 1) do
      post '/', params: {
        data: {
          type: 'bearer_token',
          attributes: {
            group_id: 1,
            expires_at: 1.day.from_now
          }
        }
      }
    end

    expect(response.code).to eq('201')
    expect(response.headers['location']).to be_truthy
    expect_data_keys(%w(id type attributes links))
    expect_data_attributes_keys(%w(usages createdAt expiresAt retractedAt))
    expect(Token.last.expires_at).to be_truthy
  end
end
