require 'beaker/dsl/outcomes'
require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'

hosts.each do |host|
  if host['roles'].include?('master')
    install_pe
  else
    install_puppet_agent_on(host)
  end
end

UNSUPPORTED_PLATFORMS = ['Suse','windows','AIX','Solaris']

proj_root = File.expand_path(File.join(File.dirname(__FILE__), '../..'))
prod_env_root = File.join(proj_root, 'production')
hiera_yaml = File.join(prod_env_root, 'hiera.yaml')
datacenter_fact = File.join(prod_env_root, 'facts.d', 'datacenter.txt')

# Check if everything exists where it should and fail if it doesn't
unless Dir.exists?(prod_env_root)
  fail_test "#{prod_env_root} does not exist - exiting"
end

unless File.exists?(hiera_yaml)
  fail_test "#{hiera_yaml} does not exist - exiting"
end

unless File.exists?(datacenter_fact)
  fail_test "#{datacenter_fact} does not exist - exiting"
end

RSpec.configure do |c|
  profiles_proj_root = File.expand_path(File.join(File.dirname(__FILE__), '../../profiles'))
  unless Dir.exists?(profiles_proj_root)
    fail_test "#{profiles_proj_root} does not exist - exiting"
  end

  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    hosts.each do |host|
      # Get some files into place
      scp_to host, hiera_yaml, '/etc/puppetlabs/code/hiera.yaml'
      on host, 'mkdir -p /etc/puppetlabs/facter/facts.d'
      scp_to host, datacenter_fact, '/etc/puppetlabs/facter/facts.d'
      scp_to host, prod_env_root, '/etc/puppetlabs/code/environments'

      on host, puppet('module','install','puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
    end
  end
end
