cuda_version = input('cuda_version')

control 'cuda' do
  describe command '/usr/local/cuda/bin/nvcc --version' do
    its('exit_status') { should eq 0 }
    its('stdout') { should match /^Cuda compilation tools, release #{cuda_version}/ }
  end

  describe file '/tmp/kitchen/cache/cuda_linux.run' do
    it { should_not exist }
  end
end
