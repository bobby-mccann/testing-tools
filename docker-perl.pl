#!/usr/bin/perl
use Config;
use Path::Tiny 'path';
use Capture::Tiny::Extended 'capture';
use IPC::Open3;
use 5.20.0;

$ENV{SR_ROOT} = $ENV{GIT_REPOS} = "/home/bobby/Work";

`perl /home/bobby/Work/docker-development-environment/sr-docker.pl up`
    unless `docker ps` =~ /dev-box/;

my $args_as_string = join(' ', @ARGV);

my $ip = (split /\n/, `ifconfig | grep inet | awk '{print \$2}'`)[0];

my @envs;
# for (keys %ENV) {
#     push @envs, "-e $_=$ENV{$_}";
# }

my @perl_exec = (
    '/usr/bin/docker', 'exec', '-i',
    @envs,
    '-e', "PROVE_PASS_PERL5OPT=$ENV{PROVE_PASS_PERL5OPT}",
    '-e', "PERL5_DEBUG_HOST=$ip",
    '-e', 'PERL5_DEBUG_PORT=12345',
    '-e', 'PERL5_DEBUG_ROLE=client',
    'dev-box',
);

@perl_exec = qw(/usr/bin/perl) if ($args_as_string =~ /-le print for \@INC/) ||
    $args_as_string =~ qr#/usr/local/bin/perlcritic#;

my @args = map {
    s+^/.*/secure/+/secure/+r;
} (@perl_exec, @ARGV);
# say join ' ', @args;

my $command = join ' ', @args;
# say $command;

path("~/.docker_perl_history")->append($command . "\n");

my $pid = open3('<&STDIN', '>&STDOUT', '>&STDOUT', @args);
waitpid($pid, 0);

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
