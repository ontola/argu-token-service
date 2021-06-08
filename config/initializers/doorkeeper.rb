# frozen_string_literal: true

module Doorkeeper
  class AccessToken
    attr_accessor :scopes

    def initialize(scopes: nil)
      self.scopes = scopes
    end
  end
end
