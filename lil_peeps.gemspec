# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lil_peeps/version'

Gem::Specification.new do |spec|
  spec.name          = 'lil_peeps'
  spec.version       = LilPeeps::VERSION
  spec.authors       = ['Gene M. Angelo, Jr.']
  spec.email         = ['public.gma@gmail.com']

  spec.summary       = "Lil' Peeps Options Parser."
  spec.description   = "Use Lil' Peeps to parse Array options."
  spec.homepage      = 'https://github.com/gangelo/lil_peeps'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = 'TODO: Set to 'http://mygemserver.com''
  # else
  #   raise 'RubyGems 2.0 or newer is required to protect against ' \
  #     'public gem pushes.'
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'activesupport', '~> 5.0', '>= 5.0.0.1'
  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'colorize'
  spec.add_development_dependency 'pry-byebug', '~> 3.7'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rdoc'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-performance'
  spec.add_development_dependency 'yard'

  spec.required_ruby_version = '>= 2.2.2'
end
