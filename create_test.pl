#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';
use File::Copy;
use File::Path qw(make_path);

my $filename = shift or die "needs filename";
my $line_number = shift or die "needs line number";

open(FH, '<', $filename) or die $!;

my $current_line = 0;
while(<FH>){
    $current_line += 1;
    if ($current_line == $line_number) {
        print "found line\n";
        $_ =~ /.*sub (\S+)/;
        my $function_name = $1;
        return unless defined $function_name;

        $filename =~ s#lib#t/lib#;
        $filename =~ s#.pm#/#;
        make_path($filename);
        $filename .= $function_name . ".t";
        print $filename . "\n";
        copy("/Users/bobbymccann/Code/testing-tools/test_template.t", $filename);
        system(qq{
            open -na "IntelliJ IDEA.app" --args "$filename"
        });
    }
}