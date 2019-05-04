# frozen_string_literal: true

require 'spec_helper'

describe 'Email conflict show' do
  let(:token) { create(:token, email: 'other@example.com') }

  before do
    group_mock(1)
  end

  ####################################
  # As Guest
  ####################################
  it 'guest should show email conflict' do
    as_guest
    get "/argu/tokens/#{token.secret}/email_conflict", headers: service_headers(accept: :n3)

    expect(response.code).to eq('401')
  end

  ####################################
  # As Other User
  ####################################
  it 'other user should show email conflict' do
    email_check_mock('other@example.com', false)
    as_user(1)
    get "/argu/tokens/#{token.secret}/email_conflict", headers: service_headers(accept: :n3)

    expect(response.code).to eq('200')
  end

  ####################################
  # As User With Other Email
  ####################################
  it 'user with other email should show email conflict' do
    email_check_mock('other@example.com', true)
    as_user(1)
    get "/argu/tokens/#{token.secret}/email_conflict", headers: service_headers(accept: :n3)

    expect(response.code).to eq('200')
  end
end
