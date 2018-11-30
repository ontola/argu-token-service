# frozen_string_literal: true

class GroupPolicy < RestrictivePolicy
  def create_child?(raw_klass)
    return false if raw_klass != :tokens

    Pundit.policy(context, Token.new(group_id: record.id)).create?
  end
end
