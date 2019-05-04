# frozen_string_literal: true

require 'spec_helper'

describe 'Token index' do
  let(:token) { create(:token) }

  before do
    group_mock(1)
  end

  ####################################
  # As Guest
  ####################################
  it 'guest should not get index' do
    as_guest
    get "/argu/tokens/bearer/g/#{token.group_id}", headers: service_headers(accept: :json_api)

    expect(response.code).to eq('401')
    expect_error_message('Please sign in to continue')
    expect_error_size(1)
  end

  ####################################
  # As User
  ####################################
  it 'user should not get index' do
    as_user
    unauthorized_mock(type: 'Group', id: 1, action: 'update')
    get "/argu/tokens/bearer/g/#{token.group_id}", headers: service_headers(accept: :json_api)

    expect(response.code).to eq('403')
    expect_error_message("You're not authorized for this action. (index)")
    expect_error_size(1)
  end

  ####################################
  # As Manager
  ####################################
  it 'manager should get index' do
    as_user
    authorized_mock(type: 'Group', id: 1, action: 'update')
    emails_mock('tokens', token.id)

    get "/argu/tokens/bearer/g/#{token.group_id}", headers: service_headers(accept: :json_api)

    expect(response.code).to eq('200')
    expect_included(resource_iri(token))
  end
end
