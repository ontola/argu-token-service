# frozen_string_literal: true
require 'spec_helper'

describe 'Token show' do
  let(:token) { create(:token) }
  let(:retracted_token) { create(:retracted_token) }
  let(:expired_token) { create(:expired_token) }
  let(:used_token) { create(:used_token) }
  let(:email_token) { create(:token, email: 'email@example.com') }
  let(:retracted_email_token) { create(:retracted_token, email: 'email@example.com') }
  let(:expired_email_token) { create(:expired_token, email: 'email@example.com') }
  let(:used_email_token) { create(:used_token, email: 'email@example.com') }

  ####################################
  # As Guest
  ####################################
  it 'guest should not show a non-existent token' do
    current_user_guest_mock
    get '/invalid_token', as: :html

    expect(response.body).to include('404')
    expect(response.code).to eq('404')
    expect(response.body).not_to include('MissingFile')
  end

  it 'guest should not show a retracted token' do
    current_user_guest_mock
    get "/#{retracted_token.secret}"

    expect(response.body).to include('403')
    expect(response.body).to include('The requested token has expired or has been retracted')
    expect(response.code).to eq('403')
    expect(response.body).not_to include('MissingFile')
  end

  it 'guest should not show an expired token' do
    current_user_guest_mock
    get "/#{expired_token.secret}"

    expect(response.body).to include('403')
    expect(response.body).to include('The requested token has expired or has been retracted')
    expect(response.code).to eq('403')
    expect(response.body).not_to include('MissingFile')
  end

  it 'guest should not show a used token' do
    current_user_guest_mock
    get "/#{used_token.secret}"

    expect(response.body).to include('403')
    expect(response.code).to eq('403')
    expect(response.body).not_to include('MissingFile')
  end

  it 'guest should not show a retracted email token' do
    current_user_guest_mock
    get "/#{retracted_email_token.secret}"

    expect(response.body).to include('403')
    expect(response.body).to include('The requested token has expired or has been retracted')
    expect(response.code).to eq('403')
    expect(response.body).not_to include('MissingFile')
  end

  it 'guest should not show an expired email token' do
    current_user_guest_mock
    get "/#{expired_email_token.secret}"

    expect(response.body).to include('403')
    expect(response.body).to include('The requested token has expired or has been retracted')
    expect(response.code).to eq('403')
    expect(response.body).not_to include('MissingFile')
  end

  it 'guest should not show a used email token' do
    current_user_guest_mock
    get "/#{used_email_token.secret}"

    expect(response.body).to include('403')
    expect(response.code).to eq('403')
    expect(response.body).not_to include('MissingFile')
  end

  it 'guest should redirect bearer_token to login page' do
    current_user_guest_mock
    get "/#{token.secret}"

    expect(response.code).to eq('302')
    expect(response).to(
      redirect_to(argu_url('/users/sign_in', r: "/#{token.secret}"))
    )
  end

  it 'guest should redirect email_token to login page' do
    current_user_guest_mock
    get "/#{email_token.secret}"

    expect(response.code).to eq('302')
    expect(response).to(
      redirect_to(argu_url('/users/sign_in', r: "/#{email_token.secret}"))
    )
  end

  ####################################
  # As User
  ####################################
  it 'user should not show a non-existent token' do
    current_user_user_mock(1)
    get '/invalid_token', as: :html

    expect(response.body).to include('404')
    expect(response.code).to eq('404')
    expect(response.body).not_to include('MissingFile')
  end

  it 'user should not show a retracted token' do
    current_user_user_mock(1)
    get "/#{retracted_token.secret}"

    expect(response.body).to include('403')
    expect(response.body).to include('The requested token has expired or has been retracted')
    expect(response.code).to eq('403')
    expect(response.body).not_to include('MissingFile')
  end

  it 'user should not show an expired token' do
    current_user_user_mock(1)
    get "/#{expired_token.secret}"

    expect(response.body).to include('403')
    expect(response.body).to include('The requested token has expired or has been retracted')
    expect(response.code).to eq('403')
    expect(response.body).not_to include('MissingFile')
  end

  it 'user should not show a used token' do
    current_user_user_mock(1)
    get "/#{used_token.secret}"

    expect(response.body).to include('403')
    expect(response.code).to eq('403')
    expect(response.body).not_to include('MissingFile')
  end

  it 'user should not show a retracted email token' do
    current_user_user_mock(1, email: 'email@example.com')
    unauthorized_mock('Group', 1, 'is_member')
    get "/#{retracted_email_token.secret}"

    expect(response.body).to include('403')
    expect(response.body).to include('The requested token has expired or has been retracted')
    expect(response.code).to eq('403')
    expect(response.body).not_to include('MissingFile')
  end

  it 'user should not show an expired email token' do
    current_user_user_mock(1, email: 'email@example.com')
    unauthorized_mock('Group', 1, 'is_member')
    get "/#{expired_email_token.secret}"

    expect(response.body).to include('403')
    expect(response.body).to include('The requested token has expired or has been retracted')
    expect(response.code).to eq('403')
    expect(response.body).not_to include('MissingFile')
  end

  it 'user should not show a used email token' do
    current_user_user_mock(1, email: 'email@example.com')
    unauthorized_mock('Group', 1, 'is_member')
    get "/#{used_email_token.secret}"

    expect(response.body).to include('403')
    expect(response.code).to eq('403')
    expect(response.body).not_to include('MissingFile')
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
  end

  it 'user should redirect bearer_token to welcome page' do
    current_user_user_mock(1)
    create_membership_mock(user_id: 1, group_id: 1, secret: token.secret)
    emails_mock('tokens', token.id)

    get "/#{token.secret}"
    expect(token.reload.last_used_at).to be_truthy
    expect(token.reload.usages).to eq(1)

    expect(response.code).to eq('302')
    expect(response).to(
      redirect_to(argu_url("/g/#{token.group_id}", welcome: true))
    )
  end

  it 'user should redirect email_token to welcome page' do
    current_user_user_mock(1, email: 'email@example.com')
    create_membership_mock(user_id: 1, group_id: 1, secret: email_token.secret)
    emails_mock('tokens', email_token.id)

    get "/#{email_token.secret}"
    expect(email_token.reload.last_used_at).to be_truthy
    expect(email_token.reload.usages).to eq(1)

    expect(response.code).to eq('302')
    expect(response).to(
      redirect_to(argu_url("/g/#{email_token.group_id}", welcome: true))
    )
  end

  it 'user should redirect email_token with secundary email to welcome page' do
    current_user_user_mock(1, secondary_emails: %w(email@example.com))
    create_membership_mock(user_id: 1, group_id: 1, secret: email_token.secret)
    emails_mock('tokens', email_token.id)

    get "/#{email_token.secret}"
    expect(email_token.reload.last_used_at).to be_truthy
    expect(email_token.reload.usages).to eq(1)

    expect(response.code).to eq('302')
    expect(response).to(
      redirect_to(argu_url("/g/#{email_token.group_id}", welcome: true))
    )
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
    authorized_mock('Group', 1, 'is_member')
    get "/#{retracted_email_token.secret}"

    expect(response).to(
      redirect_to(argu_url("/g/#{retracted_email_token.group_id}"))
    )
  end

  it 'member should show an expired email token' do
    current_user_user_mock(1, email: 'email@example.com')
    authorized_mock('Group', 1, 'is_member')
    get "/#{expired_email_token.secret}"

    expect(response).to(
      redirect_to(argu_url("/g/#{expired_email_token.group_id}"))
    )
  end

  it 'member should show a used email token' do
    current_user_user_mock(1, email: 'email@example.com')
    authorized_mock('Group', 1, 'is_member')
    get "/#{used_email_token.secret}"

    expect(response).to(
      redirect_to(argu_url("/g/#{used_email_token.group_id}"))
    )
  end

  it 'member should redirect to page' do
    current_user_user_mock(1)
    create_membership_mock(user_id: 1, group_id: 1, secret: token.secret, response: 304)

    get "/#{token.secret}"
    expect(token.reload.last_used_at).to be_nil
    expect(token.reload.usages).to eq(0)

    expect(response.code).to eq('302')
    expect(response).to(
      redirect_to(argu_url("/g/#{token.group_id}"))
    )
  end
end
