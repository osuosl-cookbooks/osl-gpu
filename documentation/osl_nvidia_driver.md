[Back to resource list](../README.md#resources)

# osl_nvidia_driver

Install Nvidia device driver

## Actions

| Action     | Description                  |
| ---------- | ---------------------------- |
| `:install` | Install Nvidia device driver |

## Properties

| Name              | Type            | Default                       | Description                                                    |
| ----------------- | --------------- | ----------------------------- | -------------------------------------------------------------- |
| `add_repos`       | `true`, `false` | `true`                        | Add dependent repositories that may be needed                  |
| `version`         | String          | Resource name                 | Major version of driver. Setting `latest` will install `515`   |
| `runfile_install` | `true`, `false` | See `runfile_install?` helper | Install software from runfile instead of a software repository |

## Examples

```ruby
# Install latest version
osl_nvidia_driver 'latest'

# Install version 515
osl_nvidia_driver '515'

# Install using runfile method with latest
osl_nvidia_driver 'latest' do
  runfile_install true
end
```
