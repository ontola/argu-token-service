# frozen_string_literal: true

Token.create!(
  secret: 'valid_bearer_token',
  group_id: 111,
  redirect_url: 'https://argu.co/holland'
)
Token.create!(
  secret: 'expired_bearer_token',
  group_id: 111,
  redirect_url: 'https://argu.co/holland',
  expires_at: 1.hour.ago
)
Token.create!(
  secret: 'valid_email_token',
  group_id: 111,
  redirect_url: 'https://argu.co/holland',
  email: 'invitee@argu.co',
  invitee: 'invitee@argu.co',
  max_usages: 1
)
Token.create!(
  secret: 'expired_email_token',
  group_id: 111,
  redirect_url: 'https://argu.co/holland',
  email: 'invitee@argu.co',
  invitee: 'invitee@argu.co',
  expires_at: 1.hour.ago,
  max_usages: 1
)
Token.create!(
  secret: 'used_email_token',
  group_id: 111,
  redirect_url: 'https://argu.co/holland',
  email: 'user1@argu.co',
  invitee: 'user1@argu.co',
  last_used_at: 1.hour.ago,
  usages: 1,
  max_usages: 1
)
