VPS Setup Scripts
==============================================================================

To get started:

- Sign up with a Cloud VPS Provider, such as DigitalOcean, Amazon AWS, MS Azurre
- Choose "Ubuntu 20.04" image (`/etc/ssh/sshd_config.d/` does not exist in 18.04)
- Set root password (root SSH login will be disabled by this setup)
- Log in via SSH or Cloud Provider VPS Web Console
- Run this to bootstrap the setup environment:

```sh
bash <(wget -qO - -- 'https://github.com/MestreLion/vps/raw/master/bootstrap.sh')
```

- Edit the setup variables in the config file, by default `/etc/vps.conf`.
