require 'spec_helper_acceptance'

describe 'ubuntu-os-tests', :if => !UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) && fact('operatingsystem') == 'Ubuntu' do

  context 'test base profile on ubuntu os' do

    it 'should work with no errors' do
      pp = <<-EOS
        include profiles::base
      EOS

      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
   end

    describe file('/etc/sysctl.conf') do
      its(:content) { should match /^kernel\.shmall\s*=\s*2097152$/ }
    end

    describe file('/etc/sysctl.conf') do
      its(:content) { should match /^kernel\.shmmax\s*=\s*2147483648$/ }
    end

    describe file('/etc/sysctl.conf') do
      its(:content) { should match /^kernel\.shmmni\s*=\s*4096$/ }
    end

    describe file('/etc/sysctl.conf') do
      its(:content) { should match /^fs\.file\-max\s*=\s*65536$/ }
    end

    describe file('/etc/sysctl.conf') do
      its(:content) { should match /^vm\.swappiness\s*=\s*0$/ }
    end

    describe file('/etc/sysctl.conf') do
      its(:content) { should match /^vm\.vfs_cache_pressure\s*=\s*50$/ }
    end
  end
end
