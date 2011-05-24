# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "version"

Gem::Specification.new do |s|
  s.name = %q{can_be_flagged}
  s.version     = FlagThis::VERSION
  s.platform    = Gem::Platform::RUBY
  
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Dan Hixon"]
  #s.autorequire = %q{can_be_flagged}
  s.date = %q{2011-05-23}
  s.summary = %q{Gem that provides flagging functionality for active record objects}
  s.description = %q{Gem that provides flagging functionality for active record objects, just add can_be_flagged to your models.}
  s.email = %q{danhixon@gmail.com}
  s.homepage    = "http://github.com/danhixon/can_be_flagged"
  
  s.add_dependency('activerecord', '>= 3.0.0')

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
