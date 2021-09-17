IP=$(~/Code/testing-tools/get_my_ip.sh)
FILE=$(cat ~/Code/testing-tools/.test)
vagrant ssh --command="sudo su -l --command='PERL5_DEBUG_HOST=$IP PERL5_DEBUG_PORT=3982 PERL5_DEBUG_ROLE=client PERL5OPT=-d:Camelcadedb perl $FILE'"