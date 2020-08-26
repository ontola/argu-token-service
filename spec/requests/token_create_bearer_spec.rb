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
    get '/argu/tokens/bearer/g/1/new', headers: service_headers(accept: :json_api)

    expect(response.code).to eq('401')
    expect_error_message('Please sign in to continue')
    expect_error_size(1)
  end

  it 'guest should not create valid bearer token' do
    as_guest
    assert_difference('Token.count', 0) do
      post '/argu/tokens/', params: {
        data: {
          type: 'bearerToken',
          attributes: {
            group_id: 1
          }
        }
      }, headers: service_headers(accept: :json_api)
    end

    expect(response.code).to eq('401')
    expect_error_message('Please sign in to continue')
    expect_error_size(1)
  end

  it 'guest should not create valid bearer token NQ' do
    as_guest
    assert_difference('Token.count', 0) do
      post '/argu/tokens/bearer/g/1', params: {
        bearer_token: {
          root_id: TEST_ROOT_ID
        }
      }, headers: service_headers(accept: :nq)
    end

    expect(response.code).to eq('401')
  end

  ####################################
  # As User
  ####################################
  it 'user should not get new bearer token' do
    as_user
    unauthorized_mock(type: 'Group', id: 1, action: 'update')
    get '/argu/tokens/bearer/g/1/new', headers: service_headers(accept: :json_api)

    expect(response.code).to eq('403')
    expect_error_message("You're not authorized for this action. (new)")
    expect_error_size(1)
  end

  it 'user should not create valid bearer token' do
    as_user
    unauthorized_mock(type: 'Group', id: 1, action: 'update')
    assert_difference('Token.count', 0) do
      post '/argu/tokens/', params: {
        data: {
          type: 'bearerToken',
          attributes: {
            group_id: 1,
            root_id: TEST_ROOT_ID
          }
        }
      }, headers: service_headers(accept: :json_api)
    end

    expect(response.code).to eq('403')
    expect_error_message("You're not authorized for this action. (create)")
    expect_error_size(1)
  end

  it 'user should not create valid bearer token NQ' do
    as_user
    unauthorized_mock(type: 'Group', id: 1, action: 'update')
    assert_difference('Token.count', 0) do
      post '/argu/tokens/bearer/g/1', params: {
        bearer_token: {
          root_id: TEST_ROOT_ID
        }
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
    authorized_mock(type: 'CurrentActor', id: "https://#{ENV['HOSTNAME']}/u/1", action: 'show')
    get '/argu/tokens/bearer/g/1/new', headers: service_headers(accept: :n3)

    expect(response.code).to eq('200')
  end

  it 'manager should not create token with wrong type' do
    as_user
    authorized_mock(type: 'Group', id: 1, action: 'update')
    assert_difference('Token.count', 0) do
      post '/argu/tokens/', params: {
        data: {
          type: 'wrongType',
          attributes: {
            group_id: 1,
            root_id: TEST_ROOT_ID
          }
        }
      }, headers: service_headers(accept: :json_api)

      expect(response.code).to eq('422')
      expect_error_message('found unpermitted parameter: :type')
      expect_error_size(1)
    end
  end

  it 'manager should not create without attributes' do
    as_user
    assert_difference('Token.count', 0) do
      post '/argu/tokens/', headers: service_headers(accept: :json_api)

      expect(response.code).to eq('422')
      expect_error_message('param is missing or the value is empty: data')
      expect_error_size(1)
    end
  end

  it 'manager should not create bearer token with invalid attributes' do
    as_user
    unauthorized_mock(type: 'Group', id: 1, action: 'update')
    assert_difference('Token.count', 0) do
      post '/argu/tokens/', params: {
        data: {
          type: 'bearerToken',
          attributes: {
            bla: 'blabla'
          }
        }
      }, headers: service_headers(accept: :json_api)

      expect(response.code).to eq('422')
      expect_error_message('param is missing or the value is empty: group_id')
      expect_error_size(1)
    end
  end

  it 'manager should not create bearer token for group_id < 0' do
    as_user
    authorized_mock(type: 'Group', id: -1, action: 'update')
    assert_difference('Token.count', 0) do
      post '/argu/tokens/', params: {
        data: {
          type: 'bearerToken',
          attributes: {
            group_id: -1,
            root_id: TEST_ROOT_ID
          }
        }
      }, headers: service_headers(accept: :json_api)
    end

    expect(response.code).to eq('422')
    expect_error_message('Group must be greater than 0')
    expect_error_size(1)
  end

  it 'manager should create valid bearer token' do
    as_user
    authorized_mock(type: 'Group', id: 1, action: 'update')
    assert_difference('Token.count', 1) do
      post '/argu/tokens/', params: {
        data: {
          type: 'bearerToken',
          attributes: {
            group_id: 1,
            root_id: TEST_ROOT_ID
          }
        }
      }, headers: service_headers(accept: :json_api)
    end

    expect(response.code).to eq('201')
    expect_token_attributes
    expect(Token.last.secret.length).to eq(16)
  end

  it 'manager should create bearer token with expired_at attribute' do
    as_user
    authorized_mock(type: 'Group', id: 1, action: 'update')
    assert_difference('Token.count', 1) do
      post '/argu/tokens/', params: {
        data: {
          type: 'bearerToken',
          attributes: {
            group_id: 1,
            root_id: TEST_ROOT_ID,
            expires_at: 1.day.from_now
          }
        }
      }, headers: service_headers(accept: :json_api)
    end

    expect(response.code).to eq('201')
    expect_token_attributes
    expect(Token.last.expires_at).to be_truthy
  end

  it 'manager should create bearer token with redirect_url' do
    as_user
    authorized_mock(type: 'Group', id: 1, action: 'update')
    assert_difference('Token.count', 1) do
      post '/argu/tokens/', params: {
        data: {
          type: 'bearerToken',
          attributes: {
            group_id: 1,
            root_id: TEST_ROOT_ID,
            redirect_url: 'https://example.com'
          }
        }
      }, headers: service_headers(accept: :json_api)
    end

    expect(response.code).to eq('201')
    expect_token_attributes
    expect(Token.last.redirect_url).to eq('https://example.com')
  end

  it 'manager should not create without attributes NQ' do
    as_user
    authorized_mock(type: 'Group', id: 1, action: 'update')
    assert_difference('Token.count', 0) do
      post '/argu/tokens/bearer/g/1', headers: service_headers(accept: :nq)

      expect(response.code).to eq('422')
    end
  end

  it 'manager should not create bearer token with invalid attributes NQ' do
    as_user
    authorized_mock(type: 'Group', id: -1, action: 'update')
    assert_difference('Token.count', 0) do
      post '/argu/tokens/bearer/g/-1', headers: service_headers(accept: :nq)

      expect(response.code).to eq('422')
    end
  end

  it 'manager should not create bearer token for group_id < 0 NQ' do
    as_user
    authorized_mock(type: 'Group', id: -1, action: 'update')
    assert_difference('Token.count', 0) do
      post '/argu/tokens/bearer/g/-1', params: {
        bearer_token: {
          root_id: TEST_ROOT_ID
        }
      }, headers: service_headers(accept: :nq)
    end

    expect(response.code).to eq('422')
  end

  it 'manager should create valid bearer token NQ' do
    as_user
    authorized_mock(type: 'Group', id: 1, action: 'update')
    assert_difference('Token.count', 1) do
      post '/argu/tokens/bearer/g/1', params: {
        bearer_token: {
          root_id: TEST_ROOT_ID,
          redirect_url: 'https://example.com'
        }
      }, headers: service_headers(accept: :nq)
    end

    expect(response.code).to eq('201')
    expect(Token.last.secret.length).to eq(16)
  end

  it 'manager should create bearer token with expired_at attribute NQ' do
    as_user
    authorized_mock(type: 'Group', id: 1, action: 'update')
    assert_difference('Token.count', 1) do
      post '/argu/tokens/bearer/g/1', params: {
        bearer_token: {
          root_id: TEST_ROOT_ID,
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
      post '/argu/tokens/bearer/g/1', params: {
        bearer_token: {
          root_id: TEST_ROOT_ID,
          redirect_url: 'https://example.com',
          message: 'Join this group!'
        }
      }, headers: service_headers(accept: :nq)
    end

    expect(response.code).to eq('201')
    expect(Token.last.redirect_url).to eq('https://example.com')
    expect(Token.last.secret.length).to eq(16)
  end

  private

  def expect_token_attributes(index = nil)
    expect_attributes(
      %w[rdf_type canonical_iri group_id usages created_at expires_at retracted_at actor_iri
         message iri display_name redirect_url root_id token_url label description],
      index
    )
  end
end
