lib = File.expand_path('lib', __dir__)

$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'jira_automation/version'

Gem::Specification.new do |spec|
  spec.name          = 'jira_automation'
  spec.version       = JiraAutomation::VERSION
  spec.authors       = ['Carlos Quinones']
  spec.email         = ['cquinones100@gmail.com']
  spec.summary       = %(Automate Jira Work)

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'dotenv'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'guard-rspec'
end