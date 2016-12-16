source ENV['GEM_SOURCE'] || "https://rubygems.org"

def location_from_env(env, default_location = [])
  if location = ENV[env]
    if location =~ /^((?:git|https?)[:@][^#]*)#(.*)/
      [{ :git => $1, :branch => $2, :require => false }]
    elsif location =~ /^file:\/\/(.*)/
      ['>= 0', { :path => File.expand_path($1), :require => false }]
    else
      [location, { :require => false }]
    end
  else
    default_location
  end
end

gem 'beaker', *location_from_env('BEAKER_VERSION', []) if RUBY_VERSION >= '2.3.0'
gem 'beaker', *location_from_env('BEAKER_VERSION', ['< 3']) if RUBY_VERSION < '2.3.0'
gem 'beaker-rspec', *location_from_env('BEAKER_RSPEC_VERSION', ['>= 3.4'])
gem 'serverspec'
gem 'rake'
gem 'facter', *location_from_env('FACTER_GEM_VERSION')
gem 'puppet', *location_from_env('PUPPET_GEM_VERSION')
gem 'puppetlabs_spec_helper', '>= 1.2.1'
gem 'r10k'
