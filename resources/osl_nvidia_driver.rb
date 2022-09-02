resource_name :osl_nvidia_driver
provides :osl_nvidia_driver
unified_mode true
include OSLGPU::Cookbook::Helpers

default_action :install

property :add_repos, [true, false], default: true
property :version, String, name_property: true
property :runfile_install, [true, false], default: lazy { runfile_install? }

action :install do
  file_path = Chef::Config[:file_cache_path]

  if new_resource.runfile_install
    include_recipe 'osl-repos::epel' if platform_family?('rhel') && new_resource.add_repos

    build_essential 'nvidia_driver'

    package runfile_pkgs

    remote_file "#{file_path}/cuda_linux.run" do
      source default_runfile_url(new_resource.version)
      show_progress true
      action :create_if_missing
    end

    execute 'cuda_linux.run' do
      command "sh #{file_path}/cuda_linux.run --extract=#{file_path}/cuda_extracted"
      creates "#{file_path}/cuda_extracted"
      not_if { nvidia_driver_installed? }
    end

    execute 'NVIDIA-Linux.run' do
      command <<~EOC
        sh #{file_path}/cuda_extracted/#{nvidia_runfile(new_resource.version)} \
          --silent --disable-nouveau --dkms
      EOC
      live_stream true
      not_if { nvidia_driver_installed? }
    end

    directory "#{file_path}/cuda_extracted" do
      recursive true
      action :delete
      only_if { nvidia_driver_installed? }
    end
  else
    nvidia_pkg_ver = driver_pkg_version(new_resource.version)
    case node['platform_family']
    when 'rhel'
      if new_resource.add_repos
        include_recipe 'osl-repos::centos'
        include_recipe 'osl-repos::epel'

        yum_repository 'cuda' do
          baseurl 'https://developer.download.nvidia.com/compute/cuda/repos/rhel$releasever/$basearch'
          gpgcheck true
          gpgkey 'https://developer.download.nvidia.com/compute/cuda/repos/rhel$releasever/$basearch/D42D0685.pub'
        end
      end

      if node['platform_version'].to_i >= 8
        package 'kernel-devel'

        dnf_module "nvidia-driver:#{nvidia_pkg_ver}" do
          action :install
        end
      else
        package [
          "nvidia-driver-#{nvidia_pkg_ver}",
          'kernel-devel',
        ]
      end
    when 'debian'
      remote_file "#{file_path}/cuda-keyring.deb" do
        source cuda_keyring_url
      end

      dpkg_package 'cuda-keyring' do
        source "#{file_path}/cuda-keyring.deb"
        notifies :update, 'apt_update[cuda-keyring]', :immediately
      end

      apt_update 'cuda-keyring'

      package "nvidia-driver-#{nvidia_pkg_ver}" do
        timeout 3600
      end
    else
      raise 'platform not supported'
    end
  end
end

action_class do
  include OSLGPU::Cookbook::Helpers
end
