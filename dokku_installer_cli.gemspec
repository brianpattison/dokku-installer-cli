# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "dokku_installer/version"

Gem::Specification.new do |spec|
  spec.name          = "dokku-installer-cli"
  spec.version       = DokkuInstaller::VERSION
  spec.authors       = ["Brian Pattison"]
  spec.email         = ["brian@brianpattison.com"]
  spec.summary       = %q{Command line tool for Dokku Installer}
  spec.homepage      = "https://github.com/brianpattison/dokku-installer-cli"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "thor", "~> 0.19"
end
