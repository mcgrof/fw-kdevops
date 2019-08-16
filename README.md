# fw-kdevops

fw-kdevops is a fork of [kdevops](https://github.com/mcgrof/kdevops),
simplified for *only* testing the Linux kernel firmware loader.

Only two target hosts are provisioned:

  * fw-stable: tracks the baseline
  * fw-dev: let's you test development patches

## Firmware loader kconfig options

We test the firmware loader through the Linux kernel's selftests framework,
and selftests lets you declare which kernel configurations are required to
test a target subsystem. These are the respective kernel configuration options
we enable on our test hosts:

```
CONFIG_TEST_FIRMWARE=y
CONFIG_FW_LOADER=y
CONFIG_FW_LOADER_USER_HELPER=y
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
```

The code in question we test inside the Linux kernel is what implements
the `CONFIG_FW_LOADER`, so all the code under:

``` 
drivers/base/firmware_loader/
```

## Install dependencies


You should have installed ansible, vagrant and terraform (hopefully we'll have
a local ansinle role to do this eventually). After that, all you have to do is:

```bash
make deps
```

Be sure to read the recommendations on the
[kdevops](https://github.com/mcgrof/kdevops) about how to let your
regular user be able to run qemu. Eventually this should be as easy
as optionally running a local ansible role, but for now this requires
a bit of manual effort.

## Provisioning hosts with vagrant

```bash
cd vagrant/
vagrant up
```

## Destroying provisioned nodes with vagrant

You can either destroy directly with vagrant:

```bash
cd vagrant/
vagrant destroy -f
# This last step is optional
rm -rf .vagrant
```

Or you can just use virsh directly, if using KVM:

```bash
sudo virsh list --all
sudo virsh destroy name-of-guest
sudo virsh undefine name-of-guest
```

## Terraform support

Read the [kdevops_terraform](https://github.com/mcgrof/kdevops_terraform)
documentation, then come here and read this.

Terraform is used to deploy your solution on cloud virtual machines. Below are
the list of clouds currently supported:

  * azure
  * openstack (special minicloud support added)
  * aws

### Provisioning with terraform

```bash
make deps
cd terraform/you_provider
make deps
terraform init
terraform plan
terraform apply
```

Because cloud providers can take time to make hosts accessible via ssh, the
only thing we strive for is update your `~/ssh/config` for you. Once the
hosts become available you are required to run ansible yourself.

#### Terraform ssh config update

We provide support for updating your ssh configuration file (typically
`~/.ssh/config`) automatically for you, however each cloud provider requires
support to be added in order for this to work. Below is the status of support
for this by different cloud providers we support:

  * OpenStack
   * Generic OpenStack solutions
   * Minicloud
  * Azure: requires work
  * AWS: requires work

## Running ansible

Before running ansible make sure you can ssh into the hosts listed on
ansible/hosts. So try:


```bash
ssh fw-dev
ssh fw-stable
```

Next to run ansible to install and reboot into the latest linux version this
project tracks:

```bash
ansible-playbook -i hosts playbooks/bootlinux.yml
```

You can use a different tag for the kernel revision from the command line, and
even add an extra patch to test on top a kernel. Say we're in the future on
September 15, 2022 and you want to test that day's version of linux-next with
your hacks implemented on fw-is-cool.patch. You can use:

```bash
ansible-playbook -i hosts -l dev --extra-vars "target_linux_version=next-20220915 target_linux_extra_patch=fw-is-cool.patch" bootlinux.yml
```

You would have these files in place as well:

```bash
~/.ansible/roles/mcgrof.bootlinux/templates/fw-is-cool.patch
~/.ansible/roles/mcgrof.bootlinux/templates/next-20220915
```

### Public ansible role documentation

The following public roles are used, and so have respective upstream
documentation which can be used if one wants to modify how the role
runs with additional tags or extra variables from the command line:

  * [create_partition](https://github.com/mcgrof/create_partition)
  * [update_ssh_config_vagrant](https://github.com/mcgrof/update_ssh_config_vagrant)
  * [devconfig](https://github.com/mcgrof/devconfig)
  * [bootlinux](https://github.com/mcgrof/bootlinux)

Kernel configuration files are tracked in the [bootlinux](https://github.com/mcgrof/bootlinux)
role. If you need to update a kernel configuration for whatever reason, please
submit a patch for the [bootlinux](https://github.com/mcgrof/bootlinux)
role upstream.

License
-------

This work is licensed under the GPLv2, refer to the [LICENSE](./LICENSE) file
for details. Please stick to SPDX annotations for file license annotations.
If a file has no SPDX annotation the GPLv2 applies. We keep SPDX annotations
with permissive licenses to ensure upstream projects we embraced under
permissive licenses can benefit from our changes to their respective files.
