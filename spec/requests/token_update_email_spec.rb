# frozen_string_literal: true
require 'spec_helper'

describe 'Token email update' do
  let(:token) { create(:token, email: 'email1@example.com') }

  ####################################
  # As Guest
  ####################################
  it 'guest should not put update email token' do
    current_user_guest_mock
    put token_path(token), params: {
      data: {
        id: token.context_id,
        type: 'tokens',
        attributes: {
          redirect_url: 'https://example.com'
        }
      }
    }
    expect(response.code).to eq('401')
    expect_error_message('Please sign in to continue')
    expect_error_size(1)
    expect(token.reload.redirect_url).to be_nil
  end

  ####################################
  # As User
  ####################################
  it 'user should not put update email token' do
    current_user_user_mock
    unauthorized_mock('Group', 1, 'update')
    put token_path(token), params: {
      data: {
        id: token.context_id,
        type: 'tokens',
        attributes: {
          redirect_url: 'https://example.com'
        }
      }
    }

    expect(response.code).to eq('403')
    expect_error_message('You are not authorized for this action')
    expect_error_size(1)
  end

  ####################################
  # As Manager
  ####################################
  it 'manager should put update email token' do
    current_user_user_mock
    emails_mock('tokens', token.id)
    authorized_mock('Group', 1, 'update')
    put token_path(token), params: {
      data: {
        id: token.context_id,
        type: 'tokens',
        attributes: {
          redirect_url: 'https://example.com'
        }
      }
    }
    expect(response.code).to eq('200')
    expect(token.reload.redirect_url).to eq('https://example.com')
  end
end
