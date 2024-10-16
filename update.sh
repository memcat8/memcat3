echo "Disabling updates"
echo "make sure you are running as root"

stop update-engine
rm -rf /usr/bin/update_engine_client
rm -rf /usr/sbin/update_engine
rm -rf /usr/sbin/chromeos-firmwareudpate
rm -rf /opt/google/cr50/firmware/*
sudo sed -i "/etc/lsb-release" -e "s/google.com/gooole.com/g"
