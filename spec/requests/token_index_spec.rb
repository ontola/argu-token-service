# frozen_string_literal: true
require 'spec_helper'

describe 'Token index' do
  let(:token) { create(:token) }

  ####################################
  # As Guest
  ####################################
  it 'guest should not get index' do
    current_user_guest_mock
    get "/bearer/g/#{token.group_id}"

    expect(response.code).to eq('401')
    expect_error_message('Please sign in to continue')
    expect_error_size(1)
  end

  ####################################
  # As User
  ####################################
  it 'user should not get index' do
    current_user_user_mock
    unauthorized_mock('Group', 1, 'update')
    get "/bearer/g/#{token.group_id}"

    expect(response.code).to eq('403')
    expect_error_message('You are not authorized for this action')
    expect_error_size(1)
  end

  ####################################
  # As Manager
  ####################################
  it 'manager should get index' do
    current_user_user_mock
    authorized_mock('Group', 1, 'update')
    get "/bearer/g/#{token.group_id}"

    expect(response.code).to eq('200')
    expect_data_size(1)
    expect_attributes(%w(usages createdAt expiresAt retractedAt), 0)
  end
end
