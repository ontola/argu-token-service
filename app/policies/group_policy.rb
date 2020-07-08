# frozen_string_literal: true

class GroupPolicy < RestrictivePolicy
  include ChildHelper
  include LinkedRails::Policy
end
