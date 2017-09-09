$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'cangaroo/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'cangaroo'
  s.version     = Cangaroo::VERSION
  s.authors     = ['Alessio Rocco', 'Andrea Pavoni']
  s.email       = ['info@nebulab.it']
  s.homepage    = 'https://github.com/nebulab/cangaroo'
  s.summary     = 'Connect Any App to Any Service'
  s.description = 'Cangaroo helps developers integrating their apps with any service'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*',
                'MIT-LICENSE',
                'Rakefile',
                'README.rdoc']
  s.test_files = Dir['spec/**/*']
  s.required_ruby_version = '>= 2.2.0'

  s.add_dependency 'rails', '>= 4.2.4'
  s.add_dependency 'interactor-rails', '~> 2.0.2'
  s.add_dependency 'json-schema', '~> 2.8.0'
  s.add_dependency 'httparty', '~> 0.14.0'

  s.add_development_dependency 'appraisal'
  s.add_development_dependency 'codeclimate-test-reporter'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'pry-byebug'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'shoulda-matchers'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'webmock'
end
