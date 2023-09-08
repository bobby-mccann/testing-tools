#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';

my $is_import = 0;
my @import_lines;
my @non_import_lines;

my $file = shift;
open(FH, '<', $file);

for (<FH>) {
    if ( $_ =~ /^\s*use\s/ ) {
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
close;

open (FH, '>', $file);
print FH (@import_lines, "\n", @non_import_lines);
close;