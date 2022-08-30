source 'https://supermarket.chef.io'

solver :ruby, :required

cookbook 'osl-repos', git: 'git@github.com:osuosl-cookbooks/osl-repos'

# Test
cookbook 'apt'
cookbook 'osl-gpu-test', path: 'test/cookbooks/osl-gpu-test'

metadata
