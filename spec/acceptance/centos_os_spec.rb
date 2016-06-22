require 'spec_helper_acceptance'

describe 'centos-os-tests', :if => !UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) && fact('operatingsystem') == 'CentOS' do

  context 'test base profile on centos os' do

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

    describe file('/etc/sysctl.conf') do
      its(:content) { should match /^net.ipv4.conf.all.send_redirects\s*=\s*0$/ }
    end

    describe file('/etc/sysctl.conf') do
      its(:content) { should match /^net\.ipv4\.conf\.default\.send_redirects\s*=\s*0$/ }
    end

    describe file('/etc/sysctl.conf') do
      its(:content) { should match /^net\.ipv4\.conf\.all\.accept_source_route\s*=\s*0$/ }
    end

    describe file('/etc/sysctl.conf') do
      its(:content) { should match /^net\.ipv4\.conf\.all\.accept_redirects\s*=\s*0$/ }
    end

    describe file('/etc/sysctl.conf') do
      its(:content) { should match /^net\.ipv4\.conf\.all\.secure_redirects\s*=\s*0$/ }
    end

    describe file('/etc/sysctl.conf') do
      its(:content) { should match /^net\.ipv4\.conf\.all\.log_martians\s*=\s*1$/ }
    end

    describe file('/etc/sysctl.conf') do
      its(:content) { should match /^net\.ipv4\.conf\.default\.accept_source_route\s*=\s*0$/ }
    end

    describe file('/etc/sysctl.conf') do
      its(:content) { should match /^net\.ipv4\.conf\.default\.accept_redirects\s*=\s*0$/ }
    end

    describe file('/etc/sysctl.conf') do
      its(:content) { should match /^net\.ipv4\.conf\.default\.secure_redirects\s*=\s*0$/ }
    end

    describe file('/etc/sysctl.conf') do
      its(:content) { should match /^net\.ipv4\.icmp_echo_ignore_broadcasts\s*=\s*1$/ }
    end

    describe file('/etc/sysctl.conf') do
      if (fact('operatingsystem') == 'CentOS' && fact('operatingsystemmajrelease') == '6')
        its(:content) { should match /^net\.ipv4\.tcp_syncookies\s*=\s*1$/ }
      end
    end

    describe file('/etc/sysctl.conf') do
      its(:content) { should match /^net\.ipv4\.conf\.all\.rp_filter\s*=\s*1$/ }
    end

    describe file('/etc/sysctl.conf') do
      its(:content) { should match /^net\.ipv4\.conf\.default\.rp_filter\s*=\s*1$/ }
    end
  end
end
