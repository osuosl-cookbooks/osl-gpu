resource_name :osl_nouveau_driver
provides :osl_nouveau_driver
unified_mode true
include OSLGPU::Cookbook::Helpers

default_action :disable

action :disable do
  kernel_module 'nouveau' do
    action :blacklist
    notifies :run, 'execute[update-grub]'
  end

  execute 'update-grub' do
    command update_grub
    action :nothing
  end
end

action_class do
  include OSLGPU::Cookbook::Helpers
end
