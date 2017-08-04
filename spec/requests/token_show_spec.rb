# frozen_string_literal: true
require 'spec_helper'

describe 'Token show' do
  let(:token) { create(:token) }
  let(:token_with_r) { create(:token, redirect_url: 'https://example.com') }
  let(:retracted_token) { create(:retracted_token) }
  let(:expired_token) { create(:expired_token) }
  let(:used_token) { create(:used_token) }
  let(:email_token) { create(:token, email: 'email@example.com') }
  let(:email_token_with_r) { create(:token, email: 'email@example.com', redirect_url: 'https://example.com') }
  let(:retracted_email_token) { create(:retracted_token, email: 'email@example.com') }
  let(:retracted_email_token_with_r) do
    create(:retracted_token, email: 'email@example.com', redirect_url: 'https://example.com')
  end
  let(:expired_email_token) { create(:expired_token, email: 'email@example.com') }
  let(:used_email_token) { create(:used_token, email: 'email@example.com') }

  ####################################
  # As Guest
  ####################################
  it 'guest should redirect non-existent to login page' do
    current_user_guest_mock
    get '/invalid_token'

    expect(response.code).to eq('302')
    expect(response).to(
      redirect_to(argu_url('/users/sign_in', r: '/invalid_token'))
    )
    expect(flash[:notice]).to eq('Please login to accept this invitation')
  end

  it 'guest should redirect retracted to login page' do
    current_user_guest_mock
    get "/#{retracted_token.secret}"

    expect(response.code).to eq('302')
    expect(response).to(
      redirect_to(argu_url('/users/sign_in', r: "/#{retracted_token.secret}"))
    )
    expect(flash[:notice]).to eq('Please login to accept this invitation')
  end

  it 'guest should redirect retracted email token to login page' do
    current_user_guest_mock
    get "/#{retracted_email_token.secret}"

    expect(response.code).to eq('302')
    expect(response).to(
      redirect_to(argu_url('/users/sign_in', r: "/#{retracted_email_token.secret}"))
    )
    expect(flash[:notice]).to eq('Please login to accept this invitation')
  end

  it 'guest should redirect email_token to login page' do
    current_user_guest_mock
    get "/#{email_token.secret}"

    expect(response.code).to eq('302')
    expect(response).to(
      redirect_to(argu_url('/users/sign_in', r: "/#{email_token.secret}"))
    )
    expect(flash[:notice]).to eq('Please login to accept this invitation')
  end

  it 'guest should redirect email_token to login page with token in query param' do
    current_user_guest_mock
    get "?token=#{email_token.secret}"

    expect(response.code).to eq('302')
    expect(response).to(
      redirect_to(argu_url('/users/sign_in', r: "?token=#{email_token.secret}"))
    )
    expect(flash[:notice]).to eq('Please login to accept this invitation')
  end

  ####################################
  # As User
  ####################################
  it 'user should not show a non-existent token' do
    current_user_user_mock(1)
    get '/invalid_token', as: :html

    expect(response).to(
      redirect_to(argu_url('/token', error: :not_found, token: :invalid_token))
    )
  end

  it 'user should not show a retracted token' do
    current_user_user_mock(1)
    get "/#{retracted_token.secret}"

    expect(response).to(
      redirect_to(argu_url('/token', error: :inactive, token: retracted_token.secret))
    )
  end

  it 'user should not show an expired token' do
    current_user_user_mock(1)
    get "/#{expired_token.secret}"

    expect(response).to(
      redirect_to(argu_url('/token', error: :inactive, token: expired_token.secret))
    )
  end

  it 'user should not show a used token' do
    current_user_user_mock(1)
    get "/#{used_token.secret}"

    expect(response).to(
      redirect_to(argu_url('/token', error: :inactive, token: used_token.secret))
    )
  end

  it 'user should not show a retracted email token' do
    current_user_user_mock(1, email: 'email@example.com')
    unauthorized_mock(type: 'Group', id: 1, action: 'is_member')
    get "/#{retracted_email_token.secret}"

    expect(response).to(
      redirect_to(argu_url('/token', error: :inactive, token: retracted_email_token.secret))
    )
  end

  it 'user should not show an expired email token' do
    current_user_user_mock(1, email: 'email@example.com')
    unauthorized_mock(type: 'Group', id: 1, action: 'is_member')
    get "/#{expired_email_token.secret}"

    expect(response).to(
      redirect_to(argu_url('/token', error: :inactive, token: expired_email_token.secret))
    )
  end

  it 'user should not show a used email token' do
    current_user_user_mock(1, email: 'email@example.com')
    unauthorized_mock(type: 'Group', id: 1, action: 'is_member')
    get "/#{used_email_token.secret}"

    expect(response).to(
      redirect_to(argu_url('/token', error: :inactive, token: used_email_token.secret))
    )
  end

  it 'user should redirect email_token with wrong email' do
    current_user_user_mock(1)
    create_membership_mock(user_id: 1, group_id: 1, secret: email_token.secret)

    get "/#{email_token.secret}"
    expect(email_token.reload.last_used_at).to be_nil
    expect(email_token.reload.usages).to eq(0)

    expect(response.code).to eq('302')
    expect(response).to(
      redirect_to(argu_url('/users/wrong_email', r: email_token.context_id, email: email_token.email))
    )
    expect(flash[:notice]).to be_nil
  end

  it 'user should redirect bearer_token to welcome page' do
    current_user_user_mock(1)
    create_membership_mock(user_id: 1, group_id: 1, secret: token.secret)
    emails_mock('tokens', token.id)

    get "/#{token.secret}"
    expect(token.reload.last_used_at).to be_truthy
    expect(token.reload.usages).to eq(1)

    expect(response.code).to eq('302')
    expect(flash[:notice]).to eq('You have joined the group \'group_name\'')
    expect(response).to redirect_to(argu_url('/group_memberships/1'))
  end

  it 'user should redirect bearer_token to welcome page with r' do
    current_user_user_mock(1)
    create_membership_mock(user_id: 1, group_id: 1, secret: token_with_r.secret)
    emails_mock('tokens', token_with_r.id)

    get "/#{token_with_r.secret}"
    expect(token_with_r.reload.last_used_at).to be_truthy
    expect(token_with_r.reload.usages).to eq(1)

    expect(response.code).to eq('302')
    expect(flash[:notice]).to eq('You have joined the group \'group_name\'')
    expect(response).to redirect_to('https://example.com')
  end

  it 'user should redirect email_token to welcome page' do
    current_user_user_mock(1, email: 'email@example.com')
    create_membership_mock(user_id: 1, group_id: 1, secret: email_token.secret)
    emails_mock('tokens', email_token.id)

    get "/#{email_token.secret}"
    expect(email_token.reload.last_used_at).to be_truthy
    expect(email_token.reload.usages).to eq(1)

    expect(response.code).to eq('302')
    expect(flash[:notice]).to eq('You have joined the group \'group_name\'')
    expect(response).to redirect_to(argu_url('/group_memberships/1'))
  end

  it 'user should redirect email_token to welcome page with r' do
    current_user_user_mock(1, email: 'email@example.com')
    create_membership_mock(user_id: 1, group_id: 1, secret: email_token_with_r.secret)
    emails_mock('tokens', email_token_with_r.id)

    get "/#{email_token_with_r.secret}"
    expect(email_token_with_r.reload.last_used_at).to be_truthy
    expect(email_token_with_r.reload.usages).to eq(1)

    expect(response.code).to eq('302')
    expect(flash[:notice]).to eq('You have joined the group \'group_name\'')
    expect(response).to redirect_to('https://example.com')
  end

  it 'user should redirect email_token with secundary email to welcome page' do
    current_user_user_mock(1, secondary_emails: %w(email@example.com))
    create_membership_mock(user_id: 1, group_id: 1, secret: email_token.secret)
    emails_mock('tokens', email_token.id)

    get "/#{email_token.secret}"
    expect(email_token.reload.last_used_at).to be_truthy
    expect(email_token.reload.usages).to eq(1)

    expect(response.code).to eq('302')
    expect(flash[:notice]).to eq('You have joined the group \'group_name\'')
    expect(response).to redirect_to(argu_url('/group_memberships/1'))
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
  it 'member should show a retracted email token' do
    current_user_user_mock(1, email: 'email@example.com')
    authorized_mock(type: 'Group', id: 1, action: 'is_member')
    get "/#{retracted_email_token.secret}"

    expect(response).to redirect_to(argu_url)
    expect(flash[:notice]).to be_nil
  end

  it 'member should show a retracted email token with r' do
    current_user_user_mock(1, email: 'email@example.com')
    authorized_mock(type: 'Group', id: 1, action: 'is_member')
    get "/#{retracted_email_token_with_r.secret}"

    expect(response).to redirect_to('https://example.com')
    expect(flash[:notice]).to be_nil
  end

  it 'member should show an expired email token' do
    current_user_user_mock(1, email: 'email@example.com')
    authorized_mock(type: 'Group', id: 1, action: 'is_member')
    get "/#{expired_email_token.secret}"

    expect(response).to redirect_to(argu_url)
    expect(flash[:notice]).to be_nil
  end

  it 'member should show a used email token' do
    current_user_user_mock(1, email: 'email@example.com')
    authorized_mock(type: 'Group', id: 1, action: 'is_member')
    get "/#{used_email_token.secret}"

    expect(response).to redirect_to(argu_url)
    expect(flash[:notice]).to be_nil
  end

  it 'member should redirect to group_membership' do
    current_user_user_mock(1)
    create_membership_mock(user_id: 1, group_id: 1, secret: token.secret, response: 304)

    get "/#{token.secret}"
    expect(token.reload.last_used_at).to be_nil
    expect(token.reload.usages).to eq(0)

    expect(response.code).to eq('302')
    expect(response).to redirect_to(argu_url('/group_memberships/1'))
    expect(flash[:notice]).to be_nil
  end
end
