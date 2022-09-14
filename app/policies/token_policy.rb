# frozen_string_literal: true

class TokenPolicy < RestrictivePolicy
  include URITemplateHelper

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
    index_group_memberships?
  end

  def show?
    true
  end

  def update?
    update_group?
  end

  private

  def update_group?
    return false if record.group_id.blank?

    @update_group ||=
      !user_context.guest? &&
      api_authorization(
        resource_type: 'Group',
        resource_id: record.group_id, action: 'update'
      )
  end

  def index_group_memberships?
    return false if record.group_id.blank?

    @index_group_memberships ||=
      !user_context.guest? && api_authorization(
        action: :show,
        resource_iri: iri_from_template(:group_memberships_iri, parent_iri: record.group.iri_elements)
      )
  end
end
