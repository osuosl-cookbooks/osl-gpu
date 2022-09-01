[Back to resource list](../README.md#resources)

# osl_cuda

Install CUDA toolkit software

## Actions

| Action     | Description                   |
| ---------- | ----------------------------- |
| `:install` | Install CUDA toolkit software |

## Properties

| Name              | Type            | Default                       | Description                                                           |
| ----------------- | --------------- | ----------------------------- | --------------------------------------------------------------------- |
| `add_repos`       | `true`, `false` | `true`                        | Add dependent repositories that may be needed                         |
| `version`         | String          | Resource name                 | Major and minor version of CUDA. Setting `latest` will install `11.7` |
| `runfile_install` | `true`, `false` | See `runfile_install?` helper | Install software from runfile instead of a software repository        |

## Examples

```ruby
# Install latest version
osl_cuda 'latest'

# Install version 11.7
osl_cuda '11.7'

# Install using runfile method with latest
osl_cuda 'latest' do
  runfile_install true
end
```
