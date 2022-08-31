resource_name :osl_cuda
provides :osl_cuda
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

    build_essential 'cuda'

    package 'tar'

    remote_file "#{file_path}/cuda_linux.run" do
      source default_runfile_url(new_resource.version)
      show_progress true
      action :create_if_missing
      not_if { cuda_installed?(new_resource.version) }
    end

    execute 'cuda_linux.run' do
      command "sh #{file_path}/cuda_linux.run --toolkit --silent"
      creates "/usr/local/cuda-#{new_resource.version}"
    end

    # file resource takes longer for some reason
    execute "rm -f #{file_path}/cuda_linux.run" do
      only_if { cuda_installed?(new_resource.version) }
      only_if { ::File.exist?("#{file_path}/cuda_linux.run") }
    end
  else
    case node['platform_family']
    when 'rhel'
      yum_repository 'cuda' do
        baseurl 'https://developer.download.nvidia.com/compute/cuda/repos/rhel$releasever/$basearch'
        gpgcheck true
        gpgkey 'https://developer.download.nvidia.com/compute/cuda/repos/rhel$releasever/$basearch/D42D0685.pub'
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
    else
      raise 'platform not supported'
    end

    package "cuda-toolkit-#{cuda_pkg_ver(new_resource.version)}" do
      timeout 3600
    end
  end
end

action_class do
  include OSLGPU::Cookbook::Helpers
end
