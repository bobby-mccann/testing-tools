IP=$(ifconfig en0 inet | grep inet | awk '{print $2}')
echo "$IP" > ~/Code/secure/bin/dev/testing-tools/.ip
echo "$IP"