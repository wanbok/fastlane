# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/version'

Gem::Specification.new do |spec|
  spec.name          = "fastlane"
  spec.version       = Fastlane::VERSION
  spec.authors       = ["Felix Krause"]
  spec.email         = ["fastlane@krausefx.com"]
  spec.summary       = 'Connect all iOS deployment tools into one streamlined workflow'
  spec.description   = 'Connect all iOS deployment tools into one streamlined workflow'
  spec.homepage      = "https://fastlane.tools"
  spec.license       = "MIT"

  spec.required_ruby_version = '>= 2.0.0'

  spec.files = Dir["lib/**/*"] + %w( bin/fastlane README.md LICENSE )

  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'krausefx-shenzhen', '>= 0.14.7' # to upload to Hockey and Crashlytics and build the app
  spec.add_dependency 'slack-notifier', '~> 1.3' # Slack notifications
  spec.add_dependency 'xcodeproj', '>= 0.20', '< 2.0.0' # Needed for commit_version_bump action
  spec.add_dependency 'xcpretty', '>= 0.2.1' # prettify xcodebuild output
  spec.add_dependency 'terminal-notifier', '~> 1.6.2' # Mac OS X notifications
  spec.add_dependency 'terminal-table', '~> 1.4.5' # Actions documentation
  spec.add_dependency 'plist', '~> 3.1.0' # Needed for set_build_number_repository and get_info_plist_value actions
  spec.add_dependency 'addressable', '~> 2.3' # Support for URI templates
  spec.add_dependency 'multipart-post', '~> 2.0.0' # Needed for uploading builds to appetize

  spec.add_dependency 'fastlane_core', '>= 0.41.2', '< 1.0.0' # all shared code and dependencies

  spec.add_dependency 'credentials_manager', '>= 0.15.0', '< 1.0.0' # Password Manager
  spec.add_dependency 'spaceship', '>= 0.25.1', '< 1.0.0' # communication layer with Apple's web services

  # All the fastlane tools
  spec.add_dependency 'deliver', '>= 1.11.0', '< 2.0.0'
  spec.add_dependency 'snapshot', '>= 1.12.1', '< 2.0.0'
  spec.add_dependency 'frameit', '>= 2.5.1', '< 3.0.0'
  spec.add_dependency 'pem', '>= 1.3.0', '< 2.0.0'
  spec.add_dependency 'cert', '>= 1.4.0', '< 2.0.0'
  spec.add_dependency 'sigh', '>= 1.6.1', '< 2.0.0'
  spec.add_dependency 'produce', '>= 1.1.1', '< 2.0.0'
  spec.add_dependency 'gym', '>= 1.6.2', '< 2.0.0'
  spec.add_dependency 'pilot', '>= 1.5.0', '< 2.0.0'
  spec.add_dependency 'supply', '>= 0.6.1', '< 1.0.0'
  spec.add_dependency 'scan', '>= 0.5.2', '< 1.0.0'
  spec.add_dependency 'match', '>= 0.4.0', '< 1.0.0'
  spec.add_dependency 'screengrab', '>= 0.3.2', '< 1.0.0'

  # Development only
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.1.0'
  spec.add_development_dependency 'rspec_junit_formatter', '~> 0.2.3'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'yard', '~> 0.8.7.4'
  spec.add_development_dependency 'webmock', '~> 1.19.0'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'rubocop', '~> 0.38.0'
  spec.add_development_dependency 'appium_lib', '~> 4.1.0'
  spec.add_development_dependency 'rest-client', '~> 1.6.7'
  spec.add_development_dependency 'fakefs', '~> 0.8.1'
end
