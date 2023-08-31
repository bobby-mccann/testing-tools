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
Usage: $0 --git-repos=/home/you/git_repos -b=[branch]

If git_repos is not provided, it will default to the value in the environment variable GIT_REPOS.

If git_branch (b) is not provided, the current branch will be used.
USAGE
;

my $opt = {
    git_repos  => $ENV{GIT_REPOS},
    git_branch => undef,
};
GetOptions(
    $opt,
    'git_repos|git-repos=s',
    'git_branch|git-branch|b=s',
    'help|usage',
);

if ($opt->{help}) {
    print $usage;
    exit;
}

die 'Must set $GIT_REPOS environment variable or use --git-repos' unless ($opt->{git_repos});

my $secure = path($opt->{git_repos})->child('secure');

my $agg_dir = $secure->child('failed_runs');
$agg_dir->mkpath;
$agg_dir->child('.gitignore')->spew(qq{*});

our $UTF8 = Encode::find_encoding('UTF-8');

my $branch = $opt->{git_branch} || current_git_branch();

my $repo = 'Spareroom/secure';

say STDERR "Watching $branch";
my $runs = get_runs(10, $branch, $repo);
my $last_run_id = 0;
for (@$runs) {
    say print_run($_);
    if ($_->{status} eq 'completed') {
        $last_run_id = $_->{databaseId};
    }
}

while (1) {
    sleep $poll_interval;
    if (!$opt->{git_branch}) {
        if ($branch ne current_git_branch()) {
            say STDERR "Switched to branch " . current_git_branch();
            $branch = current_git_branch();
        }
    }
    try {
        my $run = get_runs(1, $branch, $repo)->[0];
        if (defined $run && $run->{status} eq 'completed') {
            if ($run->{databaseId} != $last_run_id) {
                $last_run_id = $run->{databaseId};
                say print_run($run);
            }
        }
    };
}

sub current_git_branch {
    my $gb ||= `git -C $secure branch --show-current`;
    $gb =~ s/\n//;
    return $gb;
}

sub print_run {
    my $run = shift;

    my $output = "";

    my $title = $run->{displayTitle};

    my $pretty_date = _pretty_date($run->{createdAt});
    $output .= colored ['bold black on_yellow'], " $pretty_date ";
    $run->{short_hash} = substr $run->{headSha}, 0, 7; # short version of git hash is 7 chars
    $output .= colored ['bold black on_cyan'], " <$run->{short_hash}> ";
    $output .= colored ['bold black on_blue'], " $run->{author} ";

    if ($run->{status} ne 'completed') {
        $output .= colored ['bold black on_yellow'], " … $title ";
    }
    elsif ($run->{conclusion} ne 'success') {
        $output .= colored ['bold black on_red'], " ✗ $title ";
        my $agg_file = aggregate_file_to_create($run);

        if (!$agg_file->exists) {
            my $failed = `gh run view -R $repo $run->{databaseId} --log-failed`;
            if ($? >> 8) {
                print $failed;
                die "Failed to get failed tests for run $run->{databaseId}";
            }
            write_aggregate($agg_file, $run, $failed);
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

    my ($number_of_runs, $git_branch, $gh_repo) = @_;

    my @runs = @{decode_json($UTF8->encode(`gh run list -R $gh_repo -L $number_of_runs -b $git_branch -w "Perl Test Suite (GCP)" --json $json_fields`))};
    for (@runs) {
        $_->{author} = `git --git-dir=$secure/.git log -n 1 --pretty=format:"%an" $_->{headSha}`;
    }
    return [reverse @runs];
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
    my ($agg_file, $run, $failed) = @_;

    my @lines;
    my %failed_tests;
    for my $line (split /\n/, $failed) {
        # The line starts with a bunch of crap so lets get rid of it:
        $line =~ /\d{2}:\d{2}:\d{2}.\d+. (.*)/;
        next unless defined $1;
        push @lines, $1;

        # Find any tests mentioned in the line and add them to the list of failed tests:
        for ($line =~ /\/secure\/(.*\.t\b)/g) {
            my $test = $1;
            $failed_tests{$test} = 1 if (
                $test !~ qr#/aggregate/#
                && $secure->child($test)->exists
            );
        }
    }
    my $output = join "\n", @lines;

    my $ft_string = join "\n", sort keys %failed_tests;

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

=head1 Output

$output

PERL5
    );
    return $agg_file;
}