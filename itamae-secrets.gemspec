# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'itamae/secrets/version'

Gem::Specification.new do |spec|
  spec.name          = "itamae-secrets"
  spec.version       = Itamae::Secrets::VERSION
  spec.authors       = ["Shota Fukumori (sora_h)"]
  spec.email         = ["her@sorah.jp"]

  spec.summary       = %q{Encrypted Data Bag for itamae}
  spec.homepage      = "https://github.com/sorah/itamae-secrets"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'thor'

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
