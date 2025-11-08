<img src="image/home.png" alt="home" width="250"> <img src="image/list.png" alt="list" width="250"> <img src="image/settings.png" alt="settings" width="250">

[![Raspberry - Bookworm](https://img.shields.io/badge/Raspberry-Bookworm_Lite-blue?logo=raspberrypi&logoColor=red)](https://downloads.raspberrypi.com/raspios_oldstable_lite_arm64/images/raspios_oldstable_lite_arm64-2025-10-02/2025-10-01-raspios-bookworm-arm64-lite.img.xz)
[![KODI_20-skin.rnspi](https://img.shields.io/badge/KODI_20-skin.rnspi-red?logo=kodi)](https://github.com/maltsevvv/repository/raw/refs/heads/master/kodi20/skin.rnspi/skin.rnspi-20.0.8.zip) ✅ stable version
---
![Raspberry - Trixie](https://img.shields.io/badge/Raspberry-Trixie_(Lite)-blue?logo=raspberrypi&logoColor=red)
[![KODI_21-skin.rnspi](https://img.shields.io/badge/KODI_21-skin.rnspi-red?logo=kodi)](https://github.com/maltsevvv/repository/raw/refs/heads/master/kodi21/skin.rnspi/skin.rnspi-21.0.8.zip) ‼️test version
---
[![KODI_repository](https://img.shields.io/badge/KODI_repository-red?logo=kodi)](https://github.com/maltsevvv/repository/raw/refs/heads/master/repository.rnspi.zip)
---
### Auto install
```bash
wget -P /tmp https://raw.githubusercontent.com/maltsevvv/repository/master/install.sh
sudo bash /tmp/install.sh
```
---
## last version 0.9
- 0.9
    - Access to repository updates has been changed. To update, while in the Add-ons section, press the left arrow in the interface.
- 0.8
    - Added control for RNS MFD
- 0.7
    - Changed the logic of the RNSE buttons. Long press > 10 messages
    - Added display of internet connection on the home screen, without the option to disable it
- 0.6
    - Changed the display of RPI CPU temp
    - Changed everything and added it to settings
    - CAN interface settings, now in the skin interface settings
    - Removed the CAN menu from the HOME menu

---
## [Detailed information on the website](https://sites.google.com/view/rnspi/)
## [Minimum set of components](https://github.com/maltsevvv/repository/wiki)
---

1. [Wiring diagram for connecting modules to the Raspberry PI](#raspberry-PI-connect-modules)
2. [Connection diagram of modules with RNS](#connect-to-rns)
3. [Configuring CAN data display](#configuring-can-data-display)
4. [Control buttons](#control-button-rns)
5. [Bluetooth](#bluetooth)
    - [Add device](#bluetooth_add)
    - [Remove a previously connected device](#bluetooth_del)
    - [Checking usb bluetooth adapter](#bluetooth-usb-adapter)
6. [There is no image on the PC monitor or home TV.](#not-image-monitor-or-tv)
  
---
### Configuring CAN data display   
`Settings ➡️ Interface ➡️ Skin ➡️ -Configure skin...` or open `Skin Settings`

#### Disabling HDMI-CEC notification on boot  
`Settings ️➡️ System ➡️ Input ➡️ Peripherals ➡️ CEC ➡️ Enable OFF`  

---

### Control button RNS

|   RNSE   |   RNSD   |    MFD    |  time  |   KODI   |
|----------|----------|-----------|--------|----------|
| 🔘 ↪️ ↩️  | 🔘 ↪️ ↩️  | 🔘 ↪️ ↩️  |        | 🔼 🔽    |
| | | | | |
| 🔘 press | 🔘 press | 🔘 press | < 1sec | Select   |
| 🔘 press | 🔘 press | 🔘 press | > 1sec | C.Menu / 🎦 OSD |  
| | | | | |
| ⬛🔼    | UP        | 4        | < 1sec | Up       |
| ⬛🔼    | UP        | 4        | > 1sec | 🎦🎵+skeep |
| | | | | |
| ⬛🔽    | DOWN      | 5        | < 1sec | Down     | 
| ⬛🔽    | DOWN      | 5        | > 1sec | 🎦🎵-skeep |
| | | | | |
| Previous | LEFT      | Previous | < 1sec | Left     |  
| Previous | LEFT      | Previous | > 1sec | 🎦🎵Prev |
| | | | | |
| Next     | RIGHT     | Next     | < 1sec | Right     |
| Next     | RIGHT     | Next     | > 1sec | 🎦🎵Next |
| | | | | |
| RETURN   | RETURN    | Exit     | < 1sec | Back      |
| RETURN   | RETURN    | Exit     | > 1sec | 🎦🎵Stop |
| | | | | |
| SETUP    | MODE      | 6        | < 1sec | C.Menu / 🎦 OSD |  
| SETUP    | MODE      | 6        | > 1sec | Skin Settings |
| | | | | |
|          | AS        | AS       | < 1sec | Select    |
|          | AS        | AS       | > 1sec | C.Menu / 🎦 OSD | 
| | | | | |
|          | +         | 1        | < 1sec | 🎦🎵Next |  
|          | +         | 1        | > 1sec |           |  
| | | | | |
|          | -         | 2        | < 1sec | 🎦🎵Prev |  
|          | -         | 2        | > 1sec |           |  
| | | | | |
|          |           | 3        | < 1sec | Back      |  
|          |           | 3        | > 1sec | 🎦🎵Stop |  
---

## Bluetooth  

### Bluetooth_add device  
##### Connecting to Bluetooth should work without any problems, but sometimes it doesn't work, so you have to connect manually.
```bash
sudo bluetoothctl
```
```bash
scan on
```
```bash
connect 00:00:00:00:00:00
```
```bash
trust 00:00:00:00:00:00
```
##### Replace `00:00:00:00:00:00` with your device's MAC.
---
### Bluetooth_del devices  
```bash
sudo bluetoothctl
```
```bash
devices
```
```bash
remove 00:00:00:00:00:00
```
##### Replace `00:00:00:00:00:00` with your device's MAC.  
---
### Bluetooth usb adapter
1. Checking usb bluetooth adapter
```bash
hciconfig
```
`hci1:   Type: Primary  Bus: UART` >>> ***built-in Bluetooth adapter***  
`    BD Address: E4:5F:01:0D:3A:45  ACL MTU: 1021:8  SCO MTU: 64:1`  
`    UP RUNNING PSCAN ISCAN` >>> ***works***  
`    RX bytes:3780 acl:0 sco:0 events:397 errors:0`  
`    TX bytes:67416 acl:0 sco:0 commands:397 errors:0`  

`hci0:   Type: Primary  Bus: USB` >>> ***external USB Bluetooth adapter***  
`    BD Address: 00:1A:7D:DA:71:13  ACL MTU: 679:8  SCO MTU: 48:16`  
`    DOWN` >>> ***doesn't work***  
`    RX bytes:3322355 acl:5664 sco:0 events:277 errors:0`  
`    TX bytes:5985 acl:187 sco:0 commands:71 errors:0`  

The USB Bluetooth adapter is detected as "hci0", so it needs to be unlocked.  


2. Check if it is blocked at the soft level  
```bash
rfkill list
```
`0: hci0: Bluetooth`  
`    Soft blocked: yes` >>> ***blocked*** 
`    Hard blocked: no`  

3. Unblock  
```bash
sudo rfkill unblock all
```
4. Check  
```bash
rfkill list
```
`0: hci0: Bluetooth`  
`    Soft blocked: no` >>> ***USB Bluetooth unlocked***  
`    Hard blocked: no`  

5. [Let's go back to point 1 and check](#bluetooth-usb-adapter)

6. Disable built-in UART Bluetooth 
```bash
echo -e "\ndtoverlay=disable-bt" | sudo tee -a /boot/firmware/config.txt
```

7. Check which sound card you have selected
```bash
cat /proc/asound/cards
```
8. If you only have one card, we see `0`, everything is fine:  
`0 [sndrpihifiberry]: RPi-simple - snd_rpi_hifiberry_dac`  
`                      snd_rpi_hifiberry_dac`  

9. If you have a different card, change `0` to your card number in `/etc/asound.conf`:
```bash
sudo nano /etc/asound.conf
```
---

## Raspberry PI connect modules  
❎ It is recommended to use MCP2515 with SN65HVD230 for Raspberry, as the module operates from 3.3v.  
❌ It is not recommended to use the MCP2515 with TJA1050 for Raspberry without modifications, as the module operates from 5v.  
<img src="image/mcp2515sn230.png" alt="Connect to RPI MCP2515(SN65HVD230) and PCM5201" width="400" title="Connect to RPI MCP2515(SN65HVD230) and PCM5201"> <img src="image/mcp2515tja1050.png" alt="Connect to RPI MCP2515(tja1050) and PCM5201" width="400" title="Connect to RPI MCP2515(tja1050) and PCM5201">

---
## Connect to RNS
<img src="image/rnsd.png" alt="Connect to RNSD" width="250" title="RNSD"> <img src="image/rnse.png" alt="Connect to RNSE" width="250" title="RNSE">
<img src="image/rnsjp3.png" alt="Connect to RNSJP3" width="250" title="RNSJP3">
---

## Not image monitor or tv
This happens because the resolution required for display on RNS* is 480i. Most modern devices don't support this resolution.
To fix this, you can temporarily modify the Raspberry Pi configuration file.
```bash
cd
wget https://github.com/maltsevvv/repository/raw/refs/heads/master/driver/video.sh
sudo chmod +x video.sh
```
run script
```bash
sudo bash video.sh
```
