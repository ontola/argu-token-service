# frozen_string_literal: true

class GroupPolicy < RestrictivePolicy
  include ChildHelper
  include LinkedRails::Policy

  private

  def child_policy(raw_klass)
    klass = raw_klass.constantize
    return unless klass <= Token

    Pundit.policy(user_context, child_instance(record, klass))
  end
end
