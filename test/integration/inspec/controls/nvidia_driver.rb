driver_version = input('driver_version')
os_family = os.family
kernel_release = inspec.command('uname -r').stdout.strip

control 'nvidia_driver' do
  describe command 'modinfo nvidia' do
    its('exit_status') { should eq 0 }
    its('stdout') { should match /version:\s+#{driver_version}/ }
  end

  describe command 'dkms status' do
    its('exit_status') { should eq 0 }
    its('stdout') { should match /^nvidia.*#{driver_version}.*installed$/ }
  end

  if os_family == 'debian'
    describe command 'lsinitramfs /boot/initrd.img' do
      its('stdout') { should match /modprobe.d.*nvidia*/ }
    end
  else
    describe command "lsinitrd /boot/initramfs-#{kernel_release}.img" do
      its('stdout') { should match /modprobe.d.*nvidia*/ }
    end
  end
end
