# frozen_string_literal: true

class EmailConflictPolicy < RestrictivePolicy
  def show?
    true
  end

  def update?
    true
  end
end
