
__Hands-on: Data transfer with SSH__

This part is simply a reminder about how to easily


## Pre-requisite: deploy two VMs

If not yet done, create a YAML file `vagrant/config.yaml` with the following content:

~~~yaml
# -*- mode: yaml; -*-
:defaults:
  :mode: distributed
~~~

See `vagrant/config.yaml.sample` for all possible options -- you might want to adapt the `:ram` and `:vcpus` settings to match your laptop capacities.

See the result:

~~~bash
$> vagrant status
$> vagrant up
~~~

You should now have 2 VMs set.

## SSH: your new army knife tool

Resources:

* My personal [tutorial on SSH](varrette.gforge.uni.lu/tutorial/ssh.html)
* the [ULHPC Access / SSH Tutorial](https://hpc.uni.lu/users/docs/access.html)

The way SSH handles the keys and the configuration files is illustrated in the following figure:

![SSH key management](https://hpc.uni.lu/images/docssh/schema.png)


### SSH Key generation

In order to be able to transparently connect between the VMS, you'll first need to generate the key pairs on each VMs

```bash
# Generation of the key pair for 'vagrant' on VM 'vm':
(vm)$> vagrant ssh default
(vm)$> hostname
vm.vagrant.dev
(vm)$> whoami
vagrant

(vm)$> ssh-keygen -t rsa -b 4096 -o -a 100
# -o: using the new format for OpenSSH
# -a 100: improve the key quality
```

Leave the passphrase empty for this tutorial -- it's of course recommended to set a **strong** passphrase for your personal key pair.
The above command will generate two keys:

* `~/.ssh/id_rsa`: the **private** key you should **NEVER EVER** transmit
* `~/.ssh/id_rsa.pub`: the **public** counterpart, **safe** to distribute and to append to the `~/.ssh/authorized_keys`

Get the key:

```bash
(vm)$> cat ~/.ssh/id_rsa.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCsxTDNOghS06wqA1zQeZvMCaE3rogxA3PNCpPUdajBPWzlNIgo5xaLBt6xODKJssc1wksRynWnaa3e4rRahDmw8c6EsC+REQhWd6Vp0Wi87dydOZWYP1qZMhxVZKRTPOGWiDw1bpVYpspPGG2OuBNZSS9K+GHrm7QHknYuZeKJYsaa0o3ovR6pz9wUBywx2NJy8WfMte/NmWrdkEJPMlu4nKYHfxTbsM2LeMr5vNOpcQBDM4PuI4LXS4QYJhJ90iyEHP0Oanf1B0BhYjyV9jZI9UuDTPzOsCQe5ua1xoJDAtthSE9oIr9P4VP0iQeSaN86UA2QE91grzDV9R71nWbp6w4eCkcDoTNGCYyHoQWBYA6kIXz++AtQtbCDmSnrz1qj66bLeC/R+OicrG5JAu3+9KgsCWazu6JMtmbAd1jBrvaJCMmTXzOAVPDMOIPo1IvHP1iKhJ+se2QQAjtegnH2mC8fHIVZhXaRT5reY2SFkBR+T6SlJo0Zq03HBopcbSRXm6eAYI4CS1kOdeWjviCd4a2Tn4lLjqNNySl5om/JG08l+BQuvHROViK5hbvmYZmB2EuYggl1aS2LyfqbQ8G9OqE7r7vMAlCC0FMwXE0hE+/Y1Pbs/yBoZGDKL8B6x8UE8Vs3WwdG4X6tAGJvfCjXS1PrGEv13SuHgUxJs806xQ== vagrant@vm.vagrant.dev

# Check the fingerprint of the generated **public** key
(vm)$> ssh-keygen -l -f ~/.ssh/id_rsa.pub
4096 SHA256:wsJfnBc9mE8XWoU30KRJ0Ib7c7UNUQej7By/J79pCTw vagrant@vm.vagrant.dev (RSA)
```

Repeat on the second machine:

```bash
# Generation of the key pair for 'vagrant' on VM 'node-1':
$> vagrant ssh node-1
(node-1)$> hostname
node-1.vagrant.dev
(node-1)$> whoami
vagrant

(node-1)$> ssh-keygen -t rsa -b 4096 -o -a 100
(node-1)$> cat ~/.ssh/id_rsa.pub
```

Now authorize the key of the first (default) VM by **appending** the **public** key in the `~/.ssh/authorized_keys` file of the second VM:

```
(node-1)$> vim ~/.ssh/authorized_keys
[...]

# Check the fingerprint of the
(node-1)$> ssh-keygen -l -f ~/.ssh/authorized_keys
2048 SHA256:E3uwLusnwvgSjYKGjnKu3kzGPONPXxYMBSgxjMk4DcU vagrant (RSA)
4096 SHA256:wsJfnBc9mE8XWoU30KRJ0Ib7c7UNUQej7By/J79pCTw vagrant@vm.vagrant.dev (RSA)   # Ensure this matches the expected fingerprint
```

### Data transfer over SSH with `scp`

You should now be able to connect **transparently from `vm` to `node-1`**.

```bash
$> vagrant ssh default     # If not yet done
(vm)$> cat /etc/hosts      # Thanks https://github.com/oscar-stack/vagrant-hosts
(vm)$> ssh node-1
(node-1)$>     # CTRL-D to disconnect
```

This would also permit you to transfer an [big] file from `vm` to `node-1` using `scp`.

```bash
# Quickly generate a 2 GB file
(vm)$> dd if=/dev/zero of=/tmp/bigfile.txt bs=100M count=20
# Now try to transfert it between the 2 Vagrant boxes ;)
# Using scp -- prepend with time to see the duration of the command
(vm)$> time scp /tmp/bigfile.txt node-1:/tmp/

# Repeat it
(vm)$> time scp /tmp/bigfile.txt node-1:/tmp/
```

**Question**: compare the obtained time. What do you notice ?

### Data transfer over SSH with `rsync`

Now let's try again with `rsync`

```bash
# Start to clean i.e. remove the target file
(vm)$> ssh node-1 -- rm -f /tmp/bigfile.txt

# Repeat the transfer with rsync
(vm)$> time rsync -avzu /tmp/bigfile.txt node-1:/tmp/
(vm)$> time rsync -avzu /tmp/bigfile.txt node-1:/tmp/
```

**Question**: compare the obtained time. What do you notice ?

Repeat the operations in the reverse order
