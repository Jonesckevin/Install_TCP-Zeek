#!/bin/bash
echo '#####################################################################################################################'
echo '##################################~~~~~~Some Snort And Zeek Scripts ~~~~~############################################'
echo '#####################################################################################################################'

#Gets the network adapter for the inputs
ETHADAP=$(ip -br l | awk '$1 !~ "lo|vir|wl|doc" { print $1}')
#Variables for Folders
PFRING=/opt/PF_RING

sudo apt install snort -y
sudo mv /etc/apt/sources.list /etc/apt/sources.list.bak
sudo find /var/lib/apt/lists -type f -exec rm {} \;
sudo wget https://gist.githubusercontent.com/ishad0w/788555191c7037e249a439542c53e170/raw/3822ba49241e6fd851ca1c1cbcc4d7e87382f484/sources.list -O /etc/apt/sources.list
sudo apt update
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3B4FE6ACC0B21F32
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 871920D1991BC93C
sudo apt update
sudo apt install snort
sudo find /var/lib/apt/lists -type f -exec rm {} \;
sudo mv /etc/apt/sources.list /etc/apt/ubuntu_sources.list
sudo mv /etc/apt/sources.list.bak /etc/apt/sources.list
snort --version

sudo apt-get install tcpdump
echo "Install check"
tcpdump --version

echo '########################################################################################################################'
echo '##################################~~~~~~INSTALL PF-RING FOR ZEEK~~~~~~~~################################################'
echo 'https://holdmybeersecurity.com/2019/04/03/part-1-install-setup-zeek-pf_ring-on-ubuntu-18-04-on-proxmox-5-3-openvswitch/'

sudo apt  update -y
sudo apt upgrade -y
sudo apt-mark hold linux-image-generic linux-headers-generic
sudo apt install cmake make gcc g++ flex bison libpcap-dev libssl-dev python-dev swig zlib1g-dev libgeoip-dev build-essential libelf-dev -y && cd /opt || exit
sudo git clone https://github.com/ntop/PF_RING.git
cd $PFRING || exit && sudo make
cd $PFRING/kernel || exit && sudo make install
cd $PFRING/userland/lib || exit && sudo make install
cd $PFRING/kernel || exit && insmod $PFRING/kernel/pf_ring.ko && lsmod | grep pf_ring
test && cd $PFRING/userland || exit
 
sudo timeout 10s tcpdump -ni $ETHADAP

#Command below will confirm up and running
insmod $PFRING/kernel/pf_ring.ko
lsmod | grep pf_ring

echo '#####################################################################################################################'
echo '#########################################~~~~~~INSTALL ZEEK~~~~~~~~##################################################'
echo '#####################################################################################################################'

cd /tmp || exit
sudo git clone --recursive https://github.com/zeek/zeek
cd zeek || exit
sudo ./configure --with-pcap=$PFRING --prefix=/opt/bro 

#(Be Aware this part takes a while, even with more ram)
sudo make
sudo make install
#This Adds Zeek bin to the default PATH
export PATH=$PATH:/opt/bro/bin >> ~/.bashrc
export PATH="$PATH:/opt/bro/bin"
export PATH="$PATH:/opt/bro/bin" >> ~/.bashrc

echo 'DO THIS'
echo 'DO THIS'
echo 'DO THIS'
echo 'DO THIS'
echo '			sudo nano "$PREFIX"/etc/node.cfg'
echo 'DO THIS'
echo 'DO THIS'
echo 'DO THIS'
echo 'DO THIS'
sudo cat <<EOF >> "$PREFIX"/etc/node.cfg
[zeek]
type=standalone
host=localhost
interface=$ETHADAP
[manager]
type=manager
host=localhost
#
[proxy-1]
type=proxy
host=localhost
#
[worker-1]
type=worker
host=localhost
interface=$ETHADAP
lb_method=pf_ring
lb_procs=5
EOF

echo 'DO THIS'
echo "			sudo nano "$PREFIX"/etc/network.cfg"
echo 'DO THIS'
# List of local networks in CIDR notation.
sudo cat <<EOF >> "$PREFIX"/etc/network.cfg
127.0.0.1/8
10.10.10.0/16
192.168.0.0/16
192.168.1.0/24
192.168.0.0/24
172.31.0.0/16
10.0.0.0/8
EOF
echo ''
echo ''
echo '/opt/bro/bin/zeekctl #This should work once you do the Export Path part.'
echo 'install 		"#installs workers" '
echo 'deploy 		"#Deploys Workers"'
echo 'status		"#confirms workers are working"'
echo 'stop 		"#stops workers"'

#Zeek Geo IP
	sudo apt-get install libmaxminddb-dev
		#https://www.maxmind.com/en/accounts/current/geoip/downloads
		#Apparently need a DB of locations: mv <extracted subdir>/GeoLite2-City.mmdb <path_to_database_dir>/GeoLite2-City.mmdb

echo '############################################'
echo '########### EAT-THAT-BREAD #################'
echo '############################################'
