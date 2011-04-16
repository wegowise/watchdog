# -*- encoding: utf-8 -*-
require 'rubygems' unless defined? Gem
require File.dirname(__FILE__) + "/lib/watchdog/version"

Gem::Specification.new do |s|
  s.name        = "watchdog"
  s.version     = Watchdog::VERSION
  s.authors     = ["Gabriel Horner"]
  s.email       = "ghorner@wegowise.com"
  s.homepage    = "http://github.com/wegowise/watchdog"
  s.summary = "Watches over your extensions and monkey patches"
  s.description =  "Watchdog ensures your extensions and monkey patches don't redefine existing methods as well as get redefined by others."
  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project = 'tagaholic'
  s.files = Dir.glob(%w[{lib,spec}/**/*.rb [A-Z]*.{txt,rdoc,md} *.gemspec]) + %w{Rakefile}
  s.extra_rdoc_files = ["README.md", "LICENSE.txt"]
  s.license = 'MIT'
end
