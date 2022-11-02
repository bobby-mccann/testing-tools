#!/usr/bin/perl
use strict;
use warnings;
use 5.20.0;
use URI::Encode qw(uri_encode uri_decode);

my $encoder = URI::Encode->new({encode_reserved => 1});
my $branch = `git branch --show-current`;
chomp $branch;
$branch = $encoder->encode($branch);

my $url = "https://github.com/SpareRoom/secure/compare/$branch?expand=1";
`open $url`;