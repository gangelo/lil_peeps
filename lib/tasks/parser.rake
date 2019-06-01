# frozen_string_literal: true

require 'rake'

namespace :parser do
  desc "Play with the Lil' Peeps Parser."
  task :create, [:args, :option_argument_defaults, :find] do |_task, args|
    args.with_defaults(
      args: '--test arg1 arg2',
      option_argument_defaults: 'def1 def2 def3',
      find: '--test'
    )
    require 'colorize'
    require 'lil_peeps'

    if %w[-h --help].include?(args[:args])
      help = <<~DESC
        Play with the Lil' Peeps Parser.
        Examples:
        # Here, only 2 arguments to the option --test are provided; therefore, the option argument
        # will be returned as 'arg1', 'arg2', 'def3' as the default values replace any missing,
        # expected option arguments
        parser:create['--test arg1 arg2', 'def1 def2 def3', '--test'] # => [true, 'test', 'arg1', 'arg2', 'def3']
        # Here, the option '-d' was provided with no option arguments; however, the option '-x' was expected;
        # therefore, false will be returned because the option was not found; however, the defaults will be
        # provided
        parser:create['-d','def1 def2','-x'] # => [false, "x", "def1", "def2"]
      DESC
      puts help.red
    else
      parser_args = args[:args].split
      parser_option_argument_defaults = args[:option_argument_defaults].split
      parser_find = args[:find].split

      puts 'Calling LilPeeps::create using...'.red
      puts "\targs: #{parser_args}"
      puts "\toptions: {}"
      parser = LilPeeps.create(parser_args)

      puts 'Calling LilPeeps::Parser#find using...'.red
      puts "\toption_variants: #{parser_find}"
      puts "\toption_argument_defaults: #{parser_option_argument_defaults}"
      puts "\n#find # => #{parser.find(parser_find, parser_option_argument_defaults)}".red
    end
  end
end
