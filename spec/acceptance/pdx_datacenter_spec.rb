require 'spec_helper_acceptance'

describe 'pdx-datacenter-tests', :if => !UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) && fact('datacenter') == 'pdx' do

  context 'test base profile in pdx datacenter' do

    it 'should work with no errors' do
      pp = <<-EOS
        include profile::base
      EOS

      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
   end

    describe service('ntpd') do
      it { should be_running }
    end

    describe file('/etc/ntp.conf') do
      its(:content) { should match /^server\s+0\.us\.pool\.ntp\.org/ }
    end

    describe file('/etc/ntp.conf') do
      its(:content) { should match /^server\s+1\.us\.pool\.ntp\.org/ }
    end

    describe file('/etc/ntp.conf') do
      its(:content) { should match /^server\s+2\.us\.pool\.ntp\.org/ }
    end

    describe file('/etc/ntp.conf') do
      its(:content) { should match /^server\s+3\.us\.pool\.ntp\.org/ }
    end

    describe file('/etc/resolv.conf') do
      its(:content) { should match /^nameserver\s+208\.67\.222\.222$/ }
    end

    describe file('/etc/resolv.conf') do
      its(:content) { should match /^nameserver\s+208\.67\.220\.220$/ }
    end

    describe file('/etc/resolv.conf') do
      its(:content) { should match /^nameserver\s+8\.8\.8\.8$/ }
    end

    describe file('/etc/resolv.conf') do
      its(:content) { should match /^nameserver\s+8\.8\.4\.4$/ }
    end
  end
end
