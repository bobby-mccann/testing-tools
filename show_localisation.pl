#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';
use Path::Tiny 'path';
use 5.20.0;
use lib '/secure/lib';
use SR::Localisation::Util;
use SR::Encode::Util qw/encode_utf8/;

$ENV{DEVELOPMENT} = 1;

my $filename = shift or die "needs filename";
my $Line_Number = shift or die "needs line number";

my @Lines = path($filename)->lines_utf8;

my $line = $Lines[$Line_Number - 1];
$line =~ /localisation\(["']([\w\.]+)/;
my $context = $1;

say "Context: $context";
my %flags = (
    'en_GB' => '🇬🇧',
    'en_US' => '🇺🇸',
    'fr_FR' => '🇫🇷',
);
for ('en_GB', 'en_US', 'fr_FR') {
    say "$flags{$_} ". encode_utf8 SR::Localisation::Util::specific_locale_localisation($_, $context);
}