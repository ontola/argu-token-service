# frozen_string_literal: true

class EmailTokenController < TokensController
  def index
    render json: Token.email.active.where(last_used_at: nil, group_id: group_id), include: {emails: :email_events}
  end

  private

  def group_id
    @group_id ||= params.fetch(:group_id)
  end
end
