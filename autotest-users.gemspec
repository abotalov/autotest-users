# -*- encoding: utf-8 -*-
require File.expand_path('../lib/autotest-users/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Alex Klimenkov", 'Andrey Botalov']
  gem.email         = ["botalov.andrey@gmail.com"]
  gem.description   = %q{Gem to provide user for autotest}
  gem.homepage      = "https://github.com/abotalov/autotest-users"

  gem.files         = `git ls-files`.split($\)
  gem.name          = "autotest-users"
  gem.require_paths = ["lib"]
  gem.version       = Autotest::Users::VERSION
end
