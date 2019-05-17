# frozen_string_literal: true

require_relative 'lil_peeps/parser'
require_relative 'lil_peeps/version'

# This module provides an interface to the Parser
module LilPeeps
  def self.create(args, options = {})
    Parser.new(args, options)
  end
end
