name              'osl-gpu'
maintainer        'Oregon State University'
maintainer_email  'chef@osuosl.org'
license           'All Rights Reserved'
description       'Installs/Configures osl-gpu'
issues_url        'https://github.com/osuosl-cookbooks/osl-gpu/issues'
source_url        'https://github.com/osuosl-cookbooks/osl-gpu'
chef_version      '>= 16.0'
version           '0.1.0'

supports          'centos', '~> 7.0'
supports          'centos_stream', '~> 8.0'
supports          'ubuntu', '~> 20.04'

depends 'yum'
depends 'osl-repos'
