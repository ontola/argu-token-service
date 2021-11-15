# frozen_string_literal: true

class TokenPolicy < RestrictivePolicy
  class Scope < Scope
    def resolve
      scope.active.where('last_used_at IS NULL OR email IS NULL')
    end
  end

  def accept?
    show?
  end

  def create?
    update_group?
  end

  def destroy?
    update_group?
  end

  def index?
    update_group?
  end

  def show?
    true
  end

  def update?
    update_group?
  end

  private

  def update_group?
    @update_group ||=
      !user_context.guest? &&
      user_context.api.authorize_action(resource_type: 'Group', resource_id: record.group_id, action: 'update')
  end
end
