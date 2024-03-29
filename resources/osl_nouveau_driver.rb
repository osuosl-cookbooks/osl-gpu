resource_name :osl_nouveau_driver
provides :osl_nouveau_driver
unified_mode true
include OSLGPU::Cookbook::Helpers

default_action :disable

action :disable do
  package 'dracut-config-generic' do
    action :remove
  end if platform_family?('rhel')

  kernel_module 'nouveau' do
    action :blacklist
    notifies :run, 'execute[update-initrd]'
    notifies :run, 'execute[update-grub]'
  end

  execute 'update-initrd' do
    command update_initrd
    action :nothing
  end

  execute 'update-grub' do
    command update_grub
    action :nothing
  end
end

action_class do
  include OSLGPU::Cookbook::Helpers
end
