module OSLGPU
  module Cookbook
    module Helpers
      include Chef::Mixin::ShellOut

      def runfile_install?
        case node['kernel']['machine']
        when 'ppc64le'
          if platform_family?('rhel') && node['platform_version'].to_i == 8
            false
          else
            true
          end
        else
          false
        end
      end

      def cuda_keyring_url
        platform = "#{node['platform']}#{node['platform_version'].gsub('.', '')}"
        arch = node['kernel']['machine']
        "https://developer.download.nvidia.com/compute/cuda/repos/#{platform}/#{arch}/cuda-keyring_1.0-1_all.deb"
      end

      def driver_pkg_version(version)
        if version == 'latest'
          if platform_family?('rhel')
            'latest-dkms'
          else
            '515'
          end
        else
          version
        end
      end

      def runfile_suffix
        case node['kernel']['machine']
        when 'ppc64le'
          'linux_ppc64le.run'
        else
          'linux.run'
        end
      end

      def runfile_versions(version)
        case version
        when '515', '11.7', 'latest'
          {
            'driver' => '515.65.01',
            'cuda' => '11.7.1',
          }
        end
      end

      def runfile_pkgs
        if platform_family?('rhel')
          [
            'dkms',
            "kernel-devel-#{node['kernel']['release']}",
            "kernel-headers-#{node['kernel']['release']}",
          ]
        else
          [
            'dkms',
            "linux-headers-#{node['kernel']['release']}",
          ]
        end
      end

      def default_runfile_url(version)
        runfile_ver = runfile_versions(version)
        run_file = "cuda_#{runfile_ver['cuda']}_#{runfile_ver['driver']}_#{runfile_suffix}"

        "https://developer.download.nvidia.com/compute/cuda/#{runfile_ver['cuda']}/local_installers/#{run_file}"
      end

      def nvidia_runfile(version)
        "NVIDIA-Linux-#{node['kernel']['machine']}-#{runfile_versions(version)['driver']}.run"
      end

      def nvidia_driver_installed?
        cmd = shell_out!('modinfo nvidia')
        cmd.exitstatus == 0
      rescue
        false
      end

      def cuda_installed?(version)
        ::File.exist?("/usr/local/cuda-#{version}")
      end

      def cuda_pkg_ver(version)
        version.gsub('.', '-')
      end

      def update_grub
        if platform_family?('rhel')
          if node['kernel']['machine'] == 'aarch64'
            'grub2-mkconfig -o /boot/efi/EFI/centos/grub.cfg'
          else
            'grub2-mkconfig -o /boot/grub2/grub.cfg'
          end
        else
          'update-grub'
        end
      end
    end
  end
end
