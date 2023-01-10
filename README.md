# Tools for IntelliJ IDEA

## Perl Plugin

Install the Perl plugin from the IntelliJ IDEA plugin repository.
Cmd+Shift+A (or Ctrl+Shift+A) and search for "Plugins", then search for "Perl".

## SR-Bashrc

I have provided a bashrc file that provides many useful aliases.
It assumes that you store your work repos in ~/Work, but you can change this
by editing the bashrc file.
I recommend that you source the file in your ~/.bashrc file.

## docker-perl.pl

This is a script for running Perl code from the IntelliJ plugin.

![img.png](img.png)

Then choose the docker-perl.pl script as the interpreter. It is a script designed to trick
IntelliJ into thinking it's running local perl, but it's actually using the dev-box.

## External Tools

TODO: Export my external tools.

## Running Tests

Now that perl is set up, you should be able to run tests as normal from IntelliJ.

### TODO

- External tools
- Live templates
- Code templates
- 1Password setup
- VPN connect