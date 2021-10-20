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

        $filename =~ s#/secure#/secure/t#;
        $filename =~ s#.pm#/#;
        make_path($filename);
        $filename .= $function_name . ".t";
        print $filename . "\n";
        unless (-e $filename) {
            copy("/Users/bobbymccann/Code/testing-tools/test_template.t", $filename);

            $filename =~ qr#(.*/secure).+#;
            my $secure_repo_path = $1;
            system(qq{ git -C $secure_repo_path add $filename });

            # Path for aggregate_tests.pl has to be relative to the test directory
            $filename =~ qr#secure/t/(.+)#;
            system(qq{ $secure_repo_path/bin/dev/tools/aggregate_tests.pl -a $1 });
        }
        system(qq{ idea $filename });
    }
}