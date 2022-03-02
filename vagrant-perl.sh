#!/bin/zsh

echo "$*" >> ~/.vagrant_perl_history

# Camelcade is doing a version check - trick it into thinking it's my local perl.
if [[ $* == "-MConfig -e print q{perl}.chr(10);do {print;print chr(10)} for @Config{qw/version archname/}" ]]
then
  perl -MConfig -e "print q{perl}.chr(10);do {print;print chr(10)} for @Config{qw/version archname/}"
  exit 0
fi

# Camelcade wants to know that I have all the correct packages installed, so we need to trick it again.
if [[ $* == '-le print for @INC' ]]
then
  perl -le "print for @INC"
  exit 0
fi

vagrant_dir=~/Code/vagrant-devapp/devapp/

# Get local IP address, for remote debugging
my_ip=$(ifconfig en0 inet | grep inet | awk '{print $2}')

# PROVE_PASS_PERL5OPT are arguments that Camelcade passes to prove using -PPassEnv.
# Some parts of it need to be changed so that perl on vagrant accesses the correct files
PROVE_PASS_PERL5OPT=$(echo $PROVE_PASS_PERL5OPT | sed 's+/Users/bobbymccann/Code/secure+/secure+g')
PROVE_PASS_PERL5OPT=$(echo $PROVE_PASS_PERL5OPT | sed 's+/Users/bobbymccann/Library/Caches/JetBrains/IntelliJIdea2021.2+/secure+g')
#echo $PROVE_PASS_PERL5OPT

# Environment variables aren't passed to vagrant, so I need to do it myself.
perl_command="PROVE_PASS_PERL5OPT=\"$PROVE_PASS_PERL5OPT\" PERL5_DEBUG_HOST=$my_ip PERL5_DEBUG_PORT=3982 PERL5_DEBUG_ROLE=client perl"

# Perl on vagrant can't access my computer, so we need to find and replace the paths, so it uses the correct locations for things.
for arg in "$@"
do
  arg=$(echo "$arg" | sed 's+/Users/bobbymccann/perl5/perlbrew/perls/perl-5.34.0/bin+/usr/local/perl-5.24.0/bin+g')
  arg=$(echo "$arg" | sed 's+/Users/bobbymccann/Code/secure+/secure+g')

  # These ones are for coverage, which I haven't finished implementing yet.
  arg=$(echo "$arg" | sed 's+-I/Users/bobbymccann/Library/Application Support/JetBrains/Toolbox/apps/IDEA-U/ch-0/212.5080.55/IntelliJ IDEA.app.plugins/plugin/perl/lib++g')
  arg=$(echo "$arg" | sed 's+/Users/bobbymccann/Library/Caches/JetBrains/IntelliJIdea2021.2+/secure+g')
  perl_command="${perl_command} \"$arg\""
done

#echo $perl_command

cd $vagrant_dir
vagrant ssh --command="sudo su -l --command='$perl_command'" | sed 's+/secure+/Users/bobbymccann/Code/secure+g'

# TODO: use sed to change all coverage files and replace /secure with local path
cp -R ~/Code/secure/coverage/ /Users/bobbymccann/Library/Caches/JetBrains/IntelliJIdea2021.2/coverage