# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aws_pocketknife/version'

Gem::Specification.new do |spec|
  spec.name          = "aws_pocketknife"
  spec.version       = AwsPocketknife::VERSION
  spec.authors       = ["Gustavo Soares Souza"]
  spec.email         = ["gustavosoares@gmail.com"]

  spec.summary       = "Command line tools to make aws administration a little bit easier and faster than using the aws consol or aws cli."
  spec.description   = "Have you ever find yourself going through the aws cli documentation page over and over again just to remember the right syntax or argument(s) for that command that you wanna run? Do you feel that you are more productive from the command line? Are you tired of having to open private browser windows or even a different browser to work with multiple aws accounts? AWS Pocketknife is a command line tool to make aws administration a little bit easier and faster than using the aws console or aws cli. It also helps to script some AWS tasks such as cleaning up
old AMIs along its snapshots or cleaning up manual RDS snapshots or even creating a manual snapshot for a particular RDS.

These commands are also handy if you have multiple aws accounts to manage, since you can't have multiple tabs open for
different accounts in a web browser. The only way would be to use diffente browsers or open incognito windows."
  spec.homepage      = "https://github.com/gustavosoares/aws_pocketknife"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'aws-sdk-core', '~> 2.1'
  spec.add_dependency 'retryable', '~> 2.0'
  spec.add_dependency "rake", "~> 10.0"
  spec.add_dependency "erubis", "= 2.7.0"
  spec.add_dependency "pretty_table", "= 0.1.0"
  spec.add_dependency "awesome_print", "= 1.6.1"
  spec.add_dependency "recursive-open-struct",  "= 1.0.1"
  spec.add_dependency "log4r", "= 1.1.10"
  spec.add_dependency "thor", "~> 0.19"

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rspec", "~> 3.4"
  spec.add_development_dependency "debase", "= 0.2.2.beta6"
  spec.add_development_dependency "webmock", "= 1.24.2"
end
