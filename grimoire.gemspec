# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "grimoire/version"

Gem::Specification.new do |s|
  s.name        = 'grimoire'
  s.version     = '0.0.1'
  s.version     = Grimoire::VERSION
  s.date        = '2014-08-31'
  s.platform    = Gem::Platform::RUBY
  s.summary     = "Graphical Inference Modelling (with Ruby)"
  s.description = "Follows the 'Probabilistic Graphical Models' course from Stanford U"
  s.authors     = ["Javier Soto"]
  s.email       = ["sotoseattle@gmail.com"]

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec}/*`.split("\n")
  
  s.require_paths = ["lib"]

  s.homepage    = "http://sotoseattle.github.io/grimoire"
  s.license     = 'MIT'
end