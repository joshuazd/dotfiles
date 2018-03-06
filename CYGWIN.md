# Cygwin setup with Vagrant box

Setup cygwin (mintty) and a vagrant box to make the clipboard work properly

In Vagrantfile:

```ruby
config.ssh.forward_agent = true
config.ssh.forward_x11 = true
```

Start vagrant box `vagrant up`

Before ssh, run

```bash
startxwin &
export DISPLAY=':0'
```
