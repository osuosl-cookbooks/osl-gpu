require_relative '../../spec_helper'
require_relative '../../../libraries/helpers'

RSpec.describe OSLGPU::Cookbook::Helpers do
  class DummyClass < Chef::Node
    include OSLGPU::Cookbook::Helpers
  end

  subject { DummyClass.new }

  describe '#runfile_install?' do
    before do
      allow(subject).to receive(:[]).with(:platform_family).and_return(platform_family)
      allow(subject).to receive(:[]).with('platform_version').and_return(platform_version)
      allow(subject).to receive(:[]).with('kernel').and_return(machine)
    end

    context 'rhel 8 ppc64le' do
      let(:platform_family) { 'rhel' }
      let(:platform_version) { '8.0' }
      let(:machine) { { 'machine' => 'ppc64le' } }

      it do
        expect(subject.runfile_install?).to eq false
      end
    end

    context 'rhel 8 x86_64' do
      let(:platform_family) { 'rhel' }
      let(:platform_version) { '8.0' }
      let(:machine) { { 'machine' => 'x86_64' } }

      it do
        expect(subject.runfile_install?).to eq false
      end
    end

    context 'ubuntu 22.04 ppc64le' do
      let(:platform_family) { 'debian' }
      let(:platform_version) { '22.04' }
      let(:machine) { { 'machine' => 'ppc64le' } }

      it do
        expect(subject.runfile_install?).to eq true
      end
    end

    context 'ubuntu 22.04 x86_64' do
      let(:platform_family) { 'debian' }
      let(:platform_version) { '22.04' }
      let(:machine) { { 'machine' => 'x86_64' } }

      it do
        expect(subject.runfile_install?).to eq false
      end
    end
  end

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

  describe '#driver_pkg_version' do
    before do
      allow(subject).to receive(:[]).with(:platform_family).and_return(platform_family)
    end

    context 'rhel - latest' do
      let(:platform_family) { 'rhel' }

      it do
        expect(subject.driver_pkg_version('latest')).to eq 'latest-dkms'
      end
    end

    context 'ubuntu - latest' do
      let(:platform_family) { 'debian' }

      it do
        expect(subject.driver_pkg_version('latest')).to eq '550'
      end
    end

    context 'rhel - manual version' do
      let(:platform_family) { 'rhel' }

      it do
        expect(subject.driver_pkg_version('100')).to eq '100'
      end
    end
  end

  describe '#cuda_pkg_version' do
    context 'latest' do
      it do
        expect(subject.cuda_pkg_version('latest')).to eq '12.4'
      end
    end

    context 'manual version' do
      it do
        expect(subject.cuda_pkg_version('100')).to eq '100'
      end
    end
  end

  describe '#runfile_suffix' do
    before do
      allow(subject).to receive(:[]).with('kernel').and_return(machine)
    end

    context 'x86' do
      let(:machine) { { 'machine' => 'x86_64' } }

      it do
        expect(subject.runfile_suffix).to eq 'linux.run'
      end
    end

    context 'ppc64le' do
      let(:machine) { { 'machine' => 'ppc64le' } }

      it do
        expect(subject.runfile_suffix).to eq 'linux_ppc64le.run'
      end
    end
  end

  describe '#runfile_versions' do
    it do
      expect(subject.runfile_versions('550')).to eq 'cuda' => '12.4.1', 'driver' => '550.54.15'
    end
    it do
      expect(subject.runfile_versions('12.4')).to eq 'cuda' => '12.4.1', 'driver' => '550.54.15'
    end
  end

  describe '#default_runfile_url' do
    before do
      allow(subject).to receive(:[]).with('kernel').and_return(machine)
    end

    context 'x86' do
      let(:machine) { { 'machine' => 'x86_64' } }

      it do
        expect(subject.default_runfile_url('550')).to eq 'https://developer.download.nvidia.com/compute/cuda/12.4.1/local_installers/cuda_12.4.1_550.54.15_linux.run'
      end

      it do
        expect(subject.default_runfile_url('12.4')).to eq 'https://developer.download.nvidia.com/compute/cuda/12.4.1/local_installers/cuda_12.4.1_550.54.15_linux.run'
      end
    end

    context 'ppc64le' do
      let(:machine) { { 'machine' => 'ppc64le' } }

      it do
        expect(subject.default_runfile_url('550')).to eq 'https://developer.download.nvidia.com/compute/cuda/12.4.1/local_installers/cuda_12.4.1_550.54.15_linux_ppc64le.run'
      end

      it do
        expect(subject.default_runfile_url('12.4')).to eq 'https://developer.download.nvidia.com/compute/cuda/12.4.1/local_installers/cuda_12.4.1_550.54.15_linux_ppc64le.run'
      end
    end
  end
end
