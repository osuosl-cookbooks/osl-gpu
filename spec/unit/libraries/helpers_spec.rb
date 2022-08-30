require_relative '../../spec_helper'
require_relative '../../../libraries/helpers'

RSpec.describe OSLGPU::Cookbook::Helpers do
  class DummyClass < Chef::Node
    include OSLGPU::Cookbook::Helpers
  end

  subject { DummyClass.new }

  describe '#cuda_keyring_url' do
    before do
      allow(subject).to receive(:[]).with('platform').and_return(platform)
      allow(subject).to receive(:[]).with('platform_version').and_return(platform_version)
      allow(subject).to receive(:[]).with('kernel').and_return(machine)
    end
    context 'ubuntu 20.04' do
      let(:platform) { 'ubuntu' }
      let(:platform_version) { '20.04' }
      let(:machine) { { 'machine' => 'x86_64' } }

      it do
        expect(subject.cuda_keyring_url).to eq 'https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.0-1_all.deb'
      end
    end

    context 'ubuntu 22.04' do
      let(:platform) { 'ubuntu' }
      let(:platform_version) { '22.04' }
      let(:machine) { { 'machine' => 'x86_64' } }

      it do
        expect(subject.cuda_keyring_url).to eq 'https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.0-1_all.deb'
      end
    end

    context 'debian 11' do
      let(:platform) { 'debian' }
      let(:platform_version) { '11' }
      let(:machine) { { 'machine' => 'x86_64' } }

      it do
        expect(subject.cuda_keyring_url).to eq 'https://developer.download.nvidia.com/compute/cuda/repos/debian11/x86_64/cuda-keyring_1.0-1_all.deb'
      end
    end
  end

  describe '#runfile_versions' do
    it 'driver 515' do
      expect(subject.runfile_versions('515')).to eq 'cuda' => '11.7.1', 'driver' => '515.65.01'
    end
    it 'cuda 11.7' do
      expect(subject.runfile_versions('11.7')).to eq 'cuda' => '11.7.1', 'driver' => '515.65.01'
    end
  end

  describe '#runfile_suffix' do
    before do
      allow(subject).to receive(:[]).with('kernel').and_return(machine)
    end

    context 'x86' do
      let(:machine) { { 'machine' => 'x86_64' } }

      it 'suffix' do
        expect(subject.runfile_suffix).to eq 'linux.run'
      end
    end

    context 'ppc64le' do
      let(:machine) { { 'machine' => 'ppc64le' } }

      it 'suffix' do
        expect(subject.runfile_suffix).to eq 'linux_ppc64le.run'
      end
    end
  end

  describe '#default_runfile_url' do
    before do
      allow(subject).to receive(:[]).with('kernel').and_return(machine)
    end

    context 'x86' do
      let(:machine) { { 'machine' => 'x86_64' } }

      it 'driver ver' do
        expect(subject.default_runfile_url('515')).to eq 'https://developer.download.nvidia.com/compute/cuda/11.7.1/local_installers/cuda_11.7.1_515.65.01_linux.run'
      end

      it 'cuda ver' do
        expect(subject.default_runfile_url('11.7')).to eq 'https://developer.download.nvidia.com/compute/cuda/11.7.1/local_installers/cuda_11.7.1_515.65.01_linux.run'
      end
    end

    context 'ppc64le' do
      let(:machine) { { 'machine' => 'ppc64le' } }

      it 'driver ver' do
        expect(subject.default_runfile_url('515')).to eq 'https://developer.download.nvidia.com/compute/cuda/11.7.1/local_installers/cuda_11.7.1_515.65.01_linux_ppc64le.run'
      end

      it 'cuda ver' do
        expect(subject.default_runfile_url('11.7')).to eq 'https://developer.download.nvidia.com/compute/cuda/11.7.1/local_installers/cuda_11.7.1_515.65.01_linux_ppc64le.run'
      end
    end
  end
end
