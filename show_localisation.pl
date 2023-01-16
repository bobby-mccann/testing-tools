#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';
use lib '/secure/lib';
use Path::Tiny 'path';
use 5.20.0;
use SR::Encode::Util qw/decode_utf8 encode_utf8/;

my $filename = shift or die "needs filename";
my $Line_Number = shift or die "needs line number";

my @Lines = path($filename)->lines_utf8;

my $line = $Lines[$Line_Number - 1];
$line =~ /localisation\(["']([\w\.]+)/;
my $context = $1;

say "Context: $context";
$context = "'$context'";

#@inject PERL5
my $perl = qq{
use SR::Localisation::Util;
use SR::Encode::Util qw/encode_utf8/;

print SR::Localisation::Util::show_localisation($context);
};

say `./docker-perl.pl perl -e "$perl"`;