#!/usr/bin/perl
use Config;
use Path::Tiny 'path';
use Capture::Tiny::Extended 'capture';
use IPC::Open2;
use 5.20.0;

my $args_as_string = join(' ', @ARGV);

my @perl_exec = (
    qw{/usr/local/bin/docker exec},
    # '-e', 'PERL5_DEBUG_HOST=172.16.25.8',
    # '-e', 'PERL5_DEBUG_PORT=12345',
    # '-e', 'PERL5_DEBUG_ROLE=server',
    'dev-box',
    '/usr/bin/perl',
    # '-d:Camelcadedb'
);

if ($args_as_string =~ /-le print for \@INC/) {
    @perl_exec = qw(perl);
}

my @args = map {
    s+^/.*/secure/+/secure/+r;
} (@perl_exec, @ARGV);

my $command = join ' ', @args;

path("~/.docker_perl_history")->append($command . "\n");

my $pid = open2('>&STDOUT', undef, @args);
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
