os_family = os.family
kernel_release = inspec.command('uname -r').stdout.strip

control 'nouveau_driver' do
  describe kernel_module 'nouveau' do
    it { should_not be_loaded }
    it { should be_blacklisted }
  end

  if os_family == 'debian'
    describe command 'lsinitramfs /boot/initrd.img' do
      its('stdout') { should match /modprobe.d.*blacklist_nouveau*/ }
    end
  else
    describe command "lsinitrd /boot/initramfs-#{kernel_release}.img" do
      its('stdout') { should match /modprobe.d.*blacklist_nouveau*/ }
    end
  end
end
