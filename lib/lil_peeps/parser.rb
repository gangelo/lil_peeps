# frozen_string_literal: true

require_relative 'parsable'

module LilPeeps
  # Helper method to parse command line arguments.
  #
  # Pass the args to the initializer and call #find providing the
  # option(s) you are looking for and the default(s) to provide
  # if the option is missing, or, if any of the option(s) arguments
  # required are missing. If duplicate options are found, the last
  # option wins; the rest are discarded.
  class Parser
    include Parsable

    def initialize(args, options = {})
      self.args = args.dup
      self.options = options || {}
    end
  end
end
