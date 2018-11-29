# frozen_string_literal: true

class TokenPolicy < RestrictivePolicy
  class Scope < Scope
    def resolve
      scope.active.where('last_used_at IS NULL OR email IS NULL')
    end
  end

  def create?
    update_group? && valid_actor?
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
      context.api.authorize_action(resource_type: 'Group', resource_id: record.group_id, action: 'update')
  end

  def valid_actor?
    return true if record.actor_iri.blank?
    @valid_actor ||=
      context.api.authorize_action(resource_type: 'CurrentActor', resource_id: record.actor_iri, action: 'show')
  end
end
