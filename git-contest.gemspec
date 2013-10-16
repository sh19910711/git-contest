# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'git/contest/version'

Gem::Specification.new do |spec|
  spec.name          = "git-contest"
  spec.version       = Git::Contest::VERSION
  spec.authors       = ["Hiroyuki Sano"]
  spec.email         = ["sh19910711@gmail.com"]
  spec.description   = %q{git extension for programming contest (Codeforces, Google Codejam, ICPC, etc...)}
  spec.summary       = %q{git extension for programming contest}
  spec.homepage      = ""
  spec.license       = "MIT"

  # spec.files         = `git ls-files`.split($/)
  spec.files         = `find . -type f | grep -Ev '/\\.' | grep -v /tmp/`.split($/)
  spec.executables   = spec.files.grep(%r{^./bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^./(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "mechanize"
  spec.add_dependency "nokogiri"
  spec.add_dependency "trollop"
  spec.add_dependency "highline"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "watchr"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "webmock"
end
