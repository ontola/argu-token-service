# frozen_string_literal: true

class EmailToken < Token
  enhance Createable
  enhance Destroyable
  enhance Actionable
end
