# frozen_string_literal: true

require 'spec_helper'
require 'jwt'

describe 'Token verify' do
  let(:token) { create(:token) }
  let(:retracted_token) { create(:retracted_token) }
  let(:expired_token) { create(:expired_token) }
  let(:invalid_jwt) do
    JWT.encode({secret: token.secret, group_id: token.group_id + 1},
               Rails.application.secrets.jwt_encryption_token,
               'HS256')
  end
  let(:retracted_jwt) do
    JWT.encode({secret: retracted_token.secret, group_id: retracted_token.group_id},
               Rails.application.secrets.jwt_encryption_token,
               'HS256')
  end
  let(:expired_jwt) do
    JWT.encode({secret: expired_token.secret, group_id: expired_token.group_id},
               Rails.application.secrets.jwt_encryption_token,
               'HS256')
  end
  let(:valid_jwt) do
    JWT.encode({secret: token.secret, group_id: token.group_id},
               Rails.application.secrets.jwt_encryption_token,
               'HS256')
  end

  before do
    group_mock(1)
  end

  it 'jwt with wrong combination should 404' do
    get "/argu/tokens/verify?jwt=#{invalid_jwt}", headers: service_headers(accept: :json_api)

    expect(response.code).to eq('404')
  end

  it 'jwt for retracted token should 404' do
    get "/argu/tokens/verify?jwt=#{retracted_jwt}", headers: service_headers(accept: :json_api)

    expect(response.code).to eq('404')
  end

  it 'jwt for expired token should 404' do
    get "/argu/tokens/verify?jwt=#{expired_jwt}", headers: service_headers(accept: :json_api)

    expect(response.code).to eq('404')
  end

  it 'valid jwt should 200' do
    get "/argu/tokens/verify?jwt=#{valid_jwt}", headers: service_headers(accept: :json_api)

    expect(response.code).to eq('200')
  end
end
