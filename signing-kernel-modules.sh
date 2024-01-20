#!/bin/bash

##########################################################################
#                                                                        #
#                 Sign Kernel modules for SecureBoot                     #
#                                                                        #
#    A fully automated script for Fedora/Centos/Rocky/Red-Hat            #
#                                                                        #
#    Author: Carles Loriente                                             #
#    License: MIT                                                        #
#                                                                        #
#    https://github.com/carlesloriente/sign-kernel-modules-secureboot    #
#                                                                        #
##########################################################################

## Enable extended globbing for the +(...) pattern
shopt -s extglob
clear

SCRIPT_VER="v0.1"
MOKUTIL="/usr/bin/mokutil"
MODPROBE="/sbin/modprobe"
MODINFO="/sbin/modinfo"
SIGN_DIR="/root/sign-kernel-modules"
SIGN_DIR_KEY="/var/lib/shim-signed/mok"
PUB_KEY="${SIGN_DIR_KEY}/MOK.der"
PRIV_KEY="${SIGN_DIR_KEY}/MOK.priv"

show_msg() {

    echo "######################################################################";
    echo "######################################################################";
    echo " ____  _             _               _  __                    _       ";
    echo "/ ___|(_) __ _ _ __ (_)_ __   __ _  | |/ /___ _ __ _ __   ___| |      ";
    echo "\___ \| |/ _  |  _ \| |  _ \ / _  | | ' // _ \ '__| '_ \ / _ \ |      ";
    echo " ___) | | (_| | | | | | | | | (_| | | . \  __/ |  | | | |  __/ |      ";
    echo "|____/|_|\__, |_| |_|_|_| |_|\__, | |_|\_\___|_|  |_| |_|\___|_|      ";
    echo "         |___/               |___/                                    ";
    echo "                     _       _                                        ";
    echo " _ __ ___   ___   __| |_   _| | ___  ___                              ";
    echo "| '_   _ \ / _ \ / _  | | | | |/ _ \/ __|                             ";
    echo "| | | | | | (_) | (_| | |_| | |  __/\__ \                             ";
    echo "|_| |_| |_|\___/ \__,_|\__,_|_|\___||___/                             ";
    echo "                                                                      ";
    echo "######################################################################";
    echo "#            Signing kernel modules for SecureBoot                   #";
    echo "#            version $SCRIPT_VER                                     #";
    echo "#            @godarthvader   (twitter)                               #";
    echo "#            @carlesloriente (github)                                #";
    echo "######################################################################";
    echo "#            Execute the script with sudo                            #";
    echo "";

}


test_pass() {

    printf "[\e[1m\033[32mPASS\033[0m]\n";

}


test_fail() {

    printf "[\e[1m\033[31mFAIL\033[0m]\n";
    echo "$errmsg";
    exit 1;

}


start_env() {

    echo "Checking permissions";
    if [ "$EUID" -ne 0 ]
    then
        echo "Please run the script with sudo"
        exit 2
    fi

    echo "Checking environment";
    if [ ! -d "${SIGN_DIR}" ] || [ ! -d "${SIGN_DIR_KEY}" ] ;then
        mkdir -p $SIGN_DIR $SIGN_DIR_KEY
    fi

    if ! "${MOKUTIL}" --sb-state | grep -qi '[[:space:]]enabled$' ; then
        echo "WARNING: Secure Boot is not enabled, signing is not necessary"
        exit 2
    fi

    read -p "Press any key to continue..."

}


test_bin() {

    echo "Checking VirtualBox installation: "
    ga_return=$( which virtualbox > /dev/null 2>&1 ; echo $? )
    if [ "$ga_return" = "0" ] ;then
        test_pass
    else
        echo -n "This script requires virtualbox to be installed. "
        install_vbox
    fi

}


test_sign_script() {

    if [ ! -f "${SIGN_DIR}/virtual-box" ] ;then
dd of=${SIGN_DIR}/virtual-box<< EOF
#!/bin/bash

for modfile in \$(dirname \$(modinfo -n vboxdrv))/*.ko; do
    /usr/src/kernels/\$(uname -r)/scripts/sign-file sha256 ${PRIV_KEY} ${PUB_KEY} "\$modfile"
done
EOF
    fi
    chmod 700 ${SIGN_DIR}/virtual-box

}


test_systemd_script() {

    if [ ! -f "/usr/bin/autosign-vbox-kmods" ] ;then
dd of=/usr/bin/autosign-vbox-kmods<< EOF
[Unit]
SourcePath=/usr/bin/autosign-vbox-kmods
Description=Ensure the VirtualBox Linux kernel modules are signed
Before=vboxdrv.service
After=


[Service]
Type=oneshot
Restart=no
TimeoutSec=30
IgnoreSIGPIPE=no
KillMode=process
GuessMainPID=no
RemainAfterExit=yes
ExecStart=/usr/bin/autosign-vbox-kmods


[Install]
RequiredBy=vboxdrv.service
WantedBy=multi-user.target
EOF
    fi
    systemctl reload-daemon
    systemctl start autosign-vbox-kmods.service

}


install_vbox() {

    echo "Installing virtualbox"
    dnf install -y kernel-devel kernel-headers dkms qt5-qtx11extras elfutils-libelf-devel zlib-devel mokutil openssl kernel-devel-$(uname -r)
    wget http://download.virtualbox.org/virtualbox/rpm/fedora/virtualbox.repo -P /etc/yum.repos.d/
    dnf install -y VirtualBox-7.0
    systemctl enable vboxdrv --now
    wget https://download.virtualbox.org/virtualbox/7.0.12/Oracle_VM_VirtualBox_Extension_Pack-7.0.12.vbox-extpack -P $HOME/Downloads
    VBoxManage extpack install --replace $HOME/Downloads/Oracle_VM_VirtualBox_Extension_Pack-7.0.12.vbox-extpack --accept-license=33d7284dc4a0ece381196fda3cfe2ed0e1e8e7ed7f27b9a9ebc4ee22e24bd23c

    INFO="$("${MODINFO}" -n vboxdrv)"
    if [ -z "${INFO}" ] ; then
        # If there's no such module, compile it
        /usr/lib/virtualbox/vboxdrv.sh setup
        INFO="$("${MODINFO}" -n vboxdrv)"
        if [ -z "${INFO}" ] ; then
            echo "ERROR: Module compilation failed (${MODPROBE} couldn't find it after vboxdrv.sh was called)"
            exit 1
        fi
    fi
}


signing_modules() {

    openssl req -nodes -new -x509 -newkey rsa:2048 -outform DER -addext "extendedKeyUsage=codeSigning" -keyout $PRIV_KEY -out $PUB_KEY
    mokutil --import $PUB_KEY
    cd $SIGN_DIR
    ./virtual-box
    read -p "Press any key to reboot..."
    reboot

}


show_msg;
start_env;
test_bin;
test_sign_script;
test_systemd_script;
signing_modules;