# frozen_string_literal: true
require 'rails_helper'

describe 'Token retract' do
  let(:token) { create(:token) }

  ####################################
  # As Guest
  ####################################
  it 'guest should not retract valid' do
    current_user_guest_mock
    token
    assert_difference('Token.count', 0) do
      delete "/#{token.secret}"
    end

    expect(response.code).to eq('401')
    expect_error_message('Please sign in to continue')
    expect_error_size(1)
  end

  ####################################
  # As User
  ####################################
  it 'user should not retract valid' do
    current_user_user_mock
    unauthorized_mock('Group', 1, 'update')
    token
    assert_difference('Token.count', 0) do
      delete "/#{token.secret}"
    end

    expect(response.code).to eq('403')
    expect_error_message('You are not authorized for this action')
    expect_error_size(1)
  end

  ####################################
  # As Manager
  ####################################
  it 'manager should not retract invalid token' do
    current_user_user_mock
    delete '/invalid_webhook'

    expect(response.code).to eq('404')

    expect_error_message('Please provide a valid token')
    expect_error_size(1)
  end

  it 'manager should retract valid' do
    current_user_user_mock
    authorized_mock('Group', 1, 'update')
    token
    assert_difference('Token.active.count', -1) do
      delete "/#{token.secret}"

      expect(response.code).to eq('200')
      expect(token.reload.retracted_at).to be_truthy
    end
  end
end
