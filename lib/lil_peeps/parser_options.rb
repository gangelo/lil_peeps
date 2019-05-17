# frozen_string_literal: true

module LilPeeps
  # Provides methods for extending  an options Hash
  module ParserOptions
    def option_regex
      self[:option_regex]
    end

    def option_regex?
      key?(:option_regex)
    end
  end
end
