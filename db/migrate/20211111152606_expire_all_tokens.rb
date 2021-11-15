class ExpireAllTokens < ActiveRecord::Migration[6.0]
  def change
    BearerToken.where(expires_at: nil).update_all(expires_at: 1.week.from_now)
  end
end
