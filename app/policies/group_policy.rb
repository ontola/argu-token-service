# frozen_string_literal: true

class GroupPolicy < RestrictivePolicy
  def create_child?(raw_klass)
    return false unless %i[bearer_tokens email_tokens].include?(raw_klass)

    Pundit.policy(context, Token.new(group_id: record.id)).create?
  end
end
