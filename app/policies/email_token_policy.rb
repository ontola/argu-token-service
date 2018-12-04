# frozen_string_literal: true

class EmailTokenPolicy < TokenPolicy
  def permitted_attributes
    %i[addresses creator message redirect_url root_id send_mail]
  end
end
