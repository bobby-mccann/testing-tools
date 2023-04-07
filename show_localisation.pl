#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';
use lib '/secure/lib';
use Path::Tiny 'path';
use 5.20.0;
use SR::Encode::Util qw/decode_utf8 encode_utf8/;

$ENV{GIT_REPOS} ||= '~/Work';

my $filename = shift or die "needs filename";
my $Line_Number = shift or die "needs line number";

my @Lines = path($filename)->lines_utf8;

my $line = $Lines[$Line_Number - 1];
$line =~ /localisation\(["']([\w\.]+)/;
my $context = $1;

say "Context: $context";
$context = "'$context'";

my $dollar_underscore = '$_';
$ENV{_} = '$_';
#@inject PERL5
my $perl = qq{
use SR::Localisation::Util;
use SR::Encode::Util qw/encode_utf8/;
use 5.20.0;

for (SR::Localisation::Util::locales) {
    say $dollar_underscore . ': ' . SR::Localisation::Util::get_translation($dollar_underscore, $context);
}
};

say `GIT_REPOS=~/Work ./docker-perl.pl perl -e "$perl"`;