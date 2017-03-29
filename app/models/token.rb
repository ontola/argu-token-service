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
  before_create :generate_token
  after_commit :publish_data_event

  def active?
    retracted_at.nil? && (expires_at.nil? || expires_at > DateTime.current) && (max_usages.nil? || usages < max_usages)
  end

  def context_id
    Rails.application.routes.url_helpers.token_url(secret, protocol: :https)
  end

  def generate_token
    self.secret = email.present? ? SecureRandom.urlsafe_base64(128) : SecureRandom.base58(24) unless secret?
  end

  def publish_data_event
    DataEvent.publish(self)
  end

  def to_param
    secret
  end

  def update_usage!
    increment(:usages)
    update!(last_used_at: DateTime.current)
  end

  def emails
    return [] if previous_changes['id']&.first.nil? && previous_changes['id']&.second.present?
    @emails ||= Email.where(
      resource_id: id,
      resource_type: 'tokens',
      event: 'create'
    )
  end
end
