require 'spec_helper'

domains = [ 'example.com', 'another.com' ]

describe 'sssd', :type => 'class' do

  context "Should install package, create user, config files and run stunnel service" do
    let(:params) { {
        :domains => domains,
        :type => 'ad'
      } }

    it do

      should contain_package('authconfig').that_comes_before('File[/etc/sssd/sssd.conf]')
      should contain_package('sssd').that_comes_before('File[/etc/sssd/sssd.conf]')

      should contain_file('/etc/sssd/sssd.conf').with(
        'mode'    => '0600',
        'owner'   => 'root',
        'group'   => 'root',
      ).that_notifies('Service[sssd]')
      .with_content(/\[sssd\]/)
      .with_content(/config_file_version = 2/)
      .with_content(/services = nss, pam/)
      .with_content(/domains = example.com,another.com/)
      .with_content(/\[nss\]/)
      .with_content(/filter_groups = root/)
      .with_content(/filter_users = root/)
      .with_content(/\[pam\]/)
      .with_content(/\[domain\/example.com\]/)
      .with_content(/\[domain\/another.com\]/)
      .with_content(/id_provider = ad/)
      .with_content(/access_provider = ad/)

      should contain_service('sssd').with(
          'ensure'      => 'running',
          'enable'      => true,
          'subscribe'   => 'File[/etc/sssd/sssd.conf]',
      )
    end

  end
end
