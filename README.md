# osl-gpu

Install and manage drivers or software related to GPU hardware

## Requirements

### Platforms

- RHEL 8
- Ubuntu 20.04

### Cookbooks

- [yum](https://supermarket.chef.io/cookbooks/yum)
- [osl-repos](https://github.com/osuosl-cookbooks/osl-repos)

## Resources

The following resources are provided:

- [osl_cuda](documentation/osl_cuda.md)
- [osl_nouveau_driver](documentation/osl_nouveau_driver.md)
- [osl_nvidia_driver](documentation/osl_nvidia_driver.md)

## Contributing

1. Fork the repository on Github
1. Create a named feature branch (like `username/add_component_x`)
1. Write tests for your change
1. Write your change
1. Run the tests, ensuring they all pass
1. Submit a Pull Request using Github

## License and Authors

- Author:: Oregon State University <chef@osuosl.org>

```text
Copyright:: 2022, Oregon State University

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
