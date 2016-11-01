# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails_view_adapters/version'

Gem::Specification.new do |spec|
  spec.name          = "rails_view_adapters"
  spec.version       = RailsViewAdapters::VERSION
  spec.authors       = ["Bryan Hockey"]
  spec.email         = ["bhock@umich.edu"]

  spec.summary       = "Bidirectional mappings between models and external views for Rails."
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/mlibrary/rails_view_adapters"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.test_files = Dir["spec/**/*"]

  spec.required_ruby_version = ">= 2.2.2"

  spec.add_dependency "activerecord", "~>4.2.7.1"
  spec.add_dependency "activesupport", "~>4.2.7.1"

  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "faker"
  spec.add_development_dependency "fabrication"
  spec.add_development_dependency "pry"
end
