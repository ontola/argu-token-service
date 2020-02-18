# frozen_string_literal: true

require_relative '../support/test_root_id'

FactoryGirl.define do
  factory :token do
    root_id { TEST_ROOT_ID }
    sequence(:secret) { |n| "correct_token_#{n}" }
    expires_at { 1.day.from_now }
    group_id { 1 }

    factory :retracted_token do
      sequence(:secret) { |n| "retracted_token_#{n}" }
      retracted_at { 1.day.ago }
    end

    factory :expired_token do
      sequence(:secret) { |n| "expired_token_#{n}" }
      expires_at { 1.day.ago }
    end

    factory :used_token do
      sequence(:secret) { |n| "used_token_#{n}" }
      max_usages { 1 }
      usages { 1 }
    end
  end
end
