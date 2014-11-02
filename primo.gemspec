# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'primo/version'

Gem::Specification.new do |s|
  s.name        = 'soto-primo'
  s.version     = '0.0.1'
  s.date        = '2014-08-31'
  s.platform    = Gem::Platform::RUBY
  s.summary     = 'Graphical Inference Modelling (with Ruby)'
  s.description = 'Liberally based on Stanford U, Prof. Daphne Koller: Probabilistic Graphical Models'
  s.authors     = ['Javier Soto']
  s.email       = ['sotoseattle@gmail.com']

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec}/*`.split("\n")

  s.require_paths = ['lib']

  s.homepage    = 'http://sotoseattle.github.io/primo'
  s.license     = 'MIT'
end
