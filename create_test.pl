#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';
use Path::Tiny;

my $filename = shift or die "needs filename";
my $line_number = shift or die "needs line number";

my $test_template = "/Users/bobbymccann/Code/testing-tools/test_template.t";

open(FH, '<', $filename) or die $!;

my $current_line = 0;
my $package_name;
while(<FH>){
    $current_line += 1;

    unless (defined($package_name)) {
        $_ =~ /package (.+);$/;
        $package_name = $1 if defined($1);
    }

    if ($current_line == $line_number) {
        print "found line\n";
        $_ =~ /.*(sub|has) (\S+)/;
        my $function_name = $2;
        return unless defined $function_name;

        $filename =~ s#/secure#/secure/t# unless $filename =~ qr#/t/#;
        $filename =~ s#.pm#/#;
        Path::Tiny::path($filename)->mkpath;
        $filename .= $function_name . ".t";
        print $filename . "\n";
        unless (-e $filename) {
            my $template = Path::Tiny::path($test_template)->slurp_utf8;
            $template =~ s/<package_name>/$package_name/g;
            Path::Tiny::path($filename)->spew_utf8($template);

            $filename =~ qr#(.*/secure).+#;
            my $secure_repo_path = $1;
            system(qq{ git -C $secure_repo_path add $filename });

            # Path for aggregate_tests.pl has to be relative to the test directory
            $filename =~ qr#secure/t/(.+)#;
            system(qq{ $secure_repo_path/bin/dev/tools/aggregate_tests.pl -a $1 });
        }
        system(qq{ idea $filename });
        exit 0;
    }
}