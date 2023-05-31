require_relative '../../spec_helper'

describe 'osl-gpu-test::nvidia_driver_pkg' do
  context 'centos 7 - x86' do
    platform 'centos', '7'
    cached(:subject) { chef_run }
    step_into :osl_nvidia_driver

    it { is_expected.to remove_package('dracut-config-generic') }
    it { is_expected.to disable_osl_nouveau_driver('default') }
    it { is_expected.to include_recipe('osl-repos::centos') }
    it { is_expected.to include_recipe('osl-repos::epel') }
    it do
      is_expected.to create_yum_repository('cuda').with(
        baseurl: 'https://developer.download.nvidia.com/compute/cuda/repos/rhel$releasever/$basearch',
        gpgcheck: true,
        gpgkey: 'https://developer.download.nvidia.com/compute/cuda/repos/rhel$releasever/$basearch/D42D0685.pub'
      )
    end
    it { is_expected.to install_package(%w(nvidia-driver-latest-dkms kernel-devel)) }
  end

  context 'centos 7 - ppc64le' do
    platform 'centos', '7'
    automatic_attributes['kernel']['machine'] = 'ppc64le'
    cached(:subject) { chef_run }
    step_into :osl_nvidia_driver

    it { is_expected.to disable_osl_nouveau_driver('default') }
    it { is_expected.to include_recipe('osl-repos::epel') }
    it { is_expected.to install_build_essential('nvidia_driver') }
    it { is_expected.to install_package(%w(dkms kernel-devel-3.10.0-1127.el7.x86_64 kernel-headers-3.10.0-1127.el7.x86_64)) }

    it do
      is_expected.to create_if_missing_remote_file('/var/chef/cache/cuda_linux.run').with(
        source: 'https://developer.download.nvidia.com/compute/cuda/11.7.1/local_installers/cuda_11.7.1_515.65.01_linux_ppc64le.run',
        show_progress: true
      )
    end

    it do
      is_expected.to run_execute('cuda_linux.run').with(
          command: 'sh /var/chef/cache/cuda_linux.run --extract=/var/chef/cache/cuda_extracted',
          creates: '/var/chef/cache/cuda_extracted'
        )
    end

    it do
      is_expected.to run_execute('NVIDIA-Linux.run').with(
          command: "sh /var/chef/cache/cuda_extracted/NVIDIA-Linux-ppc64le-515.65.01.run   --silent --disable-nouveau --dkms\n",
          live_stream: true
        )
    end

    it { is_expected.to_not delete_directory('/var/chef/cache/cuda_extracted').with(recursive: true) }

    context 'driver installed' do
      before do
        allow_any_instance_of(OSLGPU::Cookbook::Helpers).to receive(:nvidia_driver_installed?).and_return(true)
      end
      cached(:subject) { chef_run }

      it { is_expected.to_not run_execute('cuda_linux.run') }
      it { is_expected.to_not run_execute('NVIDIA-Linux.run') }
      it { is_expected.to delete_directory('/var/chef/cache/cuda_extracted').with(recursive: true) }
    end
  end

  context 'almalinux 8 - x86' do
    platform 'almalinux', '8'
    cached(:subject) { chef_run }
    step_into :osl_nvidia_driver

    it { is_expected.to remove_package('dracut-config-generic') }
    it { is_expected.to disable_osl_nouveau_driver('default') }
    it { is_expected.to include_recipe('osl-repos::alma') }
    it { is_expected.to include_recipe('osl-repos::epel') }
    it do
      is_expected.to create_yum_repository('cuda').with(
        baseurl: 'https://developer.download.nvidia.com/compute/cuda/repos/rhel$releasever/$basearch',
        gpgcheck: true,
        gpgkey: 'https://developer.download.nvidia.com/compute/cuda/repos/rhel$releasever/$basearch/D42D0685.pub'
      )
    end
    it { is_expected.to install_package('kernel-devel-4.18.0-348.2.1.el8_5.x86_64') }
    it { is_expected.to install_dnf_module('nvidia-driver:latest-dkms') }
  end

  context 'almalinux 8 - ppc64le' do
    platform 'almalinux', '8'
    automatic_attributes['kernel']['machine'] = 'ppc64le'
    cached(:subject) { chef_run }
    step_into :osl_nvidia_driver

    it { is_expected.to disable_osl_nouveau_driver('default') }
    it { is_expected.to include_recipe('osl-repos::alma') }
    it { is_expected.to include_recipe('osl-repos::epel') }
    it do
      is_expected.to create_yum_repository('cuda').with(
        baseurl: 'https://developer.download.nvidia.com/compute/cuda/repos/rhel$releasever/$basearch',
        gpgcheck: true,
        gpgkey: 'https://developer.download.nvidia.com/compute/cuda/repos/rhel$releasever/$basearch/D42D0685.pub'
      )
    end
    it { is_expected.to install_package('kernel-devel-4.18.0-348.2.1.el8_5.x86_64') }
    it { is_expected.to install_dnf_module('nvidia-driver:latest-dkms') }
  end

  context 'ubuntu 20.04 - x86' do
    platform 'ubuntu', '20.04'
    cached(:subject) { chef_run }
    step_into :osl_nvidia_driver

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

    it { is_expected.to_not remove_package('dracut-config-generic') }
    it { is_expected.to disable_osl_nouveau_driver('default') }
    it { is_expected.to periodic_apt_update('cuda-keyring') }
    it { is_expected.to install_package('nvidia-driver-515').with(timeout: 3600) }
  end

  context 'ubuntu 20.04 - ppc64le' do
    platform 'ubuntu', '20.04'
    automatic_attributes['kernel']['machine'] = 'ppc64le'
    cached(:subject) { chef_run }
    step_into :osl_nvidia_driver

    it { is_expected.to_not remove_package('dracut-config-generic') }
    it { is_expected.to disable_osl_nouveau_driver('default') }
    it { is_expected.to_not include_recipe('osl-repos::epel') }
    it { is_expected.to install_build_essential('nvidia_driver') }
    it { is_expected.to install_package(%w(dkms linux-headers-5.11.0-1020-aws)) }

    it do
      is_expected.to create_if_missing_remote_file('/var/chef/cache/cuda_linux.run').with(
        source: 'https://developer.download.nvidia.com/compute/cuda/11.7.1/local_installers/cuda_11.7.1_515.65.01_linux_ppc64le.run',
        show_progress: true
      )
    end

    it do
      is_expected.to run_execute('cuda_linux.run').with(
          command: 'sh /var/chef/cache/cuda_linux.run --extract=/var/chef/cache/cuda_extracted',
          creates: '/var/chef/cache/cuda_extracted'
        )
    end

    it do
      is_expected.to run_execute('NVIDIA-Linux.run').with(
          command: "sh /var/chef/cache/cuda_extracted/NVIDIA-Linux-ppc64le-515.65.01.run   --silent --disable-nouveau --dkms\n",
          live_stream: true
        )
    end

    context 'driver installed' do
      before do
        allow_any_instance_of(OSLGPU::Cookbook::Helpers).to receive(:nvidia_driver_installed?).and_return(true)
      end
      cached(:subject) { chef_run }

      it { is_expected.to_not run_execute('cuda_linux.run') }
      it { is_expected.to_not run_execute('NVIDIA-Linux.run') }
      it { is_expected.to delete_directory('/var/chef/cache/cuda_extracted').with(recursive: true) }
    end
  end
end
