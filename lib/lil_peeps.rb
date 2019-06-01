# frozen_string_literal: true

require_relative 'lil_peeps/parser'
require_relative 'lil_peeps/version'

# This module provides an interface to the Parser
module LilPeeps
  # Creates an instance of the LilPeeps::Parser.
  #
  # @param [String] args the arguments to be parsed.
  #
  # @param [Hash] options the options to pass to the Parser.
  # @option options [Regexp] :option_regex (nil) provides an override of the regular expression used by {Parser} to
  #   identify options within an argument string (see {Parser#option_regex})
  #
  # @return [Parser]
  #
  # @example
  #
  #  # Creates an instance of the LilPeeps::Parser
  #  LilPeeps.create('-o --option --debug --option-with-args arg1 arg2 arg3') # => Parser
  def self.create(args, options = {})
    Parser.new(args, options)
  end
end
