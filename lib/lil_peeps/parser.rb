# frozen_string_literal: true

require_relative 'parsable'

module LilPeeps
  # Helper method to parse command line arguments. Pass the args to the initializer and call #find providing the
  # option variants you are looking for, and any option argument default(s). Option argument defaults will be used
  # in the case that the option and/or any of the option arguments is missing
  class Parser
    include Parsable

    def initialize(args, options = {})
      self.args = args.dup
      self.options = options || {}
    end
  end
end
