#!/usr/bin/perl

=head1 NAME

failed_tests.pl - List failed tests in recent secure repo github test runs

=cut

use strict;
use warnings FATAL => 'all';
use 5.20.0;
use JSON::XS;
use Encode;
use Term::ANSIColor qw(:constants colored);
use Getopt::Long;
use Path::Tiny qw(path);
use Date::Parse;
use Date::Format;
use Try::Tiny;

my $poll_interval = 10;

my $usage = <<USAGE
Usage: $0 -L [number of runs to show] --git-repos=/home/you/git_repos --git-branch=master [-w]

If git_repos is not provided, it will default to the value in the environment variable GIT_REPOS.

If git_branch is not provided, the current branch will be used.

Passing -w or --watch starts the script in watch mode, and will poll the github API every $poll_interval seconds,
showing any new results as they come in.
USAGE
;

my $opt = {
    amount_of_runs => 1,
    git_repos      => $ENV{GIT_REPOS},
    git_branch     => undef,
};
GetOptions(
    $opt,
    'amount_of_runs|amount-of-runs|L=i',
    'git_repos|git-repos=s',
    'git_branch|git-branch|b=s',
    'help|usage',
    'watch|w',
);

if ($opt->{help}) {
    print $usage;
    exit;
}

die 'Must set $GIT_REPOS environment variable or use --git-repos' unless ($opt->{git_repos});

# my $secure = path($opt->{git_repos})->child('secure');
my $secure = path("/secure");

my $agg_dir = $secure->child('failed_runs');
$agg_dir->mkpath;

our $UTF8 = Encode::find_encoding('UTF-8');

$opt->{git_branch} ||= `git -C $secure branch --show-current`;
$opt->{git_branch} =~ s/\n//;

if ($opt->{watch}) {
    my $runs = get_runs(10, $opt->{git_branch});
    my $last_run_id = 0;
    for (@$runs) {
        if ($_->{status} eq 'completed') {
            $last_run_id = $_->{databaseId};
            say print_run($_);
            last;
        }
    }

    while (1) {
        sleep $poll_interval;
        try {
            my $run = get_runs(1, $opt->{git_branch})->[0];
            if (defined $run && $run->{status} eq 'completed') {
                if ($run->{databaseId} != $last_run_id) {
                    $last_run_id = $run->{databaseId};
                    say print_run($run);
                }
            }
        };
    }
}

if ($opt->{amount_of_runs} == 1) {
    say STDERR "Fetching latest run for $opt->{git_branch}";
} else {
    say STDERR "Fetching latest $opt->{amount_of_runs} runs for $opt->{git_branch}";
}

my $result = get_runs($opt->{amount_of_runs}, $opt->{git_branch});

sub print_run {
    my $run = shift;

    my $output = "";

    my $title = $run->{displayTitle};

    my $pretty_date = _pretty_date($run->{createdAt});
    $output .= colored ['bold black on_yellow'], " $pretty_date ";
    $run->{short_hash} = substr $run->{headSha}, 0, 7; # short version of git hash is 7 chars
    $output .= colored ['bold black on_cyan'], " <$run->{short_hash}> ";

    if ($run->{status} ne 'completed') {
        $output .= colored ['bold black on_yellow'], " … $title ";
    }
    elsif ($run->{conclusion} ne 'success') {
        $output .= colored ['bold black on_red'], " ✗ $title ";
        my $agg_file = aggregate_file_to_create($run);

        if (!$agg_file->exists) {
            my $failed = `gh run view $run->{databaseId} --log-failed` || '';
            my @failed_tests = sort keys { (map {$_ => 1} ($failed =~ /\/secure\/(.*\.t\b)/g)) }->%*;
            write_aggregate($agg_file, $run, \@failed_tests);
            # my $num_failed = scalar(@failed_tests);
            # say colored(["bold red on_black"], "$num_failed failed tests");
        }
        $output .= " file://" . $agg_file;
    } else {
        $output .= colored ['bold black on_green'], " ✓ $title ";
    }
    return $output;
}

sub get_runs {
    my $json_fields = join ',', qw(
        conclusion
        createdAt
        databaseId
        displayTitle
        event
        headBranch
        headSha
        name
        startedAt
        status
        updatedAt
        url
        workflowDatabaseId
        workflowName
    );

    my ($number_of_runs, $git_branch) = @_;
    return decode_json $UTF8->encode(`gh run list -L $number_of_runs -b $git_branch -w "Perl Test Suite" --json $json_fields`);
}

sub _pretty_date {
    my $created_at = str2time(shift);
    my $nice_date = time2str('%Y-%m-%d', $created_at);
    my $nice_time = time2str('%H:%M', $created_at);
    if ($nice_date eq time2str('%Y-%m-%d', time)) {
        return $nice_time;
    } else {
        return "$nice_date $nice_time";
    }
}

sub aggregate_file_to_create {
    my $run = shift;
    return $agg_dir->child("$run->{short_hash}.t");
}

sub write_aggregate {
    my ($agg_file, $run, $failed_tests) = @_;
    my @non_aggs = grep {$_ !~ qr#/aggregate/#} @$failed_tests;
    my $ft_string = join "\n", @non_aggs;

    path($agg_file)
        ->spew_utf8(
        <<PERL5
use SR::Test::Aggregate;

=head1 $run->{headBranch}

$run->{headSha}
$run->{displayTitle}

$run->{createdAt}

=cut
# $run->{url}

SR::Test::Aggregate::run_tests(
    root          => '/secure',
    dirs          => [qw(
$ft_string
    )],
    quick_mocks   => [qw/testimonials build_and_send_email profile_photo xss xss_form/],
    test_warnings => 1
);
PERL5
    );
    return $agg_file;
}

say(print_run($_)) for @$result;