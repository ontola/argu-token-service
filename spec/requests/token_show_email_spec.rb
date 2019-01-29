# frozen_string_literal: true

require 'spec_helper'

describe 'Email token show' do
  let(:email_token) { create(:token, email: 'email@example.com') }
  let(:email_token_with_r) { create(:token, email: 'email@example.com', redirect_url: 'https://example.com') }
  let(:retracted_email_token) { create(:retracted_token, email: 'email@example.com') }
  let(:retracted_email_token_with_r) do
    create(:retracted_token, email: 'email@example.com', redirect_url: 'https://example.com')
  end
  let(:expired_email_token) { create(:expired_token, email: 'email@example.com') }
  let(:used_email_token) { create(:used_token, email: 'email@example.com') }

  ####################################
  # As Guest without access token
  ####################################
  it 'guest without access token should redirect valid token with authorized r to r' do
    as_guest_with_account(false)
    authorized_mock(action: 'show', iri: 'https://example.com')
    get "/argu/tokens/#{email_token_with_r.secret}", headers: service_headers

    expect(response.code).to eq('302')
    expect(response).to redirect_to('https://example.com')
    expect(flash[:notice]).to eq('Please login to accept this invitation')
    expect(response.cookies['token']).to eq(resource_iri(email_token_with_r, iri_prefix: "#{ENV['HOSTNAME']}/argu"))
  end

  ####################################
  # As Guest without account
  ####################################
  it 'guest without account with retracted token should not create account and redirect to welcome page' do
    as_guest
    get "/argu/tokens/#{retracted_email_token.secret}", headers: service_headers

    expect(response.code).to eq('302')
    expect(response).to(
      redirect_to(argu_url('/users/sign_in', r: "/argu/tokens/#{retracted_email_token.secret}"))
    )
    expect(flash[:notice]).to eq('Please login to accept this invitation')
    expect(response.cookies['token']).to be_nil
  end

  it 'guest without account with retracted token should not create account and redirect to r' do
    as_guest
    authorized_mock(action: 'show', iri: 'https://example.com')
    get "/argu/tokens/#{retracted_email_token_with_r.secret}", headers: service_headers

    expect(response.code).to eq('302')
    expect(response).to redirect_to('https://example.com')
    expect(flash[:notice]).to be_nil
    expect(response.cookies['token']).to be_nil
  end

  it 'guest without account with retracted token should not create account and should not redirect to unauthorized r' do
    as_guest
    unauthorized_mock(action: 'show', iri: 'https://example.com')
    get "/argu/tokens/#{retracted_email_token_with_r.secret}", headers: service_headers

    expect(response.code).to eq('302')
    expect(response).to(
      redirect_to(argu_url('/users/sign_in', r: "/argu/tokens/#{retracted_email_token_with_r.secret}"))
    )
    expect(flash[:notice]).to eq('Please login to accept this invitation')
    expect(response.cookies['token']).to be_nil
  end

  it 'guest without account with should create account, confirm and redirect to welcome page' do
    as_guest_without_account(email_token.email)
    create_membership_mock(user_id: 1, group_id: 1, secret: email_token.secret)
    emails_mock('tokens', email_token.id)
    confirm_email_mock(email_token.email)
    unauthorized_mock(action: 'show', iri: 'https://example.com')

    get "/argu/tokens/#{email_token.secret}", headers: service_headers

    expect(response.code).to eq('302')
    expect(response).to redirect_to(argu_url('/group_memberships/1'))
    expect(flash[:notice]).to eq('You have joined the group \'group_name\'')
    expect(response.cookies['token']).to be_nil
  end

  it 'guest without account should create account, confirm and redirect to r' do
    as_guest_without_account(email_token_with_r.email)
    create_membership_mock(user_id: 1, group_id: 1, secret: email_token_with_r.secret)
    emails_mock('tokens', email_token_with_r.id)
    confirm_email_mock(email_token_with_r.email)
    unauthorized_mock(action: 'show', iri: 'https://example.com')
    create_favorite_mock(iri: email_token_with_r.redirect_url)

    get "/argu/tokens/#{email_token_with_r.secret}", headers: service_headers

    expect(response.code).to eq('302')
    expect(response).to redirect_to('https://example.com')
    expect(flash[:notice]).to eq('You have joined the group \'group_name\'')
    expect(response.cookies['token']).to be_nil
  end

  ####################################
  # As Guest with account
  ####################################
  it 'guest with account should redirect retracted email token to login page' do
    as_guest
    get "/argu/tokens/#{retracted_email_token.secret}", headers: service_headers

    expect(response.code).to eq('302')
    expect(response).to(
      redirect_to(argu_url('/users/sign_in', r: "/argu/tokens/#{retracted_email_token.secret}"))
    )
    expect(flash[:notice]).to eq('Please login to accept this invitation')
    expect(response.cookies['token']).to be_nil
  end

  it 'guest with account should redirect retracted email token with authorized r to r' do
    as_guest
    authorized_mock(action: 'show', iri: 'https://example.com')
    get "/argu/tokens/#{retracted_email_token_with_r.secret}", headers: service_headers

    expect(response.code).to eq('302')
    expect(response).to redirect_to('https://example.com')
    expect(flash[:notice]).to be_nil
    expect(response.cookies['token']).to be_nil
  end

  it 'guest with account should redirect retracted email token with unauthorized r to login page' do
    as_guest
    unauthorized_mock(action: 'show', iri: 'https://example.com')
    get "/argu/tokens/#{retracted_email_token_with_r.secret}", headers: service_headers

    expect(response.code).to eq('302')
    expect(response).to(
      redirect_to(argu_url('/users/sign_in', r: "/argu/tokens/#{retracted_email_token_with_r.secret}"))
    )
    expect(flash[:notice]).to eq('Please login to accept this invitation')
    expect(response.cookies['token']).to be_nil
  end

  it 'guest with account should redirect valid token to login page' do
    as_guest_with_account
    get "/argu/tokens/#{email_token.secret}", headers: service_headers

    expect(response.code).to eq('302')
    expect(response).to(
      redirect_to(argu_url('/users/sign_in', r: "/argu/tokens/#{email_token.secret}"))
    )
    expect(flash[:notice]).to eq('Please login to accept this invitation')
    expect(response.cookies['token']).to be_nil
  end

  it 'guest with account should redirect valid token with authorized r to r' do
    as_guest_with_account
    authorized_mock(action: 'show', iri: 'https://example.com')
    get "/argu/tokens/#{email_token_with_r.secret}", headers: service_headers

    expect(response.code).to eq('302')
    expect(response).to redirect_to('https://example.com')
    expect(flash[:notice]).to eq('Please login to accept this invitation')
    expect(response.cookies['token']).to eq(resource_iri(email_token_with_r))
  end

  it 'guest with account should redirect valid token with unauthorized r to login page' do
    as_guest_with_account
    unauthorized_mock(action: 'show', iri: 'https://example.com')
    get "/argu/tokens/#{email_token_with_r.secret}", headers: service_headers

    expect(response.code).to eq('302')
    expect(response).to(
      redirect_to(argu_url('/users/sign_in', r: "/argu/tokens/#{email_token_with_r.secret}"))
    )
    expect(flash[:notice]).to eq('Please login to accept this invitation')
    expect(response.cookies['token']).to be_nil
  end

  ####################################
  # As User
  ####################################
  it 'user should not show a retracted email token' do
    as_user(1, email: 'email@example.com')
    unauthorized_mock(type: 'Group', id: 1, action: 'is_member')
    get "/argu/tokens/#{retracted_email_token.secret}", headers: service_headers

    expect(response).to(
      redirect_to(argu_url('/token', error: :inactive, token: retracted_email_token.secret))
    )
    expect(response.cookies['token']).to be_nil
  end

  it 'user should not show an expired email token' do
    as_user(1, email: 'email@example.com')
    unauthorized_mock(type: 'Group', id: 1, action: 'is_member')
    get "/argu/tokens/#{expired_email_token.secret}", headers: service_headers

    expect(response).to(
      redirect_to(argu_url('/token', error: :inactive, token: expired_email_token.secret))
    )
    expect(response.cookies['token']).to be_nil
  end

  it 'user should not show a used email token' do
    as_user(1, email: 'email@example.com')
    unauthorized_mock(type: 'Group', id: 1, action: 'is_member')
    get "/argu/tokens/#{used_email_token.secret}", headers: service_headers

    expect(response).to(
      redirect_to(argu_url('/token', error: :inactive, token: used_email_token.secret))
    )
    expect(response.cookies['token']).to be_nil
  end

  it 'user should redirect email_token with wrong email' do
    as_user(1)
    create_membership_mock(user_id: 1, group_id: 1, secret: email_token.secret)

    get "/argu/tokens/#{email_token.secret}", headers: service_headers
    expect(email_token.reload.last_used_at).to be_nil
    expect(email_token.reload.usages).to eq(0)

    expect(response.code).to eq('302')
    expect(response).to redirect_to(wrong_email_location(email_token))
    expect(flash[:notice]).to be_nil
    expect(response.cookies['token']).to be_nil
  end

  it 'user should redirect email_token to welcome page' do
    as_user(1, email: 'email@example.com')
    create_membership_mock(user_id: 1, group_id: 1, secret: email_token.secret)
    emails_mock('tokens', email_token.id)

    get "/argu/tokens/#{email_token.secret}", headers: service_headers
    expect(email_token.reload.last_used_at).to be_truthy
    expect(email_token.reload.usages).to eq(1)

    expect(response.code).to eq('302')
    expect(flash[:notice]).to eq('You have joined the group \'group_name\'')
    expect(response).to redirect_to(argu_url('/group_memberships/1'))
    expect(response.cookies['token']).to be_nil
  end

  it 'unconfirmed user should confirm and redirect email_token to welcome page' do
    as_user(1, email: 'email@example.com', confirmed: false)
    create_membership_mock(user_id: 1, group_id: 1, secret: email_token.secret)
    emails_mock('tokens', email_token.id)
    confirm_email_mock(email_token.email)

    get "/argu/tokens/#{email_token.secret}", headers: service_headers
    expect(email_token.reload.last_used_at).to be_truthy
    expect(email_token.reload.usages).to eq(1)

    expect(response.code).to eq('302')
    expect(flash[:notice]).to eq('You have joined the group \'group_name\'')
    expect(response).to redirect_to(argu_url('/group_memberships/1'))
    expect(response.cookies['token']).to be_nil
  end

  it 'user should redirect email_token to welcome page with r' do
    as_user(1, email: 'email@example.com')
    create_membership_mock(user_id: 1, group_id: 1, secret: email_token_with_r.secret)
    emails_mock('tokens', email_token_with_r.id)
    create_favorite_mock(iri: email_token_with_r.redirect_url)

    get "/argu/tokens/#{email_token_with_r.secret}", headers: service_headers
    expect(email_token_with_r.reload.last_used_at).to be_truthy
    expect(email_token_with_r.reload.usages).to eq(1)

    expect(response.code).to eq('302')
    expect(flash[:notice]).to eq('You have joined the group \'group_name\'')
    expect(response).to redirect_to('https://example.com')
    expect(response.cookies['token']).to be_nil
  end

  it 'user should redirect when failed to create favorite' do
    as_user(1, email: 'email@example.com')
    create_membership_mock(user_id: 1, group_id: 1, secret: email_token_with_r.secret)
    emails_mock('tokens', email_token_with_r.id)
    create_favorite_mock(iri: email_token_with_r.redirect_url, status: 500)

    get "/argu/tokens/#{email_token_with_r.secret}", headers: service_headers
    expect(email_token_with_r.reload.last_used_at).to be_truthy
    expect(email_token_with_r.reload.usages).to eq(1)

    expect(response.code).to eq('302')
    expect(flash[:notice]).to eq('You have joined the group \'group_name\'')
    expect(response).to redirect_to('https://example.com')
    expect(response.cookies['token']).to be_nil
  end

  it 'user should redirect email_token with secondary email to welcome page' do
    as_user(1, secondary_emails: [email: 'email@example.com', confirmed: true])
    create_membership_mock(user_id: 1, group_id: 1, secret: email_token.secret)
    emails_mock('tokens', email_token.id)

    get "/argu/tokens/#{email_token.secret}", headers: service_headers
    expect(email_token.reload.last_used_at).to be_truthy
    expect(email_token.reload.usages).to eq(1)

    expect(response.code).to eq('302')
    expect(flash[:notice]).to eq('You have joined the group \'group_name\'')
    expect(response).to redirect_to(argu_url('/group_memberships/1'))
    expect(response.cookies['token']).to be_nil
  end

  ####################################
  # As Member
  ####################################
  it 'member should show a retracted email token' do
    as_user(1, email: 'email@example.com')
    authorized_mock(type: 'Group', id: 1, action: 'is_member')
    get "/argu/tokens/#{retracted_email_token.secret}", headers: service_headers

    expect(response).to redirect_to(argu_url)
    expect(flash[:notice]).to eq('You are already member of this group')
    expect(response.cookies['token']).to be_nil
  end

  it 'member should show a retracted email token with r' do
    as_user(1, email: 'email@example.com')
    authorized_mock(type: 'Group', id: 1, action: 'is_member')
    get "/argu/tokens/#{retracted_email_token_with_r.secret}", headers: service_headers

    expect(response).to redirect_to('https://example.com')
    expect(flash[:notice]).to eq('You are already member of this group')
    expect(response.cookies['token']).to be_nil
  end

  it 'member should show an expired email token' do
    as_user(1, email: 'email@example.com')
    authorized_mock(type: 'Group', id: 1, action: 'is_member')
    get "/argu/tokens/#{expired_email_token.secret}", headers: service_headers

    expect(response).to redirect_to(argu_url)
    expect(flash[:notice]).to eq('You are already member of this group')
    expect(response.cookies['token']).to be_nil
  end

  it 'member should show a used email token' do
    as_user(1, email: 'email@example.com')
    authorized_mock(type: 'Group', id: 1, action: 'is_member')
    get "/argu/tokens/#{used_email_token.secret}", headers: service_headers

    expect(response).to redirect_to(argu_url)
    expect(flash[:notice]).to eq('You are already member of this group')
    expect(response.cookies['token']).to be_nil
  end

  private

  def wrong_email_location(token)
    argu_url(
      '/users/wrong_email',
      r: argu_url('/users/sign_in', r: resource_iri(token), notice: I18n.t('please_login')),
      email: token.email
    )
  end
end
