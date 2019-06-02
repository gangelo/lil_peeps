# frozen_string_literal: true

require_relative 'parser_options'

module LilPeeps
  # Helper method to parse command line arguments.
  #
  # Pass the args to the initializer and call #find providing the option(s) you are looking for and the default(s) to
  # provide if the option is missing, or, if any of the option(s) arguments required are missing. If duplicate option
  # are found, the last option wins; the rest are discarded.
  module Parsable
    # The default regex used to identify options as opposed to option arguments
    OPTION_REGEX = /(?=\A|\s-)/.freeze

    attr_accessor :args

    # Ensures that <object> is an Array
    def ensure_array(object)
      return [] if object.nil?

      object.is_a?(Array) ? object : [object]
    end

    # Finds the first occurance of the option variants provided in args and return the option argument(s) provided.
    #
    # @param [Array<String>, String] option_variants the option list to look for (e.g. '-g', %w(-g --group-by))
    #
    # @param [Array<String>, String] option_argument_defaults the default value(s) to use if no option arguments for the
    # option is found. For example, if "-g <type>" is expected and only "-g" is found,
    # "-g <option_argument_defaults[0]>" will be used. #
    #
    # @return [Array<Bool, String>] if no option_argument_defaults are provided. the found status of the option and the
    #    option variant. If any of the option variants are found, a status of true is returned, along with the
    #    option variant found. If none of the option variants are found, a status of false is returned, along with the
    #    first option variant provided (i.e. option_variants[0]).
    #
    # @return [Array<Bool, String, *String>] if option_argument_defaults are provided, the found status of the option,
    #    the option variant, and the option arguments.
    #    If any of the option variants are found, a status of true is returned, along with the
    #    option variant found. If none of the option variants are found, a status of false is returned, along with the
    #    first option variant provided (i.e. option_variants).
    #
    # @examples
    #
    #  # Creates an instance of the LilPeeps::Parser
    #  parser = LilPeeps.create('-o --option --debug --option-with-args arg1 arg2 arg3')
    #
    #  # If an option variant is searched for and no option argument defaults are provided, the status indicates whether
    #  # or not an option variant was present or not (true/false)
    #  parser.find('--debug') # => [true, 'debug']
    #
    #  # However, if option argument defaults are provided, they are used
    #  parser = LilPeeps.create('--debug')
    #  parser.find('--debug', [1, 2, 3]) # => [true, "debug", "1", "2", "3"]
    #
    #  parser = LilPeeps.create('--debug -v --timeout 1500')
    #  parser.find(['-v', '--verbose'], false) # => [true, 'verbose', 'true']
    #  parser.find(['--timeout'], 1500) # => [true, 'timeout', '1500']
    def find(option_variants, option_argument_defaults = [], &block)
      raise ArgumentError, 'Param [option_variants] is nil' if option_variants.nil?

      # Ensures that <option_variants> is an Array
      option_variants = ensure_array(option_variants)

      # Ensures that <option_argument_defaults> is an Array necessary for generic processing of option argument default
      # values
      option_argument_defaults = ensure_array(option_argument_defaults)

      parsed_args = parse(args)

      # Find the first option variant occurrance in the option_variants list
      option_variant = find_option_variant(option_variants, parsed_args)

      if option_variant.nil?
        option_variant_not_found(option_variants[0], option_argument_defaults, &block)
      else
        option_variant_found(option_variant, option_argument_defaults, &block)
      end
    end

    # Returns the first option occurrance found in the <parsed_args> OpenStruct
    def find_option_variant(option_variants, parsed_args)
      option_variants.each do |option_variant|
        option_variant = parsed_args[option_variant.to_sym]
        return option_variant unless option_variant.nil?
      end
      nil
    end

    def option_and_option_args_hash(parse_option_and_option_args_string)
      option, option_arguments = parse_option_and_option_args(parse_option_and_option_args_string)
      option_arguments_hash = if option_arguments.nil?
                                {}
                              else
                                # rubocop:disable Metrics/LineLength
                                option_arguments.each_with_index.each_with_object({}) do |(option_argument, index), hash|
                                  hash["arg#{index}".to_sym] = option_argument
                                end
                                # rubocop:enable Metrics/LineLength
                              end
      [option.to_sym, { option: option, args: option_arguments }.merge(option_arguments_hash)]
    end

    # Returns the regular expression to identify option variants as opposed to option arguments
    def option_regex
      options.option_regex || OPTION_REGEX
    end

    # This member processes options that are found.
    #
    # Params
    #
    # <option_indicies> = the index of each option occurance within #args. # Under normal circumstances, there should
    # only be one occurance unless # more than one option can be found within #args.
    #
    # <option_argument_defaults> = the defaults that should be provided for each option argument that is not found.
    #
    # <option_argument_defaults>.count is used to determine the number of arguments that are expected for the option
    # represented by <option_indicies>.
    def option_variant_found(option_variant, option_argument_defaults, &block)
      raise ArgumentError, 'Param [option_variant] is nil' if option_variant.nil?
      raise ArgumentError, 'Param [option_argument_defaults] is nil' if option_argument_defaults.nil?

      option_args = option_variant[:args].slice(0, option_argument_defaults.count)

      # If there are any arguments missing, replace the missing argument with the option_argument_defaults provided
      (option_args.count...option_argument_defaults.count).each { |i| option_args << option_argument_defaults[i] }

      # Return the status (found/not found), the option_variant that was found, and the option_variant arguments; use
      # the splat (*) operator on the option_args as a convenience so that the option_variant args are returned
      # individually as opposed to an array of args. This makes things more readable on the receiver's end.
      return_results(true, option_variant[:option], *option_args, &block)
    end

    # This member processes options that are not found.
    def option_variant_not_found(option_variant, option_argument_defaults, &block)
      raise ArgumentError, 'Param [option_variant] is nil' if option_variant.nil?
      raise ArgumentError, 'Param [option_argument_defaults] is nil' if option_argument_defaults.nil?

      # If the option_variant is missing, return everything passed to us along with a status of false (option variant
      # missing)
      return_results(false, option_variant, *option_argument_defaults, &block)
    end

    def options
      @options ||= {}.extend(ParserOptions)
    end

    def options=(value)
      raise ArgumentError, 'Param [value] is nil' if value.nil?
      raise ArgumentError, 'Param [value] is not a Hash' unless value.is_a?(Hash)

      @options = value.dup.extend(ParserOptions)
    end

    def parse(args)
      args = args.join(' ')
      args_strings = args.split(option_regex).map(&:strip)
      parsed_args = {}
      args_strings.map do |arg_string|
        option_sym, option_hash = option_and_option_args_hash(arg_string)
        parsed_args[option_sym] = option_hash
      end
      parsed_args
    end

    def parse_option_and_option_args(arg_string)
      options_and_option_args = arg_string.split
      [options_and_option_args[0], options_and_option_args[1..-1]]
    end

    def return_results(option_variant_found, option, *values)
      raise ArgumentError, 'Param [option_variant_found] is nil' if option_variant_found.nil?
      raise ArgumentError, 'Param [option_variant_found] not true or false' \
        unless [true, false].include?(option_variant_found)

      results = [option_variant_found, option, *values]
      return results unless block_given?

      values = yield(*results)
      [option_variant_found, option, *values]
    end

    protected :args, :args=, :ensure_array, :find_option_variant, :option_and_option_args_hash, :option_regex,
              :option_variant_found, :option_variant_not_found, :options, :options=, :parse,
              :parse_option_and_option_args, :return_results
  end
end
