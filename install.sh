#!/bin/bash

# wget -P /tmp https://raw.githubusercontent.com/maltsevvv/repository/master/install.sh
# sudo bash /tmp/install.sh

user="$SUDO_USER"

skin_kodi20=20.1.2
skin_kodi21=21.1.2

# Function for green text output
green() {
    printf "\033[32m%s\033[0m\n" "$1"
}
# Function for red text output
red() {
    printf "\033[31m%s\033[0m\n" "$1"
}

# Function to check internet connection
check_internet() {
    echo
    echo "Checking internet connection..."
    if ping -c 1 google.com &> /dev/null; then
        green "Internet connection is available. ✅"
    else
        echo "No internet connection. Please check your network. ❌"
        exit 1
    fi
}
# Function to check OS Version
check_os_version() {
    echo
    echo "Checking OS version..."
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        green "OS: $PRETTY_NAME"
        #if [ "$PRETTY_NAME" == "GNU/Linux 12 (bookworm)" ]; then
		if echo "$PRETTY_NAME" | grep -q "bookworm"; then
            echo
        #elif [ "$PRETTY_NAME" == "GNU/Linux 13 (trixie)" ]; then
		elif echo "$PRETTY_NAME" | grep -q "trixie"; then
            echo
        else
            red "OS: $PRETTY_NAME is not Linux 13 (trixie) or Linux 12 (bookworm) ❌"
            exit 1
        fi
    else
        red "Unable to determine OS version. Exiting. ❌"
        exit 1
    fi
}
# Function to check PI Version
check_pi_model() {
    echo "Checking Raspberry Pi model..."
    if [ -f /proc/cpuinfo ]; then
        MODEL=$(grep -oP 'Model\s*:\s*\K.*' /proc/cpuinfo)
        green "$MODEL"
    else
        red "Unable to determine Pi model. Exiting. ❌"
        exit 1
    fi
}
# Function Installation Packages
install_package() {
    echo
    echo "Installing Packages"
    local PACKAGE="$1"
    local TYPE="${2:-apt}"  # По умолчанию apt
    if [ -z "$PACKAGE" ]; then
        red "     Error: No Package specified for installation."
        return 1
    fi
    MAX_ATTEMPTS=5
    for i in $(seq 1 $MAX_ATTEMPTS); do
        echo "     Attempting to install package '$PACKAGE' ($i/$MAX_ATTEMPTS) via $TYPE..."
        if [ "$TYPE" = "apt" ]; then
            if apt-get install -y "$PACKAGE" &> /dev/null; then
                green "     Package '$PACKAGE' was successfully installed via apt."
                return 0
            fi
        elif [ "$TYPE" = "pip" ]; then
            if pip3 install "$PACKAGE" --break-system-packages &> /dev/null; then
                green "     Package '$PACKAGE' was successfully installed via pip."
                return 0
            fi
        else
            red "     Error: Unknown installation type '$TYPE'.."
            return 1
        fi
        red "     Error installing '$PACKAGE' via $TYPE. Trying again in 5 seconds..."
        sleep 5
    done
    red "     Failed to set '$PACKAGE' via $TYPE after $MAX_ATTEMPTS attempts."
    while true; do
        read -p "Close the installation script? (yes/no): " choice
        case $choice in
            [Yy]|[Yy][Ee][Ss]|[Дд][Aa]|[Дд]|[Да]|[да]|[Yes]|[yes]|[Y]|[y])
                green "     Skipping the package '$PACKAGE' and continuing?"
                return 0  # Продолжаем
                ;;
            [Nn]|[Nn][Oo]|[Нн][Ее][Тт]|[Нн]|[Нет]|[нет]|[No]|[no]|[N]|[n])
                red "     Closing the script."
                exit 1
                ;;
            *)
                red "     Incorrect input. Please enter 'yes' or 'no'."
                ;;
        esac
    done
}
# Function for Downloads Files
packet_download() {
    URL="$1"
    FILE_NAME=$(basename "$URL")  # Извлекаем имя файла из URL, например rpi480i.bin
    FILE_PATH="/tmp/$FILE_NAME"
    
    if [ -f "$FILE_PATH" ]; then
        green "     File $FILE_NAME already exists. Skipping download. ✅"
    else
        echo "     File $FILE_NAME not found. Attempting download with retries..."
        MAX_RETRIES=10
        RETRY_COUNT=0
        SUCCESS=false
        
        while [ $RETRY_COUNT -lt $MAX_RETRIES ] && [ "$SUCCESS" = false ]; do
            RETRY_COUNT=$((RETRY_COUNT + 1))
            echo "Download attempt $RETRY_COUNT of $MAX_RETRIES..."
            if wget -q -P /tmp "$URL"; then
                green "     Downloaded $FILE_NAME successfully on attempt $RETRY_COUNT. ✅"
                SUCCESS=true
            else
                red "     Attempt $RETRY_COUNT failed. Retrying in 5 seconds..."
                sleep 5
            fi
        done
        
        if [ "$SUCCESS" = false ]; then
            red "     Failed to download '$FILE_NAME' via wget after $MAX_RETRIES attempts."
            while true; do
                read -p "Skip this step and continue installation? (yes/no): " choice
                case $choice in
                    [Yy]|[Yy][Ee][Ss]|[Дд][Aa]|[Дд]|[Да]|[да]|[Yes]|[yes]|[Y]|[y])
                        green "     Skipping download of '$FILE_NAME' and continuing installation."
                        return 0  # Продолжаем
                        ;;
                    [Nn]|[Nn][Oo]|[Нн][Ее][Тт]|[Нн]|[Нет]|[нет]|[No]|[no]|[N]|[n])
                        red "     Closing the script."
                        exit 1
                        ;;
                    *)
                        red "     Incorrect input. Please enter 'yes' or 'no'."
                        ;;
                esac
            done
        fi
    fi
}

# Function to add Kodi service
kodi_service_add() {
    echo
    echo "     Adding Kodi service configuration..."
    local service_file="/etc/systemd/system/kodi.service"
    if [ ! -f "$service_file" ]; then
        cat > "$service_file" << EOF
[Unit]
Description=Kodi Media Center
[Service]
User=$user
Group=$user
Type=simple
ExecStart=/usr/bin/kodi-standalone
Restart=always
RestartSec=15
[Install]
WantedBy=multi-user.target
EOF
        green "     Kodi service added. ✅"
    else
        green "     Kodi service already exists. Skipping."
    fi
    # Post-Kodi installation steps
    echo
    echo "     Disabling Kodi version check..."
    sed -i '/service.xbmc.versioncheck/d' /usr/share/kodi/system/addon-manifest.xml
    green "     Kodi version check disabled. ✅"
}
# Function run Kodi service
kodi_service_run() {
    echo
    echo "     Enabling Kodi service..."
    systemctl enable kodi
    green "     Kodi service enabled. ✅"
    
    echo "     Starting Kodi service..."
    systemctl start kodi
    green "     Kodi service started. ✅"
	sleep 30
	
}
# Function to stop Kodi if running
kodi_stop_if_running() {
    echo "Checking Kodi status and addons directory..."
    if [ -d /home/$user/.kodi/addons/ ]; then
        green "Kodi is running and addons directory exists. Stopping Kodi service..."
		systemctl stop kodi
		sleep 30
        if systemctl is-active --quiet kodi; then
            red "Error: Failed to stop Kodi service." >&2
            return 1  # Возвращаем ошибку, чтобы скрипт мог обработать
        else
            green "Kodi service stopped successfully. ✅"
            sleep 20  # Ждём, чтобы сервисы полностью выгрузились (настройте, если нужно больше/меньше)
        fi
    else
        red "Kodi is not running or addons directory does not exist. Skipping stop."
		exit 1
		#kodi_service_run
    fi
}
# Function to add Samba share if not exists
samba_share_add() {
    echo
    echo "     Adding Samba share configuration..."
    local smb_conf="/etc/samba/smb.conf"
    if ! grep -q "\[rns\]" "$smb_conf"; then
        cat >> "$smb_conf" << EOF

[rns]
   path = /home/$user/
   create mask = 0775
   directory mask = 0775
   writeable = yes
   browseable = yes
   public = yes
   force user = $user
   guest ok = yes

[nobody]
   browseable = no
EOF
        green "     Samba share added. ✅"
    else
        green "     Samba share [rns] already exists. Skipping."
    fi
}

can0_100000() {
    echo
    echo "     Adding Can0 configuration for VAG"
	cat /dev/null > "/etc/systemd/network/80-can.network" # Clear File 
    local can0_conf="/etc/systemd/network/80-can.network"
    if ! grep -q "BitRate=100000" "$can0_conf"; then
        cat > "$can0_conf" << EOF

[Match]
Name=can0

[CAN]
BitRate=100000
EOF
        green "     CAN0 & Bitrate 100000 (100K) added. ✅"
    else
        green "     CAN0 & Bitrate 100000 (100K) already exists. Skipping."
    fi
}

can0_83333() {
    echo
    echo "     Adding Can0 configuration for Mercedes"
	cat /dev/null > "/etc/systemd/network/80-can.network" # Clear File 
    local can0_conf="/etc/systemd/network/80-can.network"
    if ! grep -q "BitRate=83333" "$can0_conf"; then
        cat > "$can0_conf" << EOF

[Match]
Name=can0

[CAN]
BitRate=83333
EOF
        green "     CAN0 & Bitrate 83333 (83.333K) added. ✅"
    else
        green "     CAN0 & Bitrate 83333 (83.333K) already exists. Skipping."
    fi
}

# Function run CAN0
can0_service_run() {
    echo "     Restart 80-can.network service..."
    systemctl restart systemd-networkd
    green "     80-can.network service restarted. ✅"

    echo "     Enabling 80-can.network service..."
    systemctl enable systemd-networkd
    green "     80-can.network service started. ✅"
}
# Function to setup Bluetooth Receiver
bluetooth_receiver() {
    echo
    echo "Installing Bluetooth Receiver..."
	hostnamectl set-hostname --pretty "rns"
	# Добавление нового пакета bluez-tools (с --no-install-recommends)
	echo "     Installing bluez-tools"
	apt install -y --no-install-recommends bluez-tools &> /dev/null
	# Добавление нового пакета bluez-alsa-utils
	echo "     Installing bluez-alsa-utils"
	apt install -y --no-install-recommends bluez-alsa-utils &> /dev/null


	# rfkill unblock all

	# Bluetooth settings
	local main_conf="/etc/bluetooth/main.conf"
	echo "     Adding class configuration..."
	#if ! grep -q "Class = 0x200414" "$main_conf"; then
	sed -i 's/^#\?Class = 0x000100/Class = 0x200414/' "$main_conf"
	sed -i 's/^#\?DiscoverableTimeout = 0/DiscoverableTimeout = 0/' "$main_conf"
	sed -i 's/^#\?AutoEnable=true/AutoEnable=true/' "$main_conf"
        sed -i 's/^#\?#FastConnectable = false/FastConnectable = true/' "$main_conf"
	green "     Bluetooth class configuration added. ✅"
	#else
	#	green "     Bluetooth class configuration added. Skipping."
	#fi

	# Bluetooth Agent
	local bt_agent="/etc/systemd/system/bt-agent@.service"
	echo "     Adding Bluetooth Agent service..."
	if ! grep -q "ExecStartPre=/bin/hciconfig %I sspmode 1" "$bt_agent"; then
		cat > "$bt_agent" << EOF

[Unit]
Description=Bluetooth Agent
Requires=bluetooth.service
After=bluetooth.service

[Service]
ExecStartPre=/usr/bin/bluetoothctl discoverable on
ExecStartPre=/bin/hciconfig %I piscan
ExecStartPre=/bin/hciconfig %I sspmode 1
ExecStart=/usr/bin/bt-agent --capability=NoInputNoOutput
RestartSec=5
Restart=always
KillSignal=SIGUSR1

[Install]
WantedBy=multi-user.target
EOF
		green "     Adding Bluetooth Agent service... ✅"
	else
		green "     Adding Bluetooth Agent service. Skipping."
	fi

	systemctl daemon-reload
	systemctl enable bt-agent@hci0.service

	# Bluetooth udev script
	echo "     Adding Bluetooth script..."
	local bt_udev="/usr/local/bin/bluetooth-udev"
	if ! grep -q "bluetoothctl discoverable off" "$bt_udev"; then
		cat > "$bt_udev" << EOF

#!/bin/bash
if [[ ! $NAME =~ ^\"([0-9A-F]{2}[:-]){5}([0-9A-F]{2})\"$ ]]; then exit 0; fi

action=$(expr "$ACTION" : "\([a-zA-Z]\+\).*")

if [ "$action" = "add" ]; then
bluetoothctl discoverable off
# disconnect wifi to prevent dropouts
#ifconfig wlan0 down &
fi

if [ "$action" = "remove" ]; then
# reenable wifi
#ifconfig wlan0 up &
bluetoothctl discoverable on
fi
EOF
		green "     Adding Bluetooth script... ✅"
	else
		green "     Adding Bluetooth script. Skipping."
	fi

	chmod 755 /usr/local/bin/bluetooth-udev

	echo "     Adding bluetooth-udev.rules..."
	local bt_udev_rules="/etc/udev/rules.d/99-bluetooth-udev.rules"
	if ! grep -q "/usr/local/bin/bluetooth-udev" "$bt_udev_rules"; then
		cat > "$bt_udev_rules" << EOF

SUBSYSTEM=="input", GROUP="input", MODE="0660"
KERNEL=="input[0-9]*", RUN+="/usr/local/bin/bluetooth-udev"
EOF
		green "     Adding bluetooth-udev.rules... ✅"
	else
		green "     Adding bluetooth-udev.rules. Skipping."
	fi

	# Create asound.conf if not exists
	echo "     Add asound.conf"
	local asound_conf="/etc/asound.conf"
	if [ ! -f "$asound_conf" ]; then
		cat >> "$asound_conf" << 'EOF'
defaults.ctl.card 0
defaults.ctl.card 0
EOF
		green "     Asound.conf created. ✅"
	else
		green "     Asound.conf already exists. Skipping."
	fi


}
# Function to install skin.rnspi and repository.rnspi
kodi_install_addons() {
    echo
    echo "Installing Kodi addons..."
    # unzip is installed
    install_package "unzip"
    
	# Stop KODI	
	kodi_stop_if_running
	if [ $? -eq 0 ]; then
		echo "Proceeding with addon installation..."
		# Здесь ваш код для копирования файлов в /home/pi/.kodi/addons/

		check_os_version

		# Download latest skin.rnspi from GitHub с повторными попытками
		#if [ "$PRETTY_NAME" == "Debian GNU/Linux 12 (bookworm)" ]; then
		if echo "$PRETTY_NAME" | grep -q "bookworm"; then
			packet_download "https://github.com/maltsevvv/repository/raw/master/kodi20/skin.rnspi/skin.rnspi-$skin_kodi20.zip"
		elif echo "$PRETTY_NAME" | grep -q "trixie"; then
			packet_download "https://github.com/maltsevvv/repository/raw/master/kodi21/skin.rnspi/skin.rnspi-$skin_kodi21.zip"
		fi

		packet_download "https://github.com/maltsevvv/repository/raw/master/repository.rnspi.zip"

		echo "     Checking for file /tmp/skin.rnspi.zip"
		if [ ! -f /tmp/skin.*.zip ]; then
			red "     File skin.rnspi.zip /tmp/skin.rnspi.zip not found. ❌"
			exit 1
		else
			if [ ! -d /home/$user/.kodi/addons/ ]; then
				red "     Directory /home/$user/.kodi/addons/ not found. ❌"
				exit 1
			else
				unzip -q /tmp/skin.rnspi*.zip -d /tmp
				green "     skin.rnspi unzipped. ✅"
				cp -r /tmp/skin.rnspi /home/$user/.kodi/addons/
				green "     skin.rnspi copied to /home/$user/.kodi/addons/. ✅"

				echo "     Installing repository.rnspi addon."
				unzip -q /tmp/repository.rnspi.zip -d /tmp
				green "     repository.rnspi unzipped. ✅"
				cp -r /tmp/repository.rnspi /home/$user/.kodi/addons/
				green "     repository.rnspi copied to /home/$user/.kodi/addons/. ✅"
			fi
		fi
	else
		echo "Failed to stop Kodi. Aborting installation."
		exit 1
	fi
}

# Function to configure Kodi base settings after stopping Kodi
kodi_configure() {
    echo
    echo "Configuring Kodi base settings..."
    kodi_stop_if_running

    # 1. Check and add skin.rnspi to addon-manifest.xml
    if ! grep -q 'skin.rnspi' /usr/share/kodi/system/addon-manifest.xml; then
        echo "     Adding skin.rnspi to addon-manifest.xml..."
        sed -i '$i\  <addon optional="true">skin.rnspi</addon>' /usr/share/kodi/system/addon-manifest.xml
        green "     skin.rnspi added to addon-manifest.xml. ✅"
    else
        green "     skin.rnspi already in addon-manifest.xml. Skipping."
    fi
    
    # 2. Check and add repository.rnspi to addon-manifest.xml
    if ! grep -q 'repository.rnspi' /usr/share/kodi/system/addon-manifest.xml; then
        echo "     Adding repository.rnspi to addon-manifest.xml..."
        sed -i '/<\/addons>/i \  <addon optional="true">repository.rnspi</addon>' /usr/share/kodi/system/addon-manifest.xml
        green "     repository.rnspi added to addon-manifest.xml. ✅"
    else
        green "     repository.rnspi already in addon-manifest.xml. Skipping."
    fi
    
    # 3. Enable skin.rnspi in guisettings.xml
    if ! grep -q 'skin.rnspi' /home/$user/.kodi/userdata/guisettings.xml; then
        echo "     Setting skin.rnspi in guisettings.xml..."
        sed -i 's/"lookandfeel.skin" default="true">skin.estuary/"lookandfeel.skin">skin.rnspi/' /home/$user/.kodi/userdata/guisettings.xml
        green "     Skin set to skin.rnspi in guisettings.xml. ✅"
    else
        green "     skin.rnspi already in guisettings.xml. Skipping."
    fi
    
    # 4. Set screensaver to none in guisettings.xml
    if grep -q 'screensaver.xbmc.builtin.dim' /home/$user/.kodi/userdata/guisettings.xml; then
        echo "     Setting screensaver to none in guisettings.xml..."
        sed -i 's/ default="true">screensaver.xbmc.builtin.dim/> /' /home/$user/.kodi/userdata/guisettings.xml
        green "     Screensaver set to none. ✅"
    else
        green "     Screensaver already disabled. Skipping."
    fi
    
    # 5. Set volume steps to 30 in guisettings.xml
    if ! grep -q 'volumeamplification>30.000000' /home/$user/.kodi/userdata/guisettings.xml; then
        echo "     Setting volume steps to 30db in guisettings.xml..."
        sed -i 's/volumeamplification>0.000000/volumeamplification>30.000000/' /home/$user/.kodi/userdata/guisettings.xml
        green "     Volume steps set to 30db. ✅"
    else
        green "     Volume amplification already setting +30db. Skipping."
    fi

    # 6. Enable web server in guisettings.xml
    if grep -q 'services.webserver' /home/$user/.kodi/userdata/guisettings.xml; then
        echo "     Enabling web server in guisettings.xml..."
        sed -i 's/id="services.webserver" default="true">false/id="services.webserver">true/' /home/$user/.kodi/userdata/guisettings.xml
        green "     Web server enabled. ✅"
    else
        red "     Web server setting not found. Skipping."
    fi

    # 7. Enable web server authentication in guisettings.xml
    if grep -q 'webserverauthentication" default="true' /home/$user/.kodi/userdata/guisettings.xml; then
        echo "     Enabling web server authentication in guisettings.xml..."
        sed -i 's/id="services.webserverauthentication" default="true">true/id="services.webserverauthentication">false/' /home/$user/.kodi/userdata/guisettings.xml
        green "     Web server authentication disabled. ✅"
    else
        green "     Web server authentication already disabled. Skipping."
    fi
    
    # 8. Replace sources.xml with custom media sources
    echo "     Replacing sources.xml with custom media sources..."
    cat > /home/$user/.kodi/userdata/sources.xml << EOF
<sources>
    <programs>
        <default pathversion="1"></default>
    </programs>
    <video>
        <default pathversion="1"></default>
        <source>
            <name>movies</name>
            <path pathversion="1">/home/$user/movies/</path>
            <allowsharing>true</allowsharing>
        </source>
        <source>
            <name>tvshows</name>
            <path pathversion="1">/home/$user/tvshows/</path>
            <allowsharing>true</allowsharing>
        </source>
        <source>
            <name>clips</name>
            <path pathversion="1">/home/$user/clips/</path>
            <allowsharing>true</allowsharing>
        </source>
        <source>
            <name>mults</name>
            <path pathversion="1">/home/$user/mults/</path>
            <allowsharing>true</allowsharing>
        </source>
    </video>
    <music>
        <default pathversion="1"></default>
        <source>
            <name>music</name>
            <path pathversion="1">/home/$user/music/</path>
            <allowsharing>true</allowsharing>
        </source>
    </music>
    <pictures>
        <default pathversion="1"></default>
    </pictures>
    <files>
        <default pathversion="1"></default>
        <source>
            <name>192.168.1.3</name>
            <path pathversion="1">smb://192.168.1.3/</path>
            <allowsharing>true</allowsharing>
        </source>
        <source>
            <name>pi</name>
            <path pathversion="1">/home/pi/</path>
            <allowsharing>true</allowsharing>
        </source>
    </files>
    <games>
        <default pathversion="1"></default>
    </games>
</sources>
EOF
    green "     sources.xml replaced with custom media sources. ✅"
    
    # 9. Create media directories under /home/pi/ and set permissions
    echo "     Creating media directories under /home/$user/..."
    mkdir -p /home/$user/movies
    mkdir -p /home/$user/tvshows
    mkdir -p /home/$user/clips
    mkdir -p /home/$user/music
    chmod -R 0777 /home/$user/movies /home/$user/tvshows /home/$user/clips /home/$user/music
    chown -R $user:$user /home/$user/
    green "     Media directories created and permissions set. ✅"
    
    green "     Kodi base configuration completed. ✅"
}

####################################################################

# Определение путей (как в вашем коде)
if [ -e /boot/firmware/config.txt ]; then
    FIRMWARE=/firmware
else
    FIRMWARE=
fi
CONFIG=/boot${FIRMWARE}/config.txt

if [ -e /boot/firmware/cmdline.txt ]; then
    FIRMWARE=/firmware
else
    FIRMWARE=
fi
CMDLINE=/boot${FIRMWARE}/cmdline.txt

# Create backup config.txt
rpi_backup() {
    echo
    echo "Create backup config.txt"
    if ! [ -e $CONFIG.backup ] ; then
        cp $CONFIG $CONFIG.backup
        green "     Create backup $CONFIG.backup successfully. ✅"
    else
        green "     $CONFIG.backup already exists Skipping."
    fi
    if ! [ -e $CMDLINE.backup ] ; then
        cp $CMDLINE $CMDLINE.backup
        green "     Create backup $CMDLINE.backup successfully. ✅"
    else
        green "     $CMDLINE.backup already exists Skipping."
    fi
}

rpi_ir() {
    echo
    green "Installed IR-Keytable"
    # Удаление lirc и связанной директории
    echo "Removing lirc package..."
    if apt purge -y lirc ; then
        green "     lirc package purged successfully. ✅"
    else
        red "     Warning: Failed to purge lirc (might not be installed). Continuing... ⚠️"
    fi
    if [ -d /etc/lirc ]; then
        sudo rm -r /etc/lirc &> /dev/null
        green "     /etc/lirc directory removed successfully. ✅"
    else
        green "     /etc/lirc directory does not exist. Skipping removal. ✅"
    fi

    # Установка ir-keytable
    install_package "ir-keytable"

    # Создание файла /etc/rc_keymaps/rc6_mce.toml
    echo "     Creating /etc/rc_keymaps/rc6_mce.toml..."
    local rc6_mce="/etc/rc_keymaps/rc6_mce.toml"
    if ! grep -q 'name = "jp3"' "$rc6_mce"; then
        cat > "$rc6_mce" << EOF

[[protocols]]
name = "jp3"
protocol = "nec"
[protocols.scancodes]
0x98 = "KEY_PLAYPAUSE"
0x89 = "KEY_ENTER"
0x8a = "KEY_BACK"
0x94 = "KEY_UP"
0x8e = "KEY_DOWN"
0x8d = "KEY_LEFT"
0x8c = "KEY_RIGHT"
0x92 = "KEY_STOP"
0x96 = "KEY_I"
0x97 = "KEY_C"
0x9b = "KEY_PREVIOUSSONG"
0x87 = "KEY_NEXTSONG"
EOF
        green "     /etc/rc_keymaps/rc6_mce.toml created successfully. ✅"
    else
        green "     /etc/rc_keymaps/rc6_mce.toml already exists. Skipping. ✅"
    fi

    echo "     Enabling gpio-ir,gpio_pin=17 TSOP $CONFIG"
    sed -i 's/^#\?dtoverlay=gpio-ir,gpio_pin=17/dtoverlay=gpio-ir,gpio_pin=17/' "$CONFIG"
    if ! grep -q '^dtoverlay=gpio-ir,gpio_pin=17$' "$CONFIG"; then
		echo " " >> "$CONFIG"
        echo 'dtoverlay=gpio-ir,gpio_pin=17' >> "$CONFIG"
    fi
    green "     Enablied gpio-ir,gpio_pin=17 TSOP $CONFIG"
}

rpi_add_can0(){
    echo "Added Interface Can0"
    # Вызов функции проверки модели
    check_pi_model

    # Добавить MCP2515-Can0 в зависимости от модели PI
    if ! grep -q "dtoverlay=mcp2515-can0" "$CONFIG"; then
        echo "# MCP2515-Can0 oscillator=8000000 or 16000000 and GPIO=25" >> "$CONFIG"
        echo "dtoverlay=mcp2515-can0,oscillator=8000000,interrupt=25" >> "$CONFIG"
		if echo "$MODEL" | grep -qE "(Raspberry Pi Zero 2 W|Raspberry Pi 2|Raspberry Pi 3)"; then
			echo "dtoverlay=spi-bcm2835" >> "$CONFIG"
		elif echo "$MODEL" | grep -qE "(Raspberry Pi 4|Raspberry Pi 5)"; then
			echo "dtoverlay=spi-bcm2837" >> "$CONFIG"
		fi
        green "     Added MCP2515-can0. ✅"
    else
        green "     MCP2515-can0 already present. Skipping. ℹ️"
    fi

    # 2. Раскомментировать dtparam=spi=on
    sed -i 's/^#\?dtparam=spi=on/dtparam=spi=on/' "$CONFIG"
    green "     Uncommented dtparam=spi=on in $CONFIG. ✅"

}
rpi_vga() {
	if ! [ -e /usr/lib/firmware/rpi480i.bin ] ; then
		packet_download "https://github.com/maltsevvv/repository/raw/master/driver/rpi480i.bin"
		cp -r /tmp/rpi480i.bin /usr/lib/firmware/
	fi
	if ! [ -e /usr/lib/firmware/rpi240p.bin ] ; then
		packet_download "https://github.com/maltsevvv/repository/raw/master/driver/rpi240p.bin"
		cp -r /tmp/rpi240p.bin /usr/lib/firmware/
	fi

	check_pi_model

	if ! grep -q "hdmi_vga_for_rns" "$CONFIG"; then
		echo " " >> "$CONFIG"
		echo "# hdmi_vga_for_rns" >> "$CONFIG"
		if echo "$MODEL" | grep -qE "(Raspberry Pi Zero 2 W|Raspberry Pi 2|Raspberry Pi 3)"; then
			echo "hdmi_ignore_edid=0xa5000080" >> "$CONFIG"
		fi
		echo "hdmi_force_hotplug=1" >> "$CONFIG"
		echo "hdmi_group=2" >> "$CONFIG"
		echo "hdmi_mode=87" >> "$CONFIG"
		echo "hdmi_timings=640 0 16 88 64 480 0 6 5 13 0 0 0 60 1 12700000 1" >> "$CONFIG"
		echo "#hdmi_timings=800 0 51 44 121 460 0 10 9 14 0 0 0 32 1 16000000 3" >> "$CONFIG"
		sed -i '/enable_tvout/d' $CONFIG                        # Del Analog Video 🗑️
		sed -i -r 's/(.+),composite/\1/' $CONFIG                # Del Analog Video 🗑️
		sed -i -r 's/.+(console=serial0)/\1/' $CMDLINE          # Del Analog Video 🗑️
		sed -i -r 's/(.+) vc4.tv_norm.+/\1/' $CMDLINE           # Del Analog Video 🗑️
		green "    Added VGA configuration for Pi to $CMDLINE... ✅"
	fi
	#if ! grep -q 'video=HDMI-A-1:NTSC.*margin_left=39.*margin_right=21.*margin_top=17.*margin_bottom=27' "$CMDLINE"; then
	if ! grep -q 'video=HDMI-A-1:NTSC' "$CMDLINE"; then
		echo "     Adding video and EDID parameters to $CMDLINE..."
		# Добавляем параметры в начало строки (перед существующими)
		sed -i 's/^/video=HDMI-A-1:NTSC,margin_left=39,margin_right=21,margin_top=17,margin_bottom=27 /' "$CMDLINE"
		# Добавляем EDID в конец строки
		sed -i 's/$/ drm.edid_firmware=HDMI-A-1:rpi480i.bin/' "$CMDLINE"
		#sed -i 's/$/ drm.edid_firmware=HDMI-A-1:rpi240p.bin/' $CMDLINE 
		green "Parameters added successfully. ✅"
	else
		green "Parameters already present in $CMDLINE. Skipping."
	fi


}

rpi_composite() {
	if ! grep -q 'Composite-1' $CMDLINE; then
		sed -i "s/^/video=Composite-1:720x480@60ie /" $CMDLINE   #video=Composite-1:720x480@60ie NTSC
	  # sed -i "s/^/video=Composite-1:720x576@50ie /" $CMDLINE   #video=Composite-1:720x576@50ie PAL
	fi
	if ! grep -q 'vc4.tv_norm=' $CMDLINE; then
		sed -i "s/$/ vc4.tv_norm=NTSC/" $CMDLINE                 #vc4.tv_norm=PAL for PAL
	fi
	sed -i 's/^#\?dtoverlay=vc4-kms-v3d.*/dtoverlay=vc4-kms-v3d,composite/' $CONFIG
	if ! grep -q 'enable_tvout' $CONFIG; then
		sed -i '/dtoverlay=vc4-kms-v3d/a\enable_tvout=1' $CONFIG
	fi
	sed -i '/hdmi_/d' $CONFIG                                    # Del HDMI Video 🗑️
}

rpi_audio() {
	sed -i 's/^#\?dtparam=audio=on/dtparam=audio=on/' $CONFIG
	sed -i "/.*hifiberry-dac.*/d" $CONFIG
}

rpi_pcm() {
	sed -i 's/^#\?dtparam=audio=on/#dtparam=audio=on/' $CONFIG # Del 🗑️
	if ! grep -q 'hifiberry-dac' $CONFIG; then
		sed -i '/dtparam=audio/a\dtoverlay=hifiberry-dac' $CONFIG
	fi
	if grep -q 'video=HDMI' $CMDLINE; then
		if ! grep -q 'dtoverlay=vc4-kms-v3d,noaudio' $CONFIG; then
			sed -i 's/dtoverlay=vc4-kms-v3d.*/dtoverlay=vc4-kms-v3d,noaudio/' $CONFIG
		fi
	fi
}

rpi_bt_disable(){
	rfkill unblock all
	if ! grep -q "dtoverlay=disable-bt" "$CONFIG"; then
		echo -e "\ndtoverlay=disable-bt" >> "$CONFIG"
		green "UART Bluetooth Disabled"
	else
		green "UART Bluetooth Disabled. Skipping."
	fi
}

green "Starting automated installation script for Raspberry Pi... 🚀"


# Проверка: скрипт должен запускаться только с sudo
if [ -z "$SUDO_USER" ]; then
    red "Error: The script must be run with sudo. Example sudo bash /tmp/install.sh"
    exit 1
fi

# Run checks
check_internet
check_os_version
check_pi_model

# Обновление кэша apt перед установкой
echo
echo "Update packages"
apt update || { red "Не удалось обновить кэш apt."; exit 1; }
echo
echo "Upgrade system"
apt upgrade -y &> /dev/null|| { red "Не удалось обновить ."; exit 1; }

# Установка пакетов apt
echo "Installation Packages"
install_package "samba"
install_package "kodi"
install_package "kodi-pvr-iptvsimple"
install_package "can-utils"
install_package "python3-can"
install_package "python3-pip"
install_package "overlayroot"

ntp_time() {
    check_os_version
	if echo "$PRETTY_NAME" | grep -q "bookworm"; then
		install_package "ntp"
    fi
}




ntp_time

# Установка pip-пакета
install_package "requests" "pip"

# Add configurations
kodi_service_add
kodi_service_run

samba_share_add

#run service
kodi_install_addons
kodi_configure

rpi_backup
rpi_add_can0

# Interactive prompt for Bluetooth setup (using whiptail)
if whiptail --title "Bluetooth Audio Receiver" --yesno "        Installing a Bluetooth audio receiver?\n\n      en:We recommend using a USB Bluetooth adapter.\nru:Рекомендуем использовать USB Bluetooth адаптер." 10 60; then
	bluetooth_receiver
	green "Bluetooth Receiver setup completed. ✅"
	if whiptail --title "We use an external USB Bluetooth adapter." --yesno "        en:Disable the built-in UART Bluetooth adapter\n        ru:Отключить встроенный UART адаптер Bluetooth\n                in $CONFIG." 10 60; then
		rpi_bt_disable
	else
		red "You are using UART Bluetooth"
	fi
else
	red "     You canceled the installation of Bluetooth Receiver."
fi

# Interactive select  Video Output (using whiptail)
if whiptail --title "Video Output" --yes-button " HDMI " --no-button " JACK " --yesno "en:Select HDMI-VGA or analog 3.5mm video output.\nru:Выберите видео выход HDMI-VGA или аналоговый 3.5mm." 10 60; then
	green "     Use HDMI-VGA Adapter For Video Output"
	rpi_vga
else
	rpi_composite
	red "     Use Analog Video Output Jack 3,5mm"
fi

# Interactive select  Audio Output (using whiptail)
if whiptail --title "AUDIO Output" --yes-button " PCM5102 " --no-button " ANALOG " --yesno "en:Select an audio output: external PCM5201 audio card or analog 3.5mm.\nru:Выберите аудио выход. внешняя аудио карта PCM5201 или аналоговый 3.5mm" 10 60; then
	rpi_pcm
	green "     Use Digital (PCM5102) Audio Output"
else
	rpi_audio
	red "     Use Analog Audio Output Jack 3,5mm"
fi


# Interactive select for first load (using whiptail)
XML_FILE="/home/$user/.kodi/addons/skin.rnspi/xml/custom_1103_FirstTimeRun.xml"
TEMP_FILE="/tmp/FirstTimeRun.xml.tmp"

HEIGHT=14
WIDTH=60
MENU_HEIGHT=5
TITLE="RNS model Selection"
MENU_TEXT="en: Choose a RNS model option\nru: Выберите вариант модели RNS"

OPTIONS=(
    "RNS-D" "Сontrol via RNS-D"
    "RNS-E" "Сontrol via RNS-E"
    "RNS-MFD" "Сontrol via RNS-MFD"
    "COMMAND2.0" "Сontrol via COMMAND2.0"
    "RNS-JP3" "Сontrol via IR for RNS-MFD"
)

# Используем whiptail --menu для отображения списка опций
CHOICE=$(whiptail --title "$TITLE" --menu "$MENU_TEXT" $HEIGHT $WIDTH $MENU_HEIGHT \
    "${OPTIONS[@]}" 3>&1 1>&2 2>&3)

# Обрабатываем выбор пользователя
exitstatus=$?
if [ $exitstatus = 0 ]; then
    # Удаляем старые строки, если они есть, чтобы избежать дублирования
    sed '/emulation_rnsetv\|emulation_rnsdtv\|rnsd_remote\|rnse_remote/d' "$XML_FILE" > "$TEMP_FILE"
    mv "$TEMP_FILE" "$XML_FILE"

    case "$CHOICE" in
        "RNS-D")
            echo "Выбран RNS-D"
            # Вставляем строки для RNS-D перед </window>
            sed -i '/<\/window>/i\	<onload>Skin.SetBool(emulation_rnsdtv)</onload>\n	<onload>Skin.SetBool(rnsd_remote)</onload>' "$XML_FILE"
			can0_100000
			can0_service_run
            ;;
        "RNS-E")
            echo "Выбран RNS-E"
            # Вставляем строки для RNS-E перед </window>
            sed -i '/<\/window>/i\	<onload>Skin.SetBool(emulation_rnsetv)</onload>\n	<onload>Skin.SetBool(rnse_remote)</onload>' "$XML_FILE"
			can0_100000
			can0_service_run
            ;;
        "RNS-MFD")
            echo "Выбран RNS-MFD"
            # Добавляем нужные строки для RNS-MFD
            sed -i '/<\/window>/i\	<onload>Skin.SetBool(emulation_rnsdtv)</onload>\n	<onload>Skin.SetBool(mfd_remote)</onload>' "$XML_FILE"
			can0_100000
			can0_service_run
            ;;
        "COMMAND2.0")
            echo "Выбран COMMAND2.0"
            # Добавляем нужные строки для COMMAND2.0
			sed -i '/<\/window>/i\	<onload>Skin.SetBool(emulation_rnsdtv)</onload>\n	<onload>Skin.SetBool(command_remote)</onload>' "$XML_FILE"
			can0_83333
			can0_service_run
			sed -i '/gpio-ir/d' $CONFIG # Del GPIO IR 🗑️
            ;;
        "RNS-JP3")
            echo "Выбран RNS-JP3"
            # Добавляем нужные строки для RNS-JP3
			sed -i '/<\/window>/i\	<onload>Skin.SetBool(rns-jp3)</onload>' "$XML_FILE"
			rpi_ir
			can0_100000
			can0_service_run
            ;;
    esac
    green "File $XML_FILE updated successfully. ✅"
else
    red "The user clicked Cancel. The file was not changed. ❌"
fi

green "Script completed! All tasks done. 🎉" 

# Interactive reboot 
if whiptail --title "Script completed! All tasks done" --yesno "        Reboot System Now? Then after the reboot \n         You will see a window for entering the\n\n                     activation code" 10 60; then
	reboot
else
	echo
fi
