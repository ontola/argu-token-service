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
  # As Guest
  ####################################
  it 'guest should redirect retracted email token to login page' do
    current_user_guest_mock
    get "/#{retracted_email_token.secret}"

    expect(response.code).to eq('302')
    expect(response).to(
      redirect_to(argu_url('/users/sign_in', r: "/#{retracted_email_token.secret}"))
    )
    expect(flash[:notice]).to eq('Please login to accept this invitation')
    expect(response.cookies['token']).to be_nil
  end

  it 'guest should redirect retracted email token with authorized r to r' do
    current_user_guest_mock
    authorized_mock(action: 'show', iri: 'https://example.com')
    get "/#{retracted_email_token_with_r.secret}"

    expect(response.code).to eq('302')
    expect(response).to redirect_to('https://example.com')
    expect(flash[:notice]).to be_nil
    expect(response.cookies['token']).to be_nil
  end

  it 'guest should redirect retracted email token with unauthorized r to login page' do
    current_user_guest_mock
    unauthorized_mock(action: 'show', iri: 'https://example.com')
    get "/#{retracted_email_token_with_r.secret}"

    expect(response.code).to eq('302')
    expect(response).to(
      redirect_to(argu_url('/users/sign_in', r: "/#{retracted_email_token_with_r.secret}"))
    )
    expect(flash[:notice]).to eq('Please login to accept this invitation')
    expect(response.cookies['token']).to be_nil
  end

  it 'guest should redirect email_token to login page' do
    current_user_guest_mock
    get "/#{email_token.secret}"

    expect(response.code).to eq('302')
    expect(response).to(
      redirect_to(argu_url('/users/sign_in', r: "/#{email_token.secret}"))
    )
    expect(flash[:notice]).to eq('Please login to accept this invitation')
    expect(response.cookies['token']).to be_nil
  end

  it 'guest should redirect email_token with authorized r to r' do
    current_user_guest_mock
    authorized_mock(action: 'show', iri: 'https://example.com')
    get "/#{email_token_with_r.secret}"

    expect(response.code).to eq('302')
    expect(response).to redirect_to('https://example.com')
    expect(flash[:notice]).to eq('Please login to accept this invitation')
    expect(response.cookies['token']).to eq(email_token_with_r.context_id)
  end

  it 'guest should redirect email_token with unauthorized r to login page' do
    current_user_guest_mock
    unauthorized_mock(action: 'show', iri: 'https://example.com')
    get "/#{email_token_with_r.secret}"

    expect(response.code).to eq('302')
    expect(response).to(
      redirect_to(argu_url('/users/sign_in', r: "/#{email_token_with_r.secret}"))
    )
    expect(flash[:notice]).to eq('Please login to accept this invitation')
    expect(response.cookies['token']).to be_nil
  end

  ####################################
  # As User
  ####################################
  it 'user should not show a retracted email token' do
    current_user_user_mock(1, email: 'email@example.com')
    unauthorized_mock(type: 'Group', id: 1, action: 'is_member')
    get "/#{retracted_email_token.secret}"

    expect(response).to(
      redirect_to(argu_url('/token', error: :inactive, token: retracted_email_token.secret))
    )
    expect(response.cookies['token']).to be_nil
  end

  it 'user should not show an expired email token' do
    current_user_user_mock(1, email: 'email@example.com')
    unauthorized_mock(type: 'Group', id: 1, action: 'is_member')
    get "/#{expired_email_token.secret}"

    expect(response).to(
      redirect_to(argu_url('/token', error: :inactive, token: expired_email_token.secret))
    )
    expect(response.cookies['token']).to be_nil
  end

  it 'user should not show a used email token' do
    current_user_user_mock(1, email: 'email@example.com')
    unauthorized_mock(type: 'Group', id: 1, action: 'is_member')
    get "/#{used_email_token.secret}"

    expect(response).to(
      redirect_to(argu_url('/token', error: :inactive, token: used_email_token.secret))
    )
    expect(response.cookies['token']).to be_nil
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
    expect(response.cookies['token']).to be_nil
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
    expect(response.cookies['token']).to be_nil
  end

  it 'unconfirmed user should confirm and redirect email_token to welcome page' do
    current_user_user_mock(1, email: 'email@example.com', confirmed: false)
    create_membership_mock(user_id: 1, group_id: 1, secret: email_token.secret)
    emails_mock('tokens', email_token.id)
    confirm_email_mock(email_token.email)

    get "/#{email_token.secret}"
    expect(email_token.reload.last_used_at).to be_truthy
    expect(email_token.reload.usages).to eq(1)

    expect(response.code).to eq('302')
    expect(flash[:notice]).to eq('You have joined the group \'group_name\'')
    expect(response).to redirect_to(argu_url('/group_memberships/1'))
    expect(response.cookies['token']).to be_nil
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
    expect(response.cookies['token']).to be_nil
  end

  it 'user should redirect email_token with secondary email to welcome page' do
    current_user_user_mock(1, secondary_emails: [email: 'email@example.com', confirmed: true])
    create_membership_mock(user_id: 1, group_id: 1, secret: email_token.secret)
    emails_mock('tokens', email_token.id)

    get "/#{email_token.secret}"
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
    current_user_user_mock(1, email: 'email@example.com')
    authorized_mock(type: 'Group', id: 1, action: 'is_member')
    get "/#{retracted_email_token.secret}"

    expect(response).to redirect_to(argu_url)
    expect(flash[:notice]).to eq('You are already member of this group')
    expect(response.cookies['token']).to be_nil
  end

  it 'member should show a retracted email token with r' do
    current_user_user_mock(1, email: 'email@example.com')
    authorized_mock(type: 'Group', id: 1, action: 'is_member')
    get "/#{retracted_email_token_with_r.secret}"

    expect(response).to redirect_to('https://example.com')
    expect(flash[:notice]).to eq('You are already member of this group')
    expect(response.cookies['token']).to be_nil
  end

  it 'member should show an expired email token' do
    current_user_user_mock(1, email: 'email@example.com')
    authorized_mock(type: 'Group', id: 1, action: 'is_member')
    get "/#{expired_email_token.secret}"

    expect(response).to redirect_to(argu_url)
    expect(flash[:notice]).to eq('You are already member of this group')
    expect(response.cookies['token']).to be_nil
  end

  it 'member should show a used email token' do
    current_user_user_mock(1, email: 'email@example.com')
    authorized_mock(type: 'Group', id: 1, action: 'is_member')
    get "/#{used_email_token.secret}"

    expect(response).to redirect_to(argu_url)
    expect(flash[:notice]).to eq('You are already member of this group')
    expect(response.cookies['token']).to be_nil
  end
end
