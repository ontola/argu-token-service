# frozen_string_literal: true

require 'spec_helper'

describe 'Email token show' do
  let(:valid_token) { create(:token, email: 'email@example.com') }
  let(:token_with_r) { create(:token, email: 'email@example.com', redirect_url: 'https://example.com') }
  let(:retracted_token) { create(:retracted_token, email: 'email@example.com') }
  let(:retracted_token_with_r) do
    create(:retracted_token, email: 'email@example.com', redirect_url: 'https://example.com')
  end
  let(:expired_token) { create(:expired_token, email: 'email@example.com') }
  let(:used_token) { create(:used_token, email: 'email@example.com') }

  let(:authenticate_as_guest) do
    as_guest_without_account('email@example.com')
  end
  let(:authenticate_as_guest_with_account) do
    as_guest_with_account
  end
  let(:authenticate_as_user) do
    unauthorized_mock(type: 'Group', id: 1, action: 'is_member')
    as_user(1)
  end
  let(:authenticate_as_invitee) do
    unauthorized_mock(type: 'Group', id: 1, action: 'is_member')
    as_user(1, email: 'email@example.com')
  end
  let(:authenticate_as_member) do
    authorized_mock(type: 'Group', id: 1, action: 'is_member')
    create_membership_mock(user_id: 1, group_id: 1, secret: token, response: 304)
    as_user(1, email: 'email@example.com')
  end

  before do
    group_mock(1)
  end

  shared_examples_for 'email token' do
    example 'get as n3' do
      authenticate
      get "/argu/tokens/#{token}", headers: service_headers(accept: :n3)
      expect_get_n3
    end

    example 'post as n3' do
      authenticate
      post "/argu/tokens/#{token}", headers: service_headers(accept: :n3)
      expect_post_n3
    end
  end

  context 'with invalid token' do
    let(:token) { 'invalid_token' }

    context 'with guest' do
      let(:authenticate) { authenticate_as_guest }
      let(:expect_get_n3) do
        expect_post_n3
      end
      let(:expect_post_n3) do
        expect(response.code).to eq('404')
      end

      it_behaves_like 'email token'
    end

    context 'with guest with account' do
      let(:authenticate) { authenticate_as_guest_with_account }
      let(:expect_get_n3) do
        expect_post_n3
      end
      let(:expect_post_n3) do
        expect(response.code).to eq('404')
      end

      it_behaves_like 'email token'
    end

    context 'with user' do
      let(:authenticate) { authenticate_as_user }
      let(:expect_get_n3) do
        expect_post_n3
      end
      let(:expect_post_n3) do
        expect(response.code).to eq('404')
      end

      it_behaves_like 'email token'
    end

    context 'with invitee' do
      let(:authenticate) { authenticate_as_invitee }
      let(:expect_get_n3) do
        expect_post_n3
      end
      let(:expect_post_n3) do
        expect(response.code).to eq('404')
      end

      it_behaves_like 'email token'
    end

    context 'with member' do
      let(:authenticate) { authenticate_as_member }
      let(:expect_get_n3) do
        expect_post_n3
      end
      let(:expect_post_n3) do
        expect(response.code).to eq('404')
      end

      it_behaves_like 'email token'
    end
  end

  context 'with inactive token' do
    let(:token) { [retracted_token, expired_token, used_token].sample.secret }

    context 'with guest' do
      let(:authenticate) { authenticate_as_guest }
      let(:expect_get_n3) do
        expect_post_n3
      end
      let(:expect_post_n3) do
        expect(response.code).to eq('404')
      end

      it_behaves_like 'email token'
    end

    context 'with guest with account' do
      let(:authenticate) { authenticate_as_guest_with_account }
      let(:expect_get_n3) do
        expect_post_n3
      end
      let(:expect_post_n3) do
        expect(response.code).to eq('404')
      end

      it_behaves_like 'email token'
    end

    context 'with user' do
      let(:authenticate) { authenticate_as_user }
      let(:expect_get_n3) do
        expect_post_n3
      end
      let(:expect_post_n3) do
        expect(response.code).to eq('404')
      end

      it_behaves_like 'email token'
    end

    context 'with invitee' do
      let(:authenticate) { authenticate_as_invitee }
      let(:expect_get_n3) do
        expect_post_n3
      end
      let(:expect_post_n3) do
        expect(response.code).to eq('404')
      end

      it_behaves_like 'email token'
    end

    context 'with member' do
      let(:authenticate) { authenticate_as_member }
      let(:expect_get_n3) do
        expect_post_n3
      end
      let(:expect_post_n3) do
        expect(response.code).to eq('200')
        expect_snackbar('You are already member of this group')
        expect_redirect(resource_iri(argu_url))
      end

      it_behaves_like 'email token'
    end
  end

  context 'with retracted token with authorized r' do
    let(:token) { retracted_token_with_r.secret }

    before do
      authorized_mock(action: 'show', iri: 'https://example.com')
    end

    context 'with guest' do
      let(:authenticate) { authenticate_as_guest }
      let(:expect_get_n3) do
        expect_post_n3
      end
      let(:expect_post_n3) do
        expect(response.code).to eq('302')
        expect(response).to redirect_to('https://example.com')
      end

      it_behaves_like 'email token'
    end

    context 'with guest with account' do
      let(:authenticate) { authenticate_as_guest_with_account }
      let(:expect_get_n3) do
        expect_post_n3
      end
      let(:expect_post_n3) do
        expect(response.code).to eq('302')
        expect(response).to redirect_to('https://example.com')
      end

      it_behaves_like 'email token'
    end

    context 'with user' do
      let(:authenticate) { authenticate_as_user }
      let(:expect_get_n3) do
        expect_post_n3
      end
      let(:expect_post_n3) do
        expect(response.code).to eq('302')
        expect(response).to redirect_to('https://example.com')
      end

      it_behaves_like 'email token'
    end

    context 'with invitee' do
      let(:authenticate) { authenticate_as_invitee }
      let(:expect_get_n3) do
        expect_post_n3
      end
      let(:expect_post_n3) do
        expect(response.code).to eq('302')
        expect(response).to redirect_to('https://example.com')
      end

      it_behaves_like 'email token'
    end

    context 'with member' do
      let(:authenticate) { authenticate_as_member }
      let(:expect_get_n3) do
        expect_post_n3
      end
      let(:expect_post_n3) do
        expect_token_not_used(token_with_r)

        expect(response.code).to eq('200')
        expect_snackbar('You are already member of this group')
        expect_redirect('https://example.com')
      end

      it_behaves_like 'email token'
    end
  end

  context 'with retracted token with unauthorized r' do
    let(:token) { retracted_token_with_r.secret }

    before do
      unauthorized_mock(action: 'show', iri: 'https://example.com')
    end

    context 'with guest' do
      let(:authenticate) { authenticate_as_guest }
      let(:expect_get_n3) do
        expect_post_n3
      end
      let(:expect_post_n3) do
        expect(response.code).to eq('404')
      end

      it_behaves_like 'email token'
    end

    context 'with guest with account' do
      let(:authenticate) { authenticate_as_guest_with_account }
      let(:expect_get_n3) do
        expect_post_n3
      end
      let(:expect_post_n3) do
        expect(response.code).to eq('404')
      end

      it_behaves_like 'email token'
    end

    context 'with user' do
      let(:authenticate) { authenticate_as_user }
      let(:expect_get_n3) do
        expect_post_n3
      end
      let(:expect_post_n3) do
        expect(response.code).to eq('404')
      end

      it_behaves_like 'email token'
    end

    context 'with invitee' do
      let(:authenticate) { authenticate_as_invitee }
      let(:expect_get_n3) do
        expect_post_n3
      end
      let(:expect_post_n3) do
        expect(response.code).to eq('404')
      end

      it_behaves_like 'email token'
    end

    context 'with member' do
      let(:authenticate) { authenticate_as_member }
      let(:expect_get_n3) do
        expect_post_n3
      end
      let(:expect_post_n3) do
        expect_token_not_used(token_with_r)

        expect(response.code).to eq('200')
        expect_snackbar('You are already member of this group')
        expect_redirect('https://example.com')
      end

      it_behaves_like 'email token'
    end
  end

  context 'with valid token with authorized r' do
    let(:token) { token_with_r.secret }

    before do
      authorized_mock(action: 'show', iri: 'https://example.com')
    end

    context 'with guest' do
      let(:authenticate) { authenticate_as_guest }
      let(:expect_get_n3) do
        expect_post_n3
      end
      let(:expect_post_n3) do
        expect(response.code).to eq('200')
      end

      before do
        confirm_email_mock(valid_token.email)
        create_membership_mock(user_id: 1, group_id: 1, secret: token)
        emails_mock('tokens', token_with_r.id)
        email_check_mock(valid_token.email, true)
      end

      it_behaves_like 'email token'
    end

    context 'with guest with account' do
      let(:authenticate) { authenticate_as_guest_with_account }
      let(:expect_get_n3) do
        expect_post_n3
      end
      let(:expect_post_n3) do
        expect(response.code).to eq('200')
      end

      before do
        confirm_email_mock(valid_token.email)
        create_membership_mock(user_id: 1, group_id: 1, secret: token)
        emails_mock('tokens', token_with_r.id)
        email_check_mock(valid_token.email, true)
      end

      it_behaves_like 'email token'
    end

    context 'with user' do
      let(:authenticate) { authenticate_as_user }
      let(:expect_get_n3) do
        expect_token_not_used(token_with_r)
        expect(response.code).to eq('200')
        expect_redirect(wrong_email_location(token_with_r))
      end
      let(:expect_post_n3) do
        expect_token_not_used(token_with_r)
        expect(response.code).to eq('200')
        expect_redirect(wrong_email_location(token_with_r))
      end

      before do
        create_membership_mock(user_id: 1, group_id: 1, secret: token)
      end

      it_behaves_like 'email token'
    end

    context 'with invitee' do
      let(:authenticate) { authenticate_as_invitee }
      let(:expect_get_n3) do
        expect_token_not_used(token_with_r)
        expect(response.code).to eq('200')
        expect_no_redirect
      end
      let(:expect_post_n3) do
        expect_token_used(token_with_r)
        expect(response.code).to eq('200')
        expect_snackbar('You have joined the group \'group_name\'')
        expect_redirect('https://example.com')
      end

      before do
        create_membership_mock(user_id: 1, group_id: 1, secret: token)
        emails_mock('tokens', token_with_r.id)
      end

      it_behaves_like 'email token'
    end

    context 'with member' do
      let(:authenticate) { authenticate_as_member }
      let(:expect_get_n3) do
        expect_token_not_used(token_with_r)
        expect(response.code).to eq('200')
        expect_no_redirect
      end
      let(:expect_post_n3) do
        expect_token_not_used(token_with_r)

        expect(response.code).to eq('200')
        expect_snackbar('You are already member of this group')
        expect_redirect('https://example.com')
      end

      before do
        emails_mock('tokens', token_with_r.id)
      end

      it_behaves_like 'email token'
    end
  end

  context 'with valid token' do
    let(:token) { valid_token.secret }

    context 'with guest' do
      let(:authenticate) { authenticate_as_guest }
      let(:expect_get_n3) do
        expect_post_n3
      end
      let(:expect_post_n3) do
        expect(response.code).to eq('200')
      end

      before do
        confirm_email_mock(valid_token.email)
        create_membership_mock(user_id: 1, group_id: 1, secret: token)
        emails_mock('tokens', valid_token.id)
        email_check_mock(valid_token.email, true)
      end

      it_behaves_like 'email token'
    end

    context 'with guest with account' do
      let(:authenticate) { authenticate_as_guest_with_account }
      let(:expect_get_n3) do
        expect_post_n3
      end
      let(:expect_post_n3) do
        expect(response.code).to eq('200')
      end

      before do
        confirm_email_mock(valid_token.email)
        create_membership_mock(user_id: 1, group_id: 1, secret: token)
        emails_mock('tokens', valid_token.id)
        email_check_mock(valid_token.email, true)
      end

      it_behaves_like 'email token'
    end

    context 'with user' do
      let(:authenticate) { authenticate_as_user }
      let(:expect_get_n3) do
        expect_token_not_used(valid_token)
        expect(response.code).to eq('200')
        expect_redirect(wrong_email_location(valid_token))
      end
      let(:expect_post_n3) do
        expect_token_not_used(valid_token)
        expect(response.code).to eq('200')
        expect_redirect(wrong_email_location(valid_token))
      end

      before do
        create_membership_mock(user_id: 1, group_id: 1, secret: token)
      end

      it_behaves_like 'email token'
    end

    context 'with invitee' do
      let(:authenticate) { authenticate_as_invitee }
      let(:expect_get_n3) do
        expect_token_not_used(valid_token)
        expect(response.code).to eq('200')
        expect_no_redirect
      end
      let(:expect_post_n3) do
        expect_token_used(valid_token)

        expect(response.code).to eq('200')
        expect_snackbar('You have joined the group \'group_name\'')
        expect_redirect(resource_iri(argu_url('/group_memberships/1')))
      end

      before do
        create_membership_mock(user_id: 1, group_id: 1, secret: token)
        emails_mock('tokens', valid_token.id)
      end

      it_behaves_like 'email token'
    end

    context 'with member' do
      let(:authenticate) { authenticate_as_member }
      let(:expect_get_n3) do
        expect_token_not_used(valid_token)
        expect(response.code).to eq('200')
        expect_no_redirect
      end
      let(:expect_post_n3) do
        expect_token_not_used(valid_token)

        expect(response.code).to eq('200')
        expect_snackbar('You are already member of this group')
        expect_redirect(resource_iri(argu_url('/group_memberships/1')))
      end

      before do
        emails_mock('tokens', valid_token.id)
      end

      it_behaves_like 'email token'
    end
  end

  it 'user should 500 when failed to create membership' do
    authenticate_as_invitee
    create_membership_mock(user_id: 1, group_id: 1, secret: valid_token.secret, response: 403)
    post "/argu/tokens/#{valid_token.secret}", headers: service_headers(accept: :n3)

    expect(response.code).to eq('500')
  end

  private

  def expect_no_redirect
    expect(response.headers['Exec-Action'] || '').not_to(
      include('actions/redirect')
    )
  end

  def expect_snackbar(text)
    expect(response.headers['Exec-Action']).to(
      include("actions/snackbar?#{{text: text}.to_param.gsub('+', '%20')}")
    )
  end

  def expect_redirect(location)
    expect(response.headers['Exec-Action']).to(
      include("actions/redirect?#{{location: location}.to_param}")
    )
  end

  def expect_token_not_used(token)
    expect(token.reload.last_used_at).to be_nil
    expect(token.reload.usages).to eq(0)
  end

  def expect_token_used(token)
    expect(token.reload.last_used_at).to be_truthy
    expect(token.reload.usages).to eq(1)
  end

  def wrong_email_location(token)
    resource_iri(argu_url("/tokens/#{token.secret}/email_conflict"))
  end
end
