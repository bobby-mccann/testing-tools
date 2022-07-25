#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';
use Path::Tiny 'path';

$ENV{DEVELOPMENT} = 1;

my $filename = shift or die "needs filename";
my $Line_Number = shift or die "needs line number";
my $editor = shift || 'vi';

my @Lines = path($filename)->lines_utf8;

my $package_name = get_package_name(@Lines);
my $function_name = get_function_name($Line_Number, @Lines);
exit 1 unless defined $function_name;

my $test_directory = path(get_test_directory($filename));
$test_directory->mkpath;
my $test_path = $test_directory->child("$function_name.t");

my $secure_repo_path = get_repo_directory($filename);

unless (-e $test_path) {
    my $Test_Template = "$secure_repo_path/../testing-tools/test_template.t";
    my $template = path($Test_Template)->slurp_utf8;
    $template =~ s/package_name/$package_name/g;
    $template =~ s/function_name/$function_name/g;
    $test_path->spew_utf8($template);

    system qq{ git -C $secure_repo_path add $test_path };

    # Path for aggregate_tests.pl has to be relative to the test directory
    $test_path =~ qr#secure/t/(.+)#;
    system(qq{ $secure_repo_path/bin/dev/tools/aggregate_tests.pl -a $1 -r $secure_repo_path });
}
system qq{ $editor $test_path };
system qq{ $secure_repo_path/bin/dev/tools/aggregate_tests.pl -c -r $secure_repo_path };

sub get_package_name {
    my @lines = @_;
    for (@lines) {
        $_ =~ /package (.+);$/;
        return $1 if defined($1);
    }
}

sub get_function_name {
    my $line_number = shift;
    my @lines = @_;
    my $line = $lines[$line_number-1];

    print $line;
    $line =~ /.*(sub|has) (\S+)/;
    return $2;
}

sub get_test_directory {
    my $package_path = shift;
    # Should go in /secure/t instead of /secure
    $package_path =~ s#/secure#/secure/t#
        # Unless we're testing something in /t/
        unless $package_path =~ qr#/t/#;
    # Test directory doesn't have file extension
    $package_path =~ s#.pm#/#;
    return $package_path;
}

sub get_repo_directory {
    my $package_path = shift;
    $package_path =~ qr#(.*/secure).+#;
    return $1;
}