require 'beaker/dsl/outcomes'
require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'

UNSUPPORTED_PLATFORMS = ['Suse','windows','AIX','Solaris']

# Set up some directory and filenames that we'll need for configuring
# the SUT with the code produced from the MET case study
proj_root           = File.expand_path(File.join(File.dirname(__FILE__), '../..'))
prod_env_root       = File.join(proj_root, 'production')
module_root         = File.join(prod_env_root, 'site')
profile_module_root = File.join(module_root, 'profile')
hiera_yaml          = File.join(prod_env_root, 'hiera.yaml')
facts_root          = File.join(profile_module_root, 'facts.d')

# Check if everything exists where it should and fail if it doesn't
unless Dir.exists?(prod_env_root)
  fail_test "#{prod_env_root} does not exist - exiting"
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

  # Setup some variables
  puppetbin       = '/opt/puppetlabs/puppet/bin'
  codedir         = '/etc/puppetlabs/code'
  environmentpath = "#{codedir}/environments"
  factpath        = '/etc/puppetlabs/facter'

  # Get some files into place
  scp_to host, hiera_yaml, "#{codedir}/hiera.yaml"
  on host, "mkdir -p #{factpath}"
  scp_to host, facts_root, factpath if Dir.exists?(facts_root)
  scp_to host, prod_env_root, environmentpath
  on host, "#{puppetbin}/gem install r10k --no-rdoc --no-ri"
  on host, "#{puppetbin}/r10k puppetfile install --puppetfile #{environmentpath}/production/Puppetfile --moduledir #{environmentpath}/production/modules"
  on host, 'kill -HUP $(pgrep -f puppet-server-release.jar)' if host['roles'].include?('master')
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
