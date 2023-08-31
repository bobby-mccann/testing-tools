#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';

my $is_import = 0;
my @import_lines;
my @non_import_lines;

for (<>) {
    if ( $_ =~ /^\s*use/ ) {
        $is_import = 1;
        $_ =~ s/^\s*//;
    }
    elsif ( $_ =~/^$/) {

    }
    else {
        $is_import = 0;
    }
    if ($is_import) {
        push @import_lines, $_;
    } else {
        push @non_import_lines, $_;
    }
}
print(@import_lines, "\n", @non_import_lines);