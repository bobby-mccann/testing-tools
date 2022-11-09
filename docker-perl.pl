#!/usr/bin/perl
use Config;
use Path::Tiny 'path';
use Capture::Tiny::Extended 'capture';
use IPC::Open3;
use 5.20.0;

# $ENV{SR_ROOT} = $ENV{GIT_REPOS} = "/home/bobby/Work";
# my $srd = open3(undef, undef, undef, qw(perl /home/bobby/Work/docker-development-environment/sr-docker.pl up));
# waitpid($srd, 0);

my $args_as_string = join(' ', @ARGV);

my $ip = (split /\n/, `ifconfig | grep inet | awk '{print \$2}'`)[0];

my @perl_exec = (
    '/usr/bin/docker', 'exec',
    '-e', "PROVE_PASS_PERL5OPT=$ENV{PROVE_PASS_PERL5OPT}",
    '-e', "PERL5_DEBUG_HOST=$ip",
    '-e', 'PERL5_DEBUG_PORT=12345',
    '-e', 'PERL5_DEBUG_ROLE=client',
    'dev-box',
    # '/usr/bin/perl',
    # '-d:Camelcadedb'
);

if ($args_as_string =~ /-le print for \@INC/) {
    @perl_exec = qw(perl);
}

my @args = map {
    s+^/.*/secure/+/secure/+r;
} (@perl_exec, @ARGV);
# say join ' ', @args;

my $command = join ' ', @args;

path("~/.docker_perl_history")->append($command . "\n");

my $pid = open3(undef, '>&STDOUT', '>&STDOUT', @args);
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
