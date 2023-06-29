#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';
use Path::Tiny 'path';

$ENV{DEVELOPMENT} = 1;

my $filename = shift or die "needs filename";
my ($secure_repo_path) = ($filename =~ qr#(.*/secure).+#);

$filename =~ s#^$secure_repo_path/t##;

system(qq{ $secure_repo_path/bin/dev/tools/aggregate_tests.pl -a $filename -r $secure_repo_path });
system qq{ $secure_repo_path/bin/dev/tools/aggregate_tests.pl -c -r $secure_repo_path };
