# frozen_string_literal: true

require_relative 'parser_options'

module LilPeeps
  # Helper method to parse command line arguments.
  #
  # Pass the args to the initializer and call #find providing the option(s) you
  # are looking for and the default(s) to provide if the option is missing, or,
  # if any of the option(s) arguments required are missing. If duplicate option
  # are found, the last option wins; the rest are discarded.
  module Parsable
    include ParserOptions

    OPTION_REGEX = /\A-+.*\z/.freeze

    attr_accessor :args

    # Removes any option arguments that are option.
    #
    # For example, if an option requires the following format:
    #
    # --option1 o1a o1b
    #
    # but the user entered...
    #
    # --option1 o1a --option2 o2a
    #
    # This method would receive %w(ola --option2). Because we know --option2
    # isn't an argument of --option1 (it is a whole other option altogether), it
    # should be discarded. Consequently, this method removes --option2 from the
    # passed <option_args> Array.
    def clean!(option_args)
      option_args.delete_if { |option_arg| option?(option_arg) }
    end

    # Ensures that <object> is an Array
    def ensure_array(object)
      return [] if object.nil?

      object.is_a?(Array) ? object : [object]
    end

    # Finds the option in #args and return the option argument(s)
    # provided.
    #
    # PARAMS
    #
    # <option>: the option list to look for (e.g. %w(-g --group-by))
    # <argument_defaults>: the default values for the option argument list if
    # the arguments for the option are not found. For example, if
    # "-g <type> is expected and only "-g" is encountered,
    # "-g <argument_defaults[0]>" will be used.
    #
    # RETURN
    #
    # Returns the status (found/not found), the option that was found,
    # and the option arguments; use the splat (*) operator on the
    # option_args as a convenience so that the option args are returned
    # individually as opposed to an array of args.
    #
    # EXAMPLES
    #
    # Assuming the option is found:
    # status, option, arg1, arg2 = find(%w(--test -t), %w(def1 def2))
    # # => true, '-t', 'arg1', 'arg2'
    #
    # Assuming the option is not found:
    # status, option, debug = find(['--debug', '-d'], 'false') do |_, _, value|
    #                           value == 'true'
    #                         end
    # When the option is not found, <option> will return the last option in the
    # <option> Array:
    # # => false, '-d', false
    def find(option, argument_defaults = [], &block)
      raise ArgumentError, 'Param [option] is nil' if option.nil?

      args = self.args.dup

      # Ensures that <option> is an Array
      option = ensure_array(option)

      # Ensures that <argument_defaults> is an Array necessary for generic
      # processing of default option argument values
      argument_defaults = ensure_array(argument_defaults)

      # Find the indicies of every occurrance of option found in the option
      # list...
      option_indicies = select_option_indicies(option, args)

      if option_indicies.empty?
        option_not_found(option, argument_defaults, &block)
      else
        option_found(option_indicies, argument_defaults, &block)
      end
    end

    # This member processes options that are found.
    #
    # Params
    #
    # <option_indicies> = the index of each option occurance within #args.
    # Under normal circumstances, there should only be one occurance unless
    # more than one option can be found within #args.
    #
    # <argument_defaults> = the defaults that should be provided for each
    # option argument that is not found.
    #
    # <argument_defaults>.count is used to determine the number of arguments
    # that are expected for the option represented by <option_indicies>.
    def option_found(option_indicies, argument_defaults, &block)
      raise ArgumentError, 'Param [option_indicies] is nil' \
        if option_indicies.nil?
      raise ArgumentError, 'Param [option_indicies] is not an Array' \
        unless option_indicies.is_a?(Array)
      raise ArgumentError, 'Param [argument_defaults] is nil' \
        if argument_defaults.nil?

      # Last occurance of the option wins..
      option_index = option_indicies.pop

      # Get the option found and the option arguments provided...
      option = args[option_index]

      option_args = args.slice(option_index + 1, argument_defaults.count)

      # Clean up (remove) any arguments that may actually be option (i.e. that
      # begin with '-'' or '--'); this may occur if the user failed to provide
      # all the required option arguments.
      clean!(option_args)

      # If there are any arguments missing, replace the missing argument with
      # the argument_defaults provided
      (option_args.count...argument_defaults.count).each do |i|
        option_args << argument_defaults[i]
      end

      # Return the status (found/not found), the option that was found, and the
      # option arguments; use the splat (*) operator on the option_args as a
      # convenience so that the option args are returned individually as opposed
      # to an array of args. This makes things more readable on the receiver's
      # end.
      return_results(true, option, *option_args, &block)
    end

    # This member processes options that are not found.
    def option_not_found(option, argument_defaults, &block)
      raise ArgumentError, 'Param [option] is nil' if option.nil?
      raise ArgumentError, 'Param [option] is not an Array' \
        unless option.is_a?(Array)
      raise ArgumentError, 'Param [argument_defaults] is nil' \
        if argument_defaults.nil?

      # If the option is missing, return everything passed to us along with a
      # status of false (option missing)
      return_results(false, option.last, *argument_defaults, &block)
    end

    # Returns true if <option_arg> is an option, false otherwise
    def option?(option_arg)
      option_regex = options.option_regex || OPTION_REGEX
      option_arg =~ option_regex
    end

    def options
      @options ||= {}.extend(ParserOptions)
    end

    def options=(value)
      raise ArgumentError, 'Param [value] is nil' if value.nil?
      raise ArgumentError, 'Param [value] is not a Hash' \
        unless value.is_a?(Hash)

      @options = value.dup.extend(ParserOptions)
    end

    def return_results(option_found, option, *values)
      raise ArgumentError, 'Param [option_found] is nil' if option_found.nil?
      raise ArgumentError, 'Param [option_found] not true or false' \
        unless [true, false].include?(option_found)

      results = [option_found, option, *values]
      return results unless block_given?

      values = yield(*results)
      [option_found, option, *values]
    end

    # Returns the indicies of every <option> occurrance found in the <args>
    # Array
    def select_option_indicies(option, args)
      args.each_index.select { |index| option.include?(args[index]) }
    end

    protected :args,
              :args=,
              :clean!,
              :ensure_array,
              :option_found,
              :option?,
              :options,
              :options=,
              :return_results,
              :select_option_indicies
  end
end
