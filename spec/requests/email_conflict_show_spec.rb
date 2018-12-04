# frozen_string_literal: true

require 'spec_helper'

describe 'Email conflict show' do
  let(:token) { create(:token, email: 'other@example.com') }

  ####################################
  # As Guest
  ####################################
  it 'guest should show email conflict' do
    as_guest
    get "/#{token.secret}/email_conflict", headers: service_headers(accept: :n3)

    expect(response.code).to eq('401')
  end

  ####################################
  # As Other User
  ####################################
  it 'other user should show email conflict' do
    email_check_mock(false)
    as_user(1)
    get "/#{token.secret}/email_conflict", headers: service_headers(accept: :n3)

    expect(response.code).to eq('200')
  end

  ####################################
  # As User With Other Email
  ####################################
  it 'user with other email should show email conflict' do
    email_check_mock(true)
    as_user(1)
    get "/#{token.secret}/email_conflict", headers: service_headers(accept: :n3)

    expect(response.code).to eq('200')
  end

  private

  def email_check_mock(exists)
    stub_request(:get, expand_service_url(:argu, '/spi/email_addresses', email: 'other@example.com'))
      .to_return(status: exists ? 200 : 404)
  end
end
