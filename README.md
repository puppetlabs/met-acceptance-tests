# Mock Engagement Tool (MET) Acceptance Tests
This repository houses the acceptance tests to confirm that the MET (Mock Engagement Tool) case study has been completed successfully.

The case study is a Gitbook housed at: [https://www.gitbook.com/book/puppet-partner-enablement/mock-engagement-tool-case-study/details](https://www.gitbook.com/book/puppet-partner-enablement/mock-engagement-tool-case-study/details)

### Overview

These acceptance tests are designed to validate the Puppet code produced by following the instructions in the MET case study. They check for the following configuration:

* Existence of a class named "profile::base". This is a hard requirement so the acceptance tests have a starting point from which to include the rest of the classes implemented during the case study.
* Proper configuration of the /etc/ntp.conf file across 3 datacenters - PDX, LON and NYC
* Proper configuration of the /etc/resolv.conf file across 3 datacenters - PDX, LON and NYC
* Proper configuration of the /etc/sysctl.conf across 2 operating systems - CentOS and Ubuntu

The acceptance tests use the actual hiera.yaml, Hiera data and Puppet code submitted after completion of the case study. The "spec helper" copies all of the files into the SUT (system under test) to the proper locations before the tests are launched.

### Usage

Clone the MET acceptance tests repository from [https://github.com/puppetlabs/met-acceptance-tests.git](https://github.com/puppetlabs/met-acceptance-tests.git). The submitted case study code should be in the form of a .tar.gz file with the following directory structure:

```
production
├── environment.conf
├── facts.d
│   └── # Custom fact(s) 
├── hiera.yaml
├── hieradata
│   ├── # Hiera data files
│   ├── ...
│   └── # Hiera data files
├── manifests
│   └── site.pp
└── modules
    ├── profile
    │   └── manifests
    │       ├── # Profile module classes
    │       ├── ...
    │       └── # Profile module classes
    └── role
        └── manifests
            └── init.pp
```

This .tar.gz file should be extracted to the same directory where the met-acceptance-tests repository is housed, e.g.:

```
├── met-acceptance-tests
├── ...
├── production
```

The MET acceptance tests expect the directory "production" to be located in a parallel directory.

Once the code directory to be tested is in place, change directory into `met-acceptance-tests` and run the following command:

```
BEAKER_set=vagrant/<DATACENTER>/el<VERSION> rake beaker
```

The value of `<DATACENTER>` can be one of `pdx`, `lon`, or `nyc`. The value of `<VERSION>` can be one of `5`, `6`, or `7`.

This command will launch the acceptance tests and simulate the SUT as if it were housed in the specified datacenter with the operating system type and version. For each of those combinations, different system configurations will be expected on the SUT.

Any deviations from the expected configuration will be logged at the end of the Beaker run. A successful run will exit with messages like the following:

```
pdx-centos-6-x64 13:53:52$ /bin/sh -c cat\ /etc/resolv.conf\ 2\>\ /dev/null\ \|\|\ echo\ -n
  # This file is being maintained by Puppet.
  # DO NOT EDIT
  options rotate timeout:1
  nameserver 208.67.222.222
  nameserver 208.67.220.220
  nameserver 8.8.8.8
  nameserver 8.8.4.4

pdx-centos-6-x64 executed in 0.01 seconds
        should match /^nameserver\s+8\.8\.4\.4$/
Warning: ssh connection to pdx-centos-6-x64 has been terminated
removing temporory ssh-config files per-vagrant box
Destroying vagrant boxes
==> pdx-centos-6-x64: Forcing shutdown of VM...
==> pdx-centos-6-x64: Destroying VM and associated drives...

Finished in 23.51 seconds (files took 3 minutes 10.1 seconds to load)
24 examples, 0 failures

```

and a failed run looks like:

```
       +net.ipv4.icmp_echo_ignore_broadcasts = 1


     # ./spec/acceptance/centos_os_spec.rb:63:in `block (4 levels) in <top (required)>'

Finished in 33.37 seconds (files took 3 minutes 17.3 seconds to load)
24 examples, 1 failure

Failed examples:

rspec ./spec/acceptance/centos_os_spec.rb:63 # centos-os-tests test base profile on centos os File "/etc/sysctl.conf" content should match /^net\.ipv4\.conf\.all\.rp_filter\s*=\s*1$/

/Users/glarkin/.rbenv/versions/2.1.5/bin/ruby -I/Users/glarkin/.rbenv/versions/2.1.5/lib/ruby/gems/2.1.0/gems/rspec-support-3.5.0.beta4/lib:/Users/glarkin/.rbenv/versions/2.1.5/lib/ruby/gems/2.1.0/gems/rspec-core-3.5.0.beta4/lib /Users/glarkin/.rbenv/versions/2.1.5/lib/ruby/gems/2.1.0/gems/rspec-core-3.5.0.beta4/exe/rspec spec/acceptance --color failed
```

After a failed run, look through the Beaker output to determine how the SUT is misconfigured and trace that back to the submitted code for further review and followup with the SDP consultant.