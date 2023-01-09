#!/usr/bin/perl
use strict;
use warnings;
use 5.20.0;

=head1 NAME

vpn-connect.pl - Connect to the Spareroom VPN

=head2 Usage

This script prompts you to sign into 1Password with your master password, then connects to the Spareroom VPN.

To configure correctly, you need to have a 1Password account with a login item called "Forticlient VPN" with the following fields:

- host : "vpn.spareroom.co.uk:10443"
- username : your username
- password : your password

=begin HTML

<img src="./vpn-connect.png" alt="vpn-connect" width="500" />

=end HTML

You also need the 1Password CLI, available here: L<https://developer.1password.com/docs/cli/get-started/#install>

You also need openfortivpn:

    brew install openfortivpn

or

    sudo apt install openfortivpn

I use this because the desktop version of forticlient is pretty bad.

=cut

my $op_signin = `op signin`;
$op_signin =~ /export (\S+)="(\S+)"/;
$ENV{$1} = $2;

my $vpn_creds = `op item get "Forticlient VPN"`;
$vpn_creds =~ /host:\s+(\S+)/;
my $host = $1;
$vpn_creds =~ /username:\s+(\S+)/;
my $username = $1;
$vpn_creds =~ /password:\s+(\S+)/;
my $password = $1;

`sudo openfortivpn $host --username $username --password $password`;
