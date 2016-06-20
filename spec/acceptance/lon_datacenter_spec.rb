require 'spec_helper_acceptance'

describe 'lon-datacenter-tests', :if => !UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) && fact('datacenter') == 'lon' do

  context 'test base profile in lon datacenter' do

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
      its(:content) { should match /^server\s+0\.uk\.pool\.ntp\.org$/ }
    end

    describe file('/etc/ntp.conf') do
      its(:content) { should match /^server\s+1\.uk\.pool\.ntp\.org$/ }
    end

    describe file('/etc/ntp.conf') do
      its(:content) { should match /^server\s+2\.uk\.pool\.ntp\.org$/ }
    end

    describe file('/etc/ntp.conf') do
      its(:content) { should match /^server\s+3\.uk\.pool\.ntp\.org$/ }
    end

    describe file('/etc/resolv.conf') do
      its(:content) { should match /^nameserver\s+8\.8\.8\.8$/ }
    end

    describe file('/etc/resolv.conf') do
      its(:content) { should match /^nameserver\s+8\.8\.4\.4$/ }
    end
  end
end
