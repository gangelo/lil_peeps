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
    # <option_argument_defaults>: the default values for the option argument
    # list if the arguments for the option are not found. For example, if
    # "-g <type> is expected and only "-g" is encountered,
    # "-g <option_argument_defaults[0]>" will be used.
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
    def find(option_variants, option_argument_defaults = [], &block)
      raise ArgumentError, 'Param [option_variants] is nil' if option_variants.nil?

      # Ensures that <option_variants> is an Array
      option_variants = ensure_array(option_variants)

      # Ensures that <option_argument_defaults> is an Array necessary for
      # generic processing of option argument default values
      option_argument_defaults = ensure_array(option_argument_defaults)

      parsed_args = parse(args)

      # Find the first option variant occurrance in the option_variants list
      option = find_option_variant(option_variants, parsed_args)

      if option.nil?
        option_not_found(normalize_option_variant(option_variants.first), option_argument_defaults, &block)
      else
        option_found(option, option_argument_defaults, &block)
      end
    end

    # Returns the first option occurrance found in the <parsed_args> OpenStruct
    def find_option_variant(option_variants, parsed_args)
      option_variants.each do |option_variant|
        option_variant = parsed_args[option_variant_to_sym(option_variant)]
        return option_variant unless option_variant.nil?
      end
      nil
    end

    # This member processes options that are found.
    #
    # Params
    #
    # <option_indicies> = the index of each option occurance within #args.
    # Under normal circumstances, there should only be one occurance unless
    # more than one option can be found within #args.
    #
    # <option_argument_defaults> = the defaults that should be provided for each
    # option argument that is not found.
    #
    # <option_argument_defaults>.count is used to determine the number of
    # arguments that are expected for the option represented by
    # <option_indicies>.
    def option_found(option, option_argument_defaults, &block)
      raise ArgumentError, 'Param [option] is nil' if option.nil?
      raise ArgumentError, 'Param [option_argument_defaults] is nil' if option_argument_defaults.nil?

      option_args = option[:args].slice(0, option_argument_defaults.count)

      # If there are any arguments missing, replace the missing argument with
      # the option_argument_defaults provided
      (option_args.count...option_argument_defaults.count).each { |i| option_args << option_argument_defaults[i] }

      # Return the status (found/not found), the option that was found, and the
      # option arguments; use the splat (*) operator on the option_args as a
      # convenience so that the option args are returned individually as opposed
      # to an array of args. This makes things more readable on the receiver's
      # end.
      return_results(true, option[:option], *option_args, &block)
    end

    # This member processes options that are not found.
    def option_not_found(option, option_argument_defaults, &block)
      raise ArgumentError, 'Param [option] is nil' if option.nil?
      raise ArgumentError, 'Param [option_argument_defaults] is nil' if option_argument_defaults.nil?

      # If the option is missing, return everything passed to us along with a
      # status of false (option missing)
      return_results(false, option, *option_argument_defaults, &block)
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
      raise ArgumentError, 'Param [value] is not a Hash' unless value.is_a?(Hash)

      @options = value.dup.extend(ParserOptions)
    end

    def option_and_option_args(arg_string)
      options_and_option_args = arg_string.split
      [options_and_option_args[0], options_and_option_args[1..-1]]
    end

    def option_and_option_hash(option_and_option_args_string)
      option, option_args = option_and_option_args(option_and_option_args_string)
      args_hash = if option_args.nil?
                    {}
                  else
                    option_args.each_with_index.each_with_object({}) do |(arg, index), hash|
                      hash["arg#{index}".to_sym] = arg
                    end
                  end
      [option.to_sym, { option: option, args: option_args }.merge(args_hash)]
    end

    def option_variant_to_sym(option_variant)
      normalize_option_variant(option_variant).to_sym
    end

    def normalize_option_variant(option_variant)
      # Remove leading '-'
      option_variant.gsub(/\A-+/, '')
    end

    def parse(args)
      args_strings = args.join(' ').split(/(\A|\s)-+/).reject do |a|
        a.strip!
        a.empty?
      end
      parsed_args = {}
      args_strings.map do |arg_string|
        option, option_hash = option_and_option_hash(arg_string)
        parsed_args[option] = option_hash
      end
      parsed_args
    end

    def return_results(option_found, option, *values)
      raise ArgumentError, 'Param [option_found] is nil' if option_found.nil?
      raise ArgumentError, 'Param [option_found] not true or false' unless [true, false].include?(option_found)

      results = [option_found, option, *values]
      return results unless block_given?

      values = yield(*results)
      [option_found, option, *values]
    end

    protected :args, :args=, :clean!, :ensure_array, :find_option_variant, :normalize_option_variant, :option_found,
              :option?, :options, :options=, :option_variant_to_sym, :parse, :return_results
  end
end
