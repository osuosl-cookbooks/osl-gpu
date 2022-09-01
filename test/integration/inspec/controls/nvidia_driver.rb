driver_version = input('driver_version')

control 'nvidia_driver' do
  describe command 'modinfo nvidia' do
    its('exit_status') { should eq 0 }
    its('stdout') { should match /version:\s+#{driver_version}/ }
  end

  describe command 'dkms status' do
    its('exit_status') { should eq 0 }
    its('stdout') { should match /^nvidia.*#{driver_version}.*installed$/ }
  end

  describe kernel_module 'nouveau' do
    it { should_not be_loaded }
    it { should be_blacklisted }
  end
end
