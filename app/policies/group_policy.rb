# frozen_string_literal: true

class GroupPolicy < RestrictivePolicy
  include ChildHelper

  def create_child?(raw_klass)
    return false unless %i[bearer_tokens email_tokens].include?(raw_klass)

    Pundit.policy(context, child_instance(record, raw_klass.to_s.classify.constantize)).create?
  end
end
