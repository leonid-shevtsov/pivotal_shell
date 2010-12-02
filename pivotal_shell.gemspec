# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "pivotal_shell/version"

Gem::Specification.new do |s|
  s.name        = "pivotal_shell"
  s.version     = PivotalShell::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Leonid Shevtsov"]
  s.email       = ["leonid@shevtsov.me"]
  s.homepage    = "http://rubygems.org/gems/pivotal_shell"
  s.summary     = %q{Pivotal shell}
  s.description = %q{}

  s.add_dependency 'pivotal-tracker', '=0.3'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
