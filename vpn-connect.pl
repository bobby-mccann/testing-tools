#!/usr/bin/perl
use strict;
use warnings;
use 5.20.0;

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
