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
    get "/argu/tokens/g/#{token.group_id}/bearer", headers: service_headers(accept: :json_api)

    expect(response.code).to eq('403')
    expect_error_message("You're not authorized for this action. (index)")
    expect_error_size(1)
  end

  ####################################
  # As User
  ####################################
  it 'user should not get index' do
    as_user
    unauthorized_mock(type: 'Group', id: 1, action: 'update')
    get "/argu/tokens/g/#{token.group_id}/bearer", headers: service_headers(accept: :json_api)

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

    get "/argu/tokens/g/#{token.group_id}/bearer", headers: service_headers(accept: :nq)

    expect(response.code).to eq('200')
    expect_triple(resource_iri(token.group.bearer_token_collection), NS.ontola[:pages], nil).objects.first
    expect_triple(resource_iri(token.group.bearer_token_collection), NS.as[:totalItems], 1)
    refute_triple(nil, nil, resource_iri(token))
  end

  it 'manager should get index page 1' do
    as_user
    authorized_mock(type: 'Group', id: 1, action: 'update')
    emails_mock('tokens', token.id)

    get "/argu/tokens/g/#{token.group_id}/bearer?page=1", headers: service_headers(accept: :nq)

    expect(response.code).to eq('200')
    expect_triple(resource_iri(token.group.bearer_token_collection(page: 1)), NS.as[:totalItems], 1)
    expect_triple(nil, nil, resource_iri(token))
  end
end
