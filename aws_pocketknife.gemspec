# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aws_pocketknife/version'

Gem::Specification.new do |spec|
  spec.name          = "aws_pocketknife"
  spec.version       = AwsPocketknife::VERSION
  spec.authors       = ["Gustavo Soares Souza"]
  spec.email         = ["gustavosoares@gmail.com"]

  spec.summary       = %q{TODO: Write a short summary, because Rubygems requires one.}
  spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'aws-sdk-core', '~> 2.1'
  spec.add_dependency 'retryable', '~> 2.0'
  spec.add_dependency "rake", "~> 10.0"
  spec.add_dependency "rspec", "~> 3.4"
  spec.add_dependency "webmock", "= 1.24.2"
  spec.add_dependency "erubis", "= 2.7.0"
  spec.add_dependency "pretty_table", "= 0.1.0"


  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "debase", "= 0.2.2.beta6"
end
