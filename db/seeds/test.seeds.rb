# frozen_string_literal: true

require_relative '../../spec/support/test_root_id'

Tenant.create('argu')

Apartment::Tenant.switch('argu') do # rubocop:disable Metrics/BlockLength
  Token.create!(
    secret: 'valid_bearer_token',
    group_id: 111,
    redirect_url: 'https://argu.localtest/argu/holland',
    root_id: TEST_ROOT_ID
  )
  Token.create!(
    secret: 'expired_bearer_token',
    group_id: 111,
    redirect_url: 'https://argu.localtest/argu/holland',
    expires_at: 1.hour.ago,
    root_id: TEST_ROOT_ID
  )
  Token.create!(
    secret: 'valid_email_token',
    group_id: 111,
    redirect_url: 'https://argu.localtest/argu/holland',
    email: 'invitee@example.com',
    invitee: 'invitee@example.com',
    max_usages: 1,
    root_id: TEST_ROOT_ID
  )
  Token.create!(
    secret: 'expired_email_token',
    group_id: 111,
    redirect_url: 'https://argu.localtest/argu/holland',
    email: 'invitee@example.com',
    invitee: 'invitee@example.com',
    expires_at: 1.hour.ago,
    max_usages: 1,
    root_id: TEST_ROOT_ID
  )
  Token.create!(
    secret: 'user_email_token',
    group_id: 111,
    redirect_url: 'https://argu.localtest/argu/holland',
    email: 'user1@example.com',
    invitee: 'user1@example.com',
    max_usages: 1,
    root_id: TEST_ROOT_ID
  )
  Token.create!(
    secret: 'used_email_token',
    group_id: 111,
    redirect_url: 'https://argu.localtest/argu/holland',
    email: 'user1@example.com',
    invitee: 'user1@example.com',
    last_used_at: 1.hour.ago,
    usages: 1,
    max_usages: 1,
    root_id: TEST_ROOT_ID
  )
  Token.create!(
    secret: 'member_email_token',
    group_id: 111,
    redirect_url: 'https://argu.localtest/argu/holland',
    email: 'member@example.com',
    invitee: 'member@example.com',
    max_usages: 1,
    root_id: TEST_ROOT_ID
  )
end
