# frozen_string_literal: true
class BearerTokenController < TokensController
  def index
    render json: Token.bearer.active.where(group_id: group_id), include: {emails: :email_events}
  end

  private

  def group_id
    @group_id ||= params.fetch(:group_id)
  end
end
