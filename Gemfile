source 'https://rubygems.org'
gemspec

# conditionally require specific ruby versions to satisfy travis-ci

if RUBY_VERSION >= '2.2.2'
  gem 'rails', '>= 5.0.0.beta3', '< 5.1'
else
  gem 'rails', '~> 4.2.6'
end
