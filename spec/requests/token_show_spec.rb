# frozen_string_literal: true
require 'rails_helper'

describe 'Token show' do
  let(:token) { create(:token) }
  let(:retracted_token) { create(:retracted_token) }
  let(:expired_token) { create(:expired_token) }
  let(:used_token) { create(:used_token) }

  ####################################
  # As Guest
  ####################################
  it 'guest should not show an non-existent token' do
    current_user_guest_mock
    get '/invalid_token', as: :html

    expect(response.body).to include('404')
    expect(response.code).to eq('404')
    expect(response.body).not_to include('MissingFile')
  end

  it 'guest should not show a retracted token' do
    current_user_guest_mock
    get "/#{retracted_token.secret}"

    expect(response.body).to include('403')
    expect(response.body).to include('The requested token has expired or has been retracted')
    expect(response.code).to eq('403')
    expect(response.body).not_to include('MissingFile')
  end

  it 'guest should not show an expired token' do
    current_user_guest_mock
    get "/#{expired_token.secret}"

    expect(response.body).to include('403')
    expect(response.body).to include('The requested token has expired or has been retracted')
    expect(response.code).to eq('403')
    expect(response.body).not_to include('MissingFile')
  end

  it 'guest should not show a used token' do
    current_user_guest_mock
    get "/#{used_token.secret}"

    expect(response.body).to include('403')
    expect(response.code).to eq('403')
    expect(response.body).not_to include('MissingFile')
  end

  it 'guest should redirect to login page' do
    current_user_guest_mock
    get "/#{token.secret}"

    expect(response.code).to eq('302')
    expect(response).to redirect_to "#{Rails.application.config.host_name}/users/sign_in?r=%2F#{token.secret}"
  end

  ####################################
  # As User
  ####################################
  it 'user should redirect to welcome page' do
    current_user_user_mock(1)
    create_membership_mock(user_id: 1, group_id: 1, secret: token.secret)
    get "/#{token.secret}"

    expect(token.reload.usages).to eq(1)

    expect(response.code).to eq('302')
    expect(response).to redirect_to "#{Rails.application.config.host_name}/g/#{token.group_id}?welcome=true"
  end

  it 'user should 403 when failed to create membership' do
    current_user_user_mock(1)
    create_membership_mock(user_id: 1, group_id: 1, secret: token.secret, response: 403)
    get "/#{token.secret}"

    expect(response.code).to eq('403')
    expect(response.body).to include('403')
    expect(response.body).not_to include('MissingFile')
  end

  ####################################
  # As Member
  ####################################
  it 'member should redirect to page' do
    current_user_user_mock(1)
    create_membership_mock(user_id: 1, group_id: 1, secret: token.secret, response: 304)
    get "/#{token.secret}"

    expect(token.reload.usages).to eq(0)

    expect(response.code).to eq('302')
    expect(response).to redirect_to "#{Rails.application.config.host_name}/g/#{token.group_id}"
  end
end
