#!/usr/bin/perl
use Config;
use Path::Tiny 'path';
use Capture::Tiny::Extended 'capture';
use IPC::Open3;
use 5.20.0;

my $git_repos = path($0)->parent(2)->realpath;
$ENV{SR_ROOT} = $ENV{GIT_REPOS} = $git_repos;

`perl $ENV{GIT_REPOS}/docker-development-environment/sr-docker.pl up`
    unless `docker ps` =~ /dev-box/;

my $args_as_string = join(' ', @ARGV);

my @envs;
# for (keys %ENV) {
#     push @envs, "-e $_=$ENV{$_}";
# }

my @perl_exec = (
    '/usr/bin/docker', 'exec', '-i',
    @envs,
    '-e', "PROVE_PASS_PERL5OPT=$ENV{PROVE_PASS_PERL5OPT}",
    '-e', "PERL5_DEBUG_HOST=host.docker.internal",
    '-e', 'PERL5_DEBUG_PORT=12345',
    '-e', 'PERL5_DEBUG_ROLE=client',
    'dev-box',
);

# Use system perl for some things:
@perl_exec = qw(perl) if ($args_as_string =~ /-le print for \@INC/) ||
    $args_as_string =~ qr#/usr/local/bin/perlcritic# ||
    $args_as_string =~ /-MConfig/;

# Map secure directory to /secure:
my @args = map {
    s+^/.*/secure/+/secure/+r;
} (@perl_exec, @ARGV);
say join ' ', @args;

my $command = join ' ', @args;
# say $command;

path("~/.docker_perl_history")->append($command . "\n");

my $pid = open3('<&STDIN', '>&STDOUT', '>&STDERR', @args);
waitpid($pid, 0);

# TODO: Replace /secure in output with local secure path - below works but doesn't stream
# my ($stdout, $stderr) = capture sub {
#     system($command);
# }, {
#     stdout => <STDOUT>,
# };

# my $secure = path($ENV{SR_ROOT})->child('secure')->stringify;

# $stdout =~ s+/secure+$secure+g;
#
# print STDOUT $stdout;
# print STDERR $stderr;
