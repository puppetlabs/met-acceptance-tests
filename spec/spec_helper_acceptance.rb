require 'beaker/dsl/outcomes'
require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'yaml'

UNSUPPORTED_PLATFORMS = ['Suse','windows','AIX','Solaris']

# User input from YAML
begin
  cache = YAML.load_file('./MET.yaml')
rescue Exception => e
  $stderr.puts "MET.yaml does not exist!"
  exit 1
end
met_key   = cache['met_key']
git_url   = cache['git_url']
master_ip = cache['master_ip']

# Calculate things
git_host = /\w+@([\w\d\.\-]+):.*git/.match(git_url)[1]

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
  confdir         = '/etc/puppetlabs/puppet'
  cdmgr_key       = '/etc/puppetlabs/puppetserver/ssh/id-control_repo.rsa'

  host_met_key   = '/tmp/met.pem'
  host_cdmgr_key = '/tmp/id-control_repo.rsa'
  host_r10k      = '/tmp/r10k.yaml'
  host_ssh_conf  = '/root/.ssh/config'
  #host_puppetf   = '/etc/puppetlabs/code/environments/production/Puppetfile'
  options        = "-i #{host_met_key} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

  # Use r10k to pull control repo
  scp_to host, met_key, host_met_key
  r10k_yaml = <<-RYAML
---
cachedir: /opt/puppetlabs/server/data/puppetserver/r10k
sources:
  puppet:
    basedir: #{environmentpath}
    remote: #{git_url}
  RYAML
  on host, "echo -e '#{r10k_yaml}' > #{host_r10k}", :accept_all_exit_codes => true
  puts "=> Deployed r10k.yaml"

  # No rugged, using ssh config to indicate key
  # Don't check known_hosts
  ssh_config = <<-SSHC
Host #{git_host}
  IdentityFile #{host_cdmgr_key}
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
  SSHC
  on host, "echo -e '#{ssh_config}' > #{host_ssh_conf}", :accept_all_exit_codes => true
  puts "=> Deployed ssh config"

  # Install r10k
  on host, "#{puppetbin}/gem install r10k --no-rdoc --no-ri"
  puts "=> Installed r10k"

  on host, "scp #{options} training@#{master_ip}:#{confdir}/hiera.yaml #{confdir}", :accept_all_exit_codes => true
  puts "=> Deployed hiera.yaml"

  # Private key is only accessible by sudo.
  # Using SSH instead to grab key contents.
  on host, "ssh #{options} training@#{master_ip} 'sudo cat #{cdmgr_key}' >> #{host_cdmgr_key}"
  on host, "chown 400 #{host_cdmgr_key}"
  puts "=> Deployed Code Manager private key"

  # No functional r10k providers as is
  # Choosing git as the one to use
  on host, puppet('resource', 'package', 'git', 'ensure=installed'), { :acceptable_exit_codes => [0,1] }
  on host, "#{puppetbin}/r10k deploy environment -c #{host_r10k} production -pv"
  on host, 'kill -HUP $(pgrep -f puppet-server-release.jar)' if host['roles'].include?('master')
end

RSpec.configure do |c|
  c.formatter = :documentation
end
