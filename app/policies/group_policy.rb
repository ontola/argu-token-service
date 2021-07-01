# frozen_string_literal: true

class GroupPolicy < RestrictivePolicy
  def show?
    true
  end
end
