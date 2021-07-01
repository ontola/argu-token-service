# frozen_string_literal: true

require 'spec_helper'

describe 'Token bearer create' do
  before do
    group_mock(1)
  end

  ####################################
  # As Guest
  ####################################
  it 'guest should not get new bearer token' do
    as_guest
    get '/argu/tokens/g/1/bearer/new', headers: service_headers(accept: :nq)

    assert_disabled_form(error: nil)
  end

  it 'guest should not create valid bearer token' do
    as_guest
    assert_difference('Token.count', 0) do
      post '/argu/tokens/g/1/bearer', headers: service_headers(accept: :nq)
    end

    expect(response.code).to eq('401')
  end

  ####################################
  # As User
  ####################################
  it 'user should not get new bearer token' do
    as_user
    unauthorized_mock(type: 'Group', id: 1, action: 'update')
    get '/argu/tokens/g/1/bearer/new', headers: service_headers(accept: :nq)

    assert_disabled_form(error: nil)
  end

  it 'user should not create valid bearer token NQ' do
    as_user
    unauthorized_mock(type: 'Group', id: 1, action: 'update')
    assert_difference('Token.count', 0) do
      post '/argu/tokens/g/1/bearer', params: {
        bearer_token: {}
      }, headers: service_headers(accept: :nq)
    end

    expect(response.code).to eq('403')
  end

  ####################################
  # As Manager
  ####################################
  it 'manager should not get new bearer token' do
    as_user
    authorized_mock(type: 'Group', action: 'update')
    authorized_mock(type: 'Group', id: 1, action: 'update')
    authorized_mock(type: 'CurrentActor', id: "http://#{ENV['HOSTNAME']}/u/1", action: 'show')
    get '/argu/tokens/g/1/bearer/new', headers: service_headers(accept: :n3)

    expect(response.code).to eq('200')
  end

  it 'manager should not create without attributes' do
    as_user
    authorized_mock(type: 'Group', id: 1, action: 'update')
    assert_difference('Token.count', 0) do
      post '/argu/tokens/g/1/bearer', headers: service_headers(accept: :nq)

      expect(response.code).to eq('422')
      expect_ontola_action(snackbar: 'param is missing or the value is empty')
    end
  end

  it 'manager should not create bearer token for group_id < 0' do
    as_user
    authorized_mock(type: 'Group', id: -1, action: 'update')
    assert_difference('Token.count', 0) do
      post '/argu/tokens/g/-1/bearer', params: {
        bearer_token: {
          redirect_url: 'https://example.com'
        }
      }, headers: service_headers(accept: :nq)
    end

    expect(response.code).to eq('422')
  end

  it 'manager should create bearer token with redirect_url' do
    as_user
    authorized_mock(type: 'Group', id: 1, action: 'update')
    assert_difference('Token.count', 1) do
      post '/argu/tokens/g/1/bearer', params: {
        bearer_token: {
          redirect_url: 'https://example.com'
        }
      }, headers: service_headers(accept: :nq)
    end

    expect(response.code).to eq('201')
    expect(Token.last.redirect_url).to eq('https://example.com')
  end

  it 'manager should create bearer token with expired_at attribute' do
    as_user
    authorized_mock(type: 'Group', id: 1, action: 'update')
    assert_difference('Token.count', 1) do
      post '/argu/tokens/g/1/bearer', params: {
        bearer_token: {
          expires_at: 1.day.from_now
        }
      }, headers: service_headers(accept: :nq)
    end

    expect(response.code).to eq('201')
    expect(Token.last.expires_at).to be_truthy
  end

  it 'manager should not create without attributes NQ' do
    as_user
    authorized_mock(type: 'Group', id: 1, action: 'update')
    assert_difference('Token.count', 0) do
      post '/argu/tokens/g/1/bearer', headers: service_headers(accept: :nq)

      expect(response.code).to eq('422')
    end
  end

  it 'manager should not create bearer token with invalid attributes NQ' do
    as_user
    authorized_mock(type: 'Group', id: -1, action: 'update')
    assert_difference('Token.count', 0) do
      post '/argu/tokens/g/-1/bearer', headers: service_headers(accept: :nq)

      expect(response.code).to eq('422')
    end
  end

  it 'manager should not create bearer token for group_id < 0 NQ' do
    as_user
    authorized_mock(type: 'Group', id: -1, action: 'update')
    assert_difference('Token.count', 0) do
      post '/argu/tokens/g/-1/bearer', params: {
        bearer_token: {}
      }, headers: service_headers(accept: :nq)
    end

    expect(response.code).to eq('422')
  end

  it 'manager should create valid bearer token NQ' do
    as_user
    authorized_mock(type: 'Group', id: 1, action: 'update')
    assert_difference('Token.count', 1) do
      post '/argu/tokens/g/1/bearer', params: {
        bearer_token: {
          redirect_url: 'https://example.com'
        }
      }, headers: service_headers(accept: :nq)
    end

    expect(response.code).to eq('201')
    expect(Token.last.secret.length).to eq(8)
  end

  it 'manager should create bearer token with expired_at attribute NQ' do
    as_user
    authorized_mock(type: 'Group', id: 1, action: 'update')
    assert_difference('Token.count', 1) do
      post '/argu/tokens/g/1/bearer', params: {
        bearer_token: {
          redirect_url: 'https://example.com',
          expires_at: 1.day.from_now
        }
      }, headers: service_headers(accept: :nq)
    end

    expect(response.code).to eq('201')
    expect(Token.last.expires_at).to be_truthy
  end

  it 'manager should create bearer token with redirect_url NQ' do
    as_user
    authorized_mock(type: 'Group', id: 1, action: 'update')
    assert_difference('Token.count', 1) do
      post '/argu/tokens/g/1/bearer', params: {
        bearer_token: {
          redirect_url: 'https://example.com',
          message: 'Join this group!'
        }
      }, headers: service_headers(accept: :nq)
    end

    expect(response.code).to eq('201')
    expect(Token.last.redirect_url).to eq('https://example.com')
    expect(Token.last.secret.length).to eq(8)
  end
end
