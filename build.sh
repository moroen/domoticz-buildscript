#!/bin/bash

cwd=$(pwd)

sudo apt-get update -y
sudo apt-get upgrade -y

sudo apt-get install -y cmake git python3-dev python3-pip libboost-dev libboost-thread-dev libssl-dev curl libcurl4-openssl-dev autoconf automake libtool zlib1g-dev

git clone https://github.com/domoticz/domoticz.git
cd ${cwd}/domoticz
#git checkout development

for arg in "$@"
do
	case "${arg}"
	in
		tradfri)
			echo "Installing tradfri"
			cd ${cwd}/domoticz/plugins
			git clone -b development https://github.com/moroen/IKEA-Tradfri-plugin.git IKEA-Tradfri
			sudo pip3 install twisted 
			cd ${cwd}/domoticz/plugins/IKEA-Tradfri
			git clone https://github.com/ggravlingen/pytradfri.git
			cd ${cwd}/domoticz/plugins/IKEA-Tradfri/pytradfri/script
			sudo ./install-coap-client.sh
			cd ${cwd}/domoticz/plugins/IKEA-Tradfri/pytradfri
			sudo python3 setup.py install
			;;
		zwave)
			echo "Adding support for zwave"
			sudo apt-get install -y libudev-dev
			cd ${cwd}/domoticz
			git clone https://github.com/moroen/open-zwave.git
			cd open-zwave
			make
			cd ${cwd}
			ln -s domoticz/open-zwave open-zwave-read-only
			;;
		
	esac
done

cd ${cwd}/domoticz
cmake .
make 

for arg in "$@"
do
	case "${arg}"
	in
		service)
			cd ${cwd}/domoticz/plugins/IKEA-Tradfri
			sudo cp ikea-tradfri.service-pi /lib/systemd/system/ikea-tradfri.service
			sudo cp domoticz.service-pi /lib/systemd/system/domoticz.service
			sudo systemctl daemon-reload
			sudo systemctl start ikea-tradfri
			sudo systemctl enable ikea-tradfri

			sudo systemctl start domoticz
			sudo systemctl enable domoticz
		;;
	esac
done
