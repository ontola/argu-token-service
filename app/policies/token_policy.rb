# frozen_string_literal: true

class TokenPolicy
  class Scope
    attr_reader :context, :scope

    def initialize(context, scope)
      @context = context
      @scope = scope
    end

    def resolve
      scope.active.where('last_used_at IS NULL OR email IS NULL')
    end
  end
end
