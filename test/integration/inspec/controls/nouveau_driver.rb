control 'nouveau_driver' do
  describe kernel_module 'nouveau' do
    it { should_not be_loaded }
    it { should be_blacklisted }
  end
end
