# frozen_string_literal: true

require 'spec_helper'

describe 'Bearer token show n3' do
  let(:token) { create(:token) }
  let(:token_with_r) { create(:token, redirect_url: 'https://example.com') }
  let(:retracted_token) { create(:retracted_token) }
  let(:retracted_token_with_r) { create(:retracted_token, redirect_url: 'https://example.com') }
  let(:expired_token) { create(:expired_token) }
  let(:used_token) { create(:used_token) }

  ####################################
  # As Guest
  ####################################
  it 'guest should get 401' do
    as_guest
    get '/invalid_token', headers: service_headers(accept: :n3)

    expect(response.code).to eq('401')
  end

  it 'guest should redirect retracted to login page' do
    as_guest
    get "/#{retracted_token.secret}", headers: service_headers(accept: :n3)

    expect(response.code).to eq('401')
  end

  it 'guest should redirect retracted with authorized r to r' do
    as_guest
    authorized_mock(action: 'show', iri: 'https://example.com')
    get "/#{retracted_token_with_r.secret}", headers: service_headers(accept: :n3)

    expect(response.code).to eq('401')
  end

  it 'guest should redirect retracted with unauthorized r to login page' do
    as_guest
    unauthorized_mock(action: 'show', iri: 'https://example.com')
    get "/#{retracted_token_with_r.secret}", headers: service_headers(accept: :n3)

    expect(response.code).to eq('401')
  end

  it 'guest should redirect with authorized r to login page' do
    as_guest
    authorized_mock(action: 'show', iri: 'https://example.com')
    get "/#{token_with_r.secret}", headers: service_headers(accept: :n3)

    expect(response.code).to eq('401')
  end

  it 'guest should redirect to login page' do
    as_guest
    get "/#{token.secret}", headers: service_headers(accept: :n3)

    expect(response.code).to eq('401')
  end

  it 'guest should redirect valid token from query param to login page' do
    as_guest
    get "?secret=#{token.secret}", headers: service_headers(accept: :n3)

    expect(response.code).to eq('401')
  end

  ####################################
  # As User
  ####################################
  it 'user should not show a non-existent token' do
    as_user(1)
    get '/invalid_token', headers: service_headers(accept: :n3)

    expect(response.code).to eq('404')
  end

  it 'user should not show a retracted token' do
    as_user(1)
    unauthorized_mock(type: 'Group', id: 1, action: 'is_member')
    get "/#{retracted_token.secret}", headers: service_headers(accept: :n3)

    expect(response.code).to eq('404')
  end

  it 'user should not show an expired token' do
    as_user(1)
    unauthorized_mock(type: 'Group', id: 1, action: 'is_member')
    get "/#{expired_token.secret}", headers: service_headers(accept: :n3)

    expect(response.code).to eq('404')
  end

  it 'user should not show a used token' do
    as_user(1)
    unauthorized_mock(type: 'Group', id: 1, action: 'is_member')
    get "/#{used_token.secret}", headers: service_headers(accept: :n3)

    expect(response.code).to eq('404')
  end

  it 'user should redirect valid token to welcome page' do
    as_user(1)
    create_membership_mock(user_id: 1, group_id: 1, secret: token.secret)
    emails_mock('tokens', token.id)

    get "/#{token.secret}", headers: service_headers(accept: :n3)
    expect(token.reload.last_used_at).to be_truthy
    expect(token.reload.usages).to eq(1)

    expect(response.code).to eq('302')
    expect(flash[:notice]).to eq('You have joined the group \'group_name\'')
    expect(response).to redirect_to(argu_url('/group_memberships/1'))
    expect(response.cookies['token']).to be_nil
  end

  it 'user should redirect valid token form query param to welcome page' do
    as_user(1)
    create_membership_mock(user_id: 1, group_id: 1, secret: token.secret)
    emails_mock('tokens', token.id)

    get "?secret=#{token.secret}", headers: service_headers(accept: :n3)
    expect(token.reload.last_used_at).to be_truthy
    expect(token.reload.usages).to eq(1)

    expect(response.code).to eq('302')
    expect(flash[:notice]).to eq('You have joined the group \'group_name\'')
    expect(response).to redirect_to(argu_url('/group_memberships/1'))
    expect(response.cookies['token']).to be_nil
  end

  it 'user should redirect valid token to welcome page with r' do
    as_user(1)
    create_membership_mock(user_id: 1, group_id: 1, secret: token_with_r.secret)
    emails_mock('tokens', token_with_r.id)
    create_favorite_mock(iri: token_with_r.redirect_url)

    get "/#{token_with_r.secret}", headers: service_headers(accept: :n3)
    expect(token_with_r.reload.last_used_at).to be_truthy
    expect(token_with_r.reload.usages).to eq(1)

    expect(response.code).to eq('302')
    expect(flash[:notice]).to eq('You have joined the group \'group_name\'')
    expect(response).to redirect_to('https://example.com')
    expect(response.cookies['token']).to be_nil
  end

  it 'user should redirect valid token from query param to welcome page with r' do
    as_user(1)
    create_membership_mock(user_id: 1, group_id: 1, secret: token_with_r.secret)
    emails_mock('tokens', token_with_r.id)
    create_favorite_mock(iri: token_with_r.redirect_url)

    get "?secret=#{token_with_r.secret}", headers: service_headers(accept: :n3)
    expect(token_with_r.reload.last_used_at).to be_truthy
    expect(token_with_r.reload.usages).to eq(1)

    expect(response.code).to eq('302')
    expect(flash[:notice]).to eq('You have joined the group \'group_name\'')
    expect(response).to redirect_to('https://example.com')
    expect(response.cookies['token']).to be_nil
  end

  it 'user should redirect when failed to create favorite' do
    as_user(1)
    create_membership_mock(user_id: 1, group_id: 1, secret: token_with_r.secret)
    emails_mock('tokens', token_with_r.id)
    create_favorite_mock(iri: token_with_r.redirect_url, status: 500)

    get "?secret=#{token_with_r.secret}", headers: service_headers(accept: :n3)
    expect(token_with_r.reload.last_used_at).to be_truthy
    expect(token_with_r.reload.usages).to eq(1)

    expect(response.code).to eq('302')
    expect(flash[:notice]).to eq('You have joined the group \'group_name\'')
    expect(response).to redirect_to('https://example.com')
    expect(response.cookies['token']).to be_nil
  end

  it 'user should 500 when failed to create membership' do
    as_user(1)
    create_membership_mock(user_id: 1, group_id: 1, secret: token.secret, response: 403)
    get "/#{token.secret}", headers: service_headers(accept: :n3)

    expect(response.code).to eq('500')
  end

  ####################################
  # As Member
  ####################################
  it 'member should show a retracted token' do
    as_user(1)
    authorized_mock(type: 'Group', id: 1, action: 'is_member')
    get "/#{retracted_token.secret}", headers: service_headers(accept: :n3)

    expect(response).to(redirect_to(argu_url))
    expect(response.cookies['token']).to be_nil
    expect(flash[:notice]).to eq('You are already member of this group')
  end

  it 'member should show an expired token' do
    as_user(1)
    authorized_mock(type: 'Group', id: 1, action: 'is_member')
    get "/#{expired_token.secret}", headers: service_headers(accept: :n3)

    expect(response).to(redirect_to(argu_url))
    expect(response.cookies['token']).to be_nil
    expect(flash[:notice]).to eq('You are already member of this group')
  end

  it 'member should show a used token' do
    as_user(1)
    authorized_mock(type: 'Group', id: 1, action: 'is_member')
    get "/#{used_token.secret}", headers: service_headers(accept: :n3)

    expect(response).to(redirect_to(argu_url))
    expect(response.cookies['token']).to be_nil
    expect(flash[:notice]).to eq('You are already member of this group')
  end

  it 'member should not show a retracted token with r' do
    as_user(1)
    authorized_mock(type: 'Group', id: 1, action: 'is_member')
    get "/#{retracted_token_with_r.secret}", headers: service_headers(accept: :n3)

    expect(response).to(redirect_to('https://example.com'))
    expect(response.cookies['token']).to be_nil
    expect(flash[:notice]).to eq('You are already member of this group')
  end

  it 'member should redirect to group_membership' do
    as_user(1)
    create_membership_mock(user_id: 1, group_id: 1, secret: token.secret, response: 304)

    get "/#{token.secret}", headers: service_headers(accept: :n3)
    expect(token.reload.last_used_at).to be_nil
    expect(token.reload.usages).to eq(0)

    expect(response.code).to eq('302')
    expect(response).to redirect_to(argu_url('/group_memberships/1'))
    expect(response.cookies['token']).to be_nil
    expect(flash[:notice]).to eq('You are already member of this group')
  end
end
