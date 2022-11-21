#!/usr/bin/perl
use strict;
use warnings;
use 5.20.0;
use Getopt::Long;
use Path::Tiny qw/path/;

# Get options for file name, cursor row and column, selection start and end rows and columns:
GetOptions(
    'file=s' => \my $file,
    'row=i' => \my $row,
    'col=i' => \my $col,
    'selrow=i' => \my $selrow,
    'selcol=i' => \my $selcol,
    'selendrow=i' => \my $selendrow,
    'selendcol=i' => \my $selendcol,
);

my @lines = path($file)->lines_utf8;

say get_package_name();

sub get_selected {
    if (defined($selcol) && defined($selendcol) && defined($selrow) && defined($selendrow)) {
        if ($selrow == $selendrow) {
            return substr($lines[$selrow], $selcol, $selendcol - $selcol);
        } else {
            my $selected = substr($lines[$selrow], $selcol);
            for my $i ($selrow + 1 .. $selendrow - 1) {
                $selected .= $lines[$i];
            }
            $selected .= substr($lines[$selendrow], 0, $selendcol);
            return $selected;
        }
    }
}

sub get_package_name {
    for (@lines) {
        $_ =~ /package (.+);$/;
        return $1 if defined($1);
    }
}

sub get_function_name {
    my $line_number = shift;
    my $line = $lines[$line_number-1];

    print $line;
    $line =~ /.*(sub|has) (\S+)/;
    return $2;
}

sub get_selected_module {
    my $line = $lines[$row];
    my @matches = ($line =~ /[a-zA-z0-9:]+/);
    my $last_match_pos = pos $matches[0];
    for (@matches) {
        my $pos = pos $_;
        return $_ if ($pos > $last_match_pos && $pos < $col);
        $last_match_pos = $pos;
    }
}
