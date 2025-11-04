#!/bin/bash

# Function for green text output
green() {
    printf "\033[32m%s\033[0m\n" "$1"
}
# Function for red text output
red() {
    printf "\033[31m%s\033[0m\n" "$1"
}

if [ -e /boot/firmware/config.txt ] ; then
  FIRMWARE=/firmware
else
  FIRMWARE=
fi
CONFIG=/boot${FIRMWARE}/config.txt

if [ -e /boot/firmware/cmdline.txt ] ; then
  FIRMWARE=/firmware
else
  FIRMWARE=
fi
CMDLINE=/boot${FIRMWARE}/cmdline.txt

rpi_conf() {
	if ! [ -e $CONFIG.backup ] ; then
		cp $CONFIG $CONFIG.backup
	fi
	if ! [ -e $CMDLINE.backup ] ; then
		cp $CMDLINE $CMDLINE.backup
	fi
}

config_tv() {
	if ! [ -e $CMDLINE.rns ]; then
			cp $CMDLINE $CMDLINE.rns
			cp $CMDLINE.backup $CMDLINE
			green "Use HDMI Video Output TV"
			red "The system will reboot now"
			reboot
	else
			green "NOW use HDMI Video Output TV"
	fi
}

config_rns() {
	if [ -e $CMDLINE.rns ]; then
			mv $CMDLINE.rns $CMDLINE
			green "Use HDMI Video Output RNS"
			red "The system will reboot now"
			reboot
	else
			green "Use HDMI Video Output RNS"
	fi
}

if (whiptail --title "Select video output source" --yes-button " TV " --no-button " RNS " --yesno "en:Select <TV> for your TV or PC monitor.\nSelect <RNS> to restore for RNS settings.\n\nru:Выбрать <TV> для телевизора или монитора ПК.\nВыбрать <RNS>, чтобы восстановить настройки для RNS." 11 60); then
		config_tv
else
		config_rns
fi
