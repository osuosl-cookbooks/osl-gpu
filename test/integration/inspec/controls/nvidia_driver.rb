os_family = os.family
pkg_install = input('pkg_install')

driver_version =
  if os_family == 'redhat' && pkg_install
    inspec.command("rpm -q --qf '%{VERSION}' kmod-nvidia-latest-dkms").stdout.strip
  else
    input('driver_version')
  end

control 'nvidia_driver' do
  describe command 'modinfo nvidia' do
    its('exit_status') { should eq 0 }
    its('stdout') { should match /version:\s+#{driver_version}/ }
  end

  describe command 'dkms status' do
    its('exit_status') { should eq 0 }
    its('stdout') { should match /^nvidia.*#{driver_version}.*installed$/ }
  end
end
