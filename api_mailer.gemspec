require File.expand_path('../lib/api_mailer/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Carl Allen"]
  gem.email         = ["github@allenofmn.com"]
  gem.description   = %q{A simple replication of ActionMailer for API based mailing that doesn't require the mail gem}
  gem.summary       = %q{A simple replication of ActionMailer for API based mailing that doesn't require the mail gem}
  gem.homepage      = "http://github.com/sportngin/api_mailer"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(spec)/})
  gem.name          = "api_mailer"
  gem.require_paths = ["lib"]
  gem.license       = "MIT"
  gem.version       = ApiMailer::VERSION

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "debugger"
  gem.add_dependency "actionpack", ">= 3.0"
  gem.add_dependency "activesupport", ">= 3.0"
  gem.add_dependency "hashie"
end
