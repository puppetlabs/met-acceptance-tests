require 'beaker/dsl/outcomes'
require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'

UNSUPPORTED_PLATFORMS = ['Suse','windows','AIX','Solaris']

# Set up some directory and filenames that we'll need for configuring
# the SUT with the code produced from the MET case study
proj_root = File.expand_path(File.join(File.dirname(__FILE__), '../..'))
prod_env_root = File.join(proj_root, 'production')
profile_module_root = File.join(prod_env_root, 'modules', 'profiles')
hiera_yaml = File.join(prod_env_root, 'hiera.yaml')
facts_root = File.join(profile_module_root, 'facts.d')

# Check if everything exists where it should and fail if it doesn't
unless Dir.exists?(prod_env_root)
  fail_test "#{prod_env_root} does not exist - exiting"
end

unless Dir.exists?(profile_module_root)
  fail_test "#{profile_module_root} does not exist - exiting"
end

unless File.exists?(hiera_yaml)
  fail_test "#{hiera_yaml} does not exist - exiting"
end

unless Dir.exists?(facts_root)
  fail_test "#{facts_root} does not exist - exiting"
end

hosts.each do |host|
  if host['roles'].include?('master')
    install_pe
  else
    install_puppet_agent_on(host)
  end

  # Get some files into place
  scp_to host, hiera_yaml, '/etc/puppetlabs/code/hiera.yaml'
  on host, 'mkdir -p /etc/puppetlabs/facter'
  scp_to host, facts_root, '/etc/puppetlabs/facter'
  scp_to host, prod_env_root, '/etc/puppetlabs/code/environments'
end

RSpec.configure do |c|
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    hosts.each do |host|
      on host, puppet('module','install','puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
    end
  end
end
