echo "Disabling updates"
echo "Make sure you are running as root and have rootfs protection off"

stop update-engine
rm -rf /usr/bin/update_engine_client
echo "rm -rf /usr/bin/update_engine_client"
rm -rf /usr/sbin/update_engine
echo "rm -rf /usr/sbin/update_engine"
rm -rf /usr/sbin/chromeos-firmwareudpate
echo "rm -rf /usr/sbin/chromeos-firmwareudpate"
rm -rf /opt/google/cr50/firmware/*
echo "rm -rf /opt/google/cr50/firmware/* this doesn't delete your firmware just cached firmware updates"
sed -i "/etc/lsb-release" -e "s/google.com/gooole.com/g"
echo "Done! Updates should be blocked. Make sure you set up an account and get to the desktop before you reboot or else you will have to powerwash"
