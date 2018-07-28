# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ezdrb/version'

Gem::Specification.new do |spec|
    spec.name          = "ezdrb"
    spec.version       = Ezdrb::VERSION
    spec.platform      = Gem::Platform::RUBY
    spec.authors       = ["monocrystal"]
    spec.email         = ["askeeydev@email.com"]
    spec.homepage      = ""
    spec.summary       = %q{A tool that helps you write Discord bots faster (Discordrb-only)}
    spec.description   = %q{A tool that helps you write Discord bots faster (Discordrb-only)}
    spec.license       = "MIT"

    spec.add_development_dependency "bundler", "~> 1.3"
    spec.add_development_dependency "rake"

    spec.add_runtime_dependency "thor"

    spec.files         = `git ls-files`.split($/)
    spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
    spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
    spec.require_paths = ["lib"]
end