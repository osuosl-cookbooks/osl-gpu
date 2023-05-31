require_relative '../../spec_helper'

describe 'osl-gpu-test::cuda_pkg' do
  context 'centos 7 - x86' do
    platform 'centos', '7'
    cached(:subject) { chef_run }
    step_into :osl_cuda

    it do
      is_expected.to create_yum_repository('cuda').with(
        baseurl: 'https://developer.download.nvidia.com/compute/cuda/repos/rhel$releasever/$basearch',
        gpgcheck: true,
        gpgkey: 'https://developer.download.nvidia.com/compute/cuda/repos/rhel$releasever/$basearch/D42D0685.pub'
      )
    end
    it { is_expected.to install_package('cuda-toolkit-11-7').with(timeout: 3600) }
  end

  context 'centos 7 - ppc64le' do
    platform 'centos', '7'
    automatic_attributes['kernel']['machine'] = 'ppc64le'
    cached(:subject) { chef_run }
    step_into :osl_cuda

    it { is_expected.to include_recipe('osl-repos::epel') }
    it { is_expected.to install_build_essential('cuda') }
    it { is_expected.to install_package('tar') }

    it do
      is_expected.to create_if_missing_remote_file('/var/chef/cache/cuda_linux.run').with(
        source: 'https://developer.download.nvidia.com/compute/cuda/11.7.1/local_installers/cuda_11.7.1_515.65.01_linux_ppc64le.run',
        show_progress: true
      )
    end

    it do
      is_expected.to run_execute('cuda_linux.run').with(
          command: 'sh /var/chef/cache/cuda_linux.run --toolkit --silent',
          creates: '/usr/local/cuda-11.7'
        )
    end

    it { is_expected.to nothing_execute('rm -f /var/chef/cache/cuda_linux.run') }

    context 'cuda installed' do
      before do
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with('/usr/local/cuda-11.7').and_return(true)
        allow(File).to receive(:exist?).with('/var/chef/cache/cuda_linux.run').and_return(true)
      end
      cached(:subject) { chef_run }
      it { is_expected.to_not create_if_missing_remote_file('/var/chef/cache/cuda_linux.run') }
      it { is_expected.to run_execute('rm -f /var/chef/cache/cuda_linux.run') }
    end
  end

  context 'almalinux 8 - x86' do
    platform 'almalinux', '8'
    cached(:subject) { chef_run }
    step_into :osl_cuda

    it do
      is_expected.to create_yum_repository('cuda').with(
        baseurl: 'https://developer.download.nvidia.com/compute/cuda/repos/rhel$releasever/$basearch',
        gpgcheck: true,
        gpgkey: 'https://developer.download.nvidia.com/compute/cuda/repos/rhel$releasever/$basearch/D42D0685.pub'
      )
    end
    it { is_expected.to install_package('cuda-toolkit-11-7').with(timeout: 3600) }
  end

  context 'almalinux 8 - ppc64le' do
    platform 'almalinux', '8'
    automatic_attributes['kernel']['machine'] = 'ppc64le'
    cached(:subject) { chef_run }
    step_into :osl_cuda

    it do
      is_expected.to create_yum_repository('cuda').with(
        baseurl: 'https://developer.download.nvidia.com/compute/cuda/repos/rhel$releasever/$basearch',
        gpgcheck: true,
        gpgkey: 'https://developer.download.nvidia.com/compute/cuda/repos/rhel$releasever/$basearch/D42D0685.pub'
      )
    end
    it { is_expected.to install_package('cuda-toolkit-11-7').with(timeout: 3600) }
  end

  context 'ubuntu 20.04 - x86' do
    platform 'ubuntu', '20.04'
    cached(:subject) { chef_run }
    step_into :osl_cuda

    it do
      is_expected.to create_remote_file('/var/chef/cache/cuda-keyring.deb').with(
        source: 'https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.0-1_all.deb'
      )
    end

    it do
      is_expected.to install_dpkg_package('cuda-keyring').with(
        source: '/var/chef/cache/cuda-keyring.deb'
      )
    end

    it do
      expect(chef_run.dpkg_package('cuda-keyring')).to notify('apt_update[cuda-keyring]').to(:update).immediately
    end

    it { is_expected.to periodic_apt_update('cuda-keyring') }
    it { is_expected.to install_package('cuda-toolkit-11-7').with(timeout: 3600) }
  end

  context 'ubuntu 20.04 - ppc64le' do
    platform 'ubuntu', '20.04'
    automatic_attributes['kernel']['machine'] = 'ppc64le'
    cached(:subject) { chef_run }
    step_into :osl_cuda

    it { is_expected.to_not include_recipe('osl-repos::epel') }
    it { is_expected.to install_build_essential('cuda') }
    it { is_expected.to install_package('tar') }

    it do
      is_expected.to create_if_missing_remote_file('/var/chef/cache/cuda_linux.run').with(
        source: 'https://developer.download.nvidia.com/compute/cuda/11.7.1/local_installers/cuda_11.7.1_515.65.01_linux_ppc64le.run',
        show_progress: true
      )
    end

    it do
      is_expected.to run_execute('cuda_linux.run').with(
          command: 'sh /var/chef/cache/cuda_linux.run --toolkit --silent',
          creates: '/usr/local/cuda-11.7'
        )
    end

    it { is_expected.to nothing_execute('rm -f /var/chef/cache/cuda_linux.run') }

    context 'cuda installed' do
      before do
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with('/usr/local/cuda-11.7').and_return(true)
        allow(File).to receive(:exist?).with('/var/chef/cache/cuda_linux.run').and_return(true)
      end
      cached(:subject) { chef_run }
      it { is_expected.to_not create_if_missing_remote_file('/var/chef/cache/cuda_linux.run') }
      it { is_expected.to run_execute('rm -f /var/chef/cache/cuda_linux.run') }
    end
  end
end
