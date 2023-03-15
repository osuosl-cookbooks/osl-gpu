require_relative '../../spec_helper'

describe 'osl-gpu::default' do
  context 'centos' do
    platform 'centos'
    cached(:subject) { chef_run }
    step_into :osl_nouveau_driver

    it { is_expected.to remove_package('dracut-config-generic') }
    it { is_expected.to blacklist_kernel_module('nouveau') }
    it { expect(chef_run.kernel_module('nouveau')).to notify('execute[update-initrd]').to(:run) }
    it { expect(chef_run.kernel_module('nouveau')).to notify('execute[update-grub]').to(:run) }
    it do
      is_expected.to nothing_execute('update-initrd').with(
        command: 'dracut --force'
      )
    end
    it do
      is_expected.to nothing_execute('update-grub').with(
        command: 'grub2-mkconfig -o /boot/grub2/grub.cfg'
      )
    end
  end

  context 'ubuntu' do
    platform 'ubuntu'
    cached(:subject) { chef_run }
    step_into :osl_nouveau_driver

    it { is_expected.to_not remove_package('dracut-config-generic') }
    it do
      is_expected.to nothing_execute('update-initrd').with(
        command: 'update-initramfs -u'
      )
    end
    it do
      is_expected.to nothing_execute('update-grub').with(
        command: 'update-grub'
      )
    end
  end
end
