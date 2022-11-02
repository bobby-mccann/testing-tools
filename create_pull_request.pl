#!/usr/bin/perl
use strict;
use warnings;
use URI::Encode qw(uri_encode uri_decode);

my $branch = uri_encode `git branch --show-current`;
my $url = "https://github.com/SpareRoom/secure/compare/$branch?expand=1";
`open $url`;