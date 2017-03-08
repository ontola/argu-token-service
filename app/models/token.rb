# frozen_string_literal: true
class Token < ApplicationRecord
  scope :active, lambda {
    where('retracted_at IS NULL AND (expires_at IS NULL OR expires_at > ?)'\
          ' AND (max_usages IS NULL OR usages < max_usages)',
          DateTime.current)
  }
  scope :bearer, -> { where(email: nil) }
  scope :email, -> { where('email IS NOT NULL') }
  validates :group_id, presence: true
  has_secure_token :secret

  def active?
    retracted_at.nil? && (expires_at.nil? || expires_at > DateTime.current) && (max_usages.nil? || usages < max_usages)
  end

  def to_param
    secret
  end

  def update_usage!
    increment(:usages)
    update!(last_used_at: DateTime.current)
  end
end
