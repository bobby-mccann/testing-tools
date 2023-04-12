# Tools for IntelliJ IDEA

## Perl Plugin

Install the Perl plugin from the IntelliJ IDEA plugin repository.
Cmd+Shift+A (or Ctrl+Shift+A) and search for "Plugins", then search for "Perl".

### Perl Plugin Setup for Secure

#### Replace your .idea/secure.iml with the one from this repository

```shell
cp $SR_ROOT/testing-tools/secure.iml $SR_ROOT/secure/.idea/secure.iml
```

#### Build dev-lite docker image

The following command builds an image and adds it to your local
registry.

```shell
cp $SR_ROOT/docker-development-environment/dev/dot-my.cnf $SR_ROOT/testing-tools/dev-lite/dot-my.cnf
docker build dev-lite -t dev:lite
```

#### Add docker image

![img_1.png](images/img_1.png)

![img_2.png](images/img_2.png)

#### Run with network & volume parameters (making sure dev env is already up)

![img.png](images/img.png)

```
--network
docker-development-environment_spareroom
--env
SR_ROOT=/intellijperl/home/bobby/Work
--env
NO_TEST_LIB=1
```

Now you should be able to run and debug perl tests 
right from the editor.

## [sr-bashrc.sh](sr-bashrc.sh)

I have provided a bashrc file that provides many useful aliases.
You must at least have `$GIT_REPOS` set to wherever you store your repos.
Add the following to your .(ba|z)shrc:

```shell
export GIT_REPOS=~/Work # Or whatever it is you use
source $GIT_REPOS/testing-tools/sr-bashrc.sh
```

## External Tools

To add external tools, go to Settings > External Tools

![img_4.png](images/img_4.png)

![img_5.png](images/img_5.png)

![img_6.png](images/img_6.png)

### TODO

- Live templates
- Code templates
- 1Password setup
- VPN connect