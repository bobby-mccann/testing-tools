#!/usr/bin/perl
use strict;
use warnings;
use Config;
use IPC::Open3;
use Path::Tiny 'path';
use 5.20.0;

my $script_path = $0;
$script_path =~ qr#^(.+)/testing-tools#;
$ENV{SR_ROOT} = $ENV{GIT_REPOS} ||= $1;

`perl $ENV{GIT_REPOS}/docker-development-environment/sr-docker.pl up`
    unless `docker ps` =~ /dev-box/;

my $args_as_string = join(' ', map { "\"$_\"" } @ARGV);
path("~/.docker_perl_history")->append($args_as_string . "\n");

my $local_docker_path = `which docker`;
chomp $local_docker_path;

my @envs;

# This variable is set by the IntelliJ plugin to pass perl options to the prove command.
# If it's not set, we fill it with an empty string so as not to throw an error.
$ENV{PROVE_PASS_PERL5OPT} ||= '';
my @perl_exec = (
    $local_docker_path, 'exec', '-i',
    @envs,
    # '-e', "PROVE_PASS_PERL5OPT='$ENV{PROVE_PASS_PERL5OPT}'",
    '-e', "PERL5_DEBUG_HOST=172.16.25.1",
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

# Replace local prove with /usr/bin/prove
@args = map {
    s+^/.*/prove+/usr/bin/prove+r;
} @args;

my $command = join ' ', @args;
path("~/.docker_perl_history")->append($command . "\n");

my $pid = open3('<&STDIN', '>&STDOUT', '>&STDERR', @args);
waitpid($pid, 0);