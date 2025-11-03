![Raspberry - Bookworm](https://img.shields.io/badge/Raspberry-Bookworm_(Lite)-blue?logo=raspberrypi&logoColor=red)➡️
[![KODI_20-skin.carpc](https://img.shields.io/badge/KODI_20-skin.carpc-red?logo=kodi)](https://github.com/maltsevvv/repository/raw/refs/heads/master/kodi20/skin.rnspi/skin.rnspi-20.0.7.zip) 
![Raspberry - Trixie](https://img.shields.io/badge/Raspberry-Trixie_(Lite)-blue?logo=raspberrypi&logoColor=red)➡️
[![KODI_21-skin.rnspi](https://img.shields.io/badge/KODI_21-skin.rnspi-red?logo=kodi)](https://github.com/maltsevvv/repository/raw/refs/heads/master/kodi21/skin.rnspi/skin.rnspi-21.0.7.zip) 
[![KODI_repository](https://img.shields.io/badge/KODI_repository-red?logo=kodi)](https://github.com/maltsevvv/repository/raw/refs/heads/master/repository.rnspi.zip)



### Auto install
```bash
wget -P /tmp https://raw.githubusercontent.com/maltsevvv/repository/master/install.sh
sudo bash /tmp/install.sh
```
---
#### Начиная с версия **.0.6 и выше... .Настройки интерфейса CAN перенесены в   
`Settings ️️➡️ Interface ➡️  Skin ➡️ -Configure skin...`  

---

### Control

|   RNSE   |   RNSD   |        |  KODI  |
| -------- | ---------|--------|--------|
| 🔘 ↪️ ↩️ | 🔘 ↪️ ↩️  |        | 🔼 🔽 |
|          |          |        |        |
| 🔘 press | 🔘 press | < 1sec | Select |
| 🔘 press | 🔘 press | > 1sec | C.Menu / 🎦 OSD |  
|           |          |       |        |
| ⬛🔼     | UP       | < 1sec | Up    |
| ⬛🔼     | UP       | > 1sec | 🎦+20min |
|           |          |        |        |
| ⬛🔽     | DOWN     | < 1sec | Down   | 
| ⬛🔽     | DOWN     | > 1sec | 🎦-20min |
|           |          |        |        |
| Previous  | LEFT     | < 1sec | Left     |  
| Previous  | LEFT     | > 1sec | 🎦Prev |
|           |          |        |        |
| Next      | RIGHT    | < 1sec | Right  |
| Next      | RIGHT    | > 1sec | 🎦Next |
|           |          |        |        |
| RETURN    | RETURN   | < 1sec | Back   |
| RETURN    | RETURN   | > 1sec | 🎦Stop |
|           |          |        |        |
| SETUP     | MODE     | < 1sec | C.Menu / 🎦 OSD |  
| SETUP     | MODE     | > 1sec | Skin Settings |
|           |          |        |        |
|           | AS       | < 1sec | Select |
|           | AS       | > 1sec | C.Menu / 🎦 OSD | 
---

## Bluetooth
1. Проверка USB Адаптера
    ```bash
    hciconfig
    ```
    `hci1:   Type: Primary  Bus: UART` >>> ***встроенный bluetooth адаптер***  
    `    BD Address: E4:5F:01:0D:3A:45  ACL MTU: 1021:8  SCO MTU: 64:1`  
    `    UP RUNNING PSCAN ISCAN` >>> ***работает***  
    `    RX bytes:3780 acl:0 sco:0 events:397 errors:0`  
    `    TX bytes:67416 acl:0 sco:0 commands:397 errors:0`  

    `hci0:   Type: Primary  Bus: USB` >>> ***внешний usb bluetooth адаптер***  
    `    BD Address: 00:1A:7D:DA:71:13  ACL MTU: 679:8  SCO MTU: 48:16`  
    `    DOWN` >>> ***не работает***  
    `    RX bytes:3322355 acl:5664 sco:0 events:277 errors:0`  
    `    TX bytes:5985 acl:187 sco:0 commands:71 errors:0`  

    usb bluetooth адаптер, опредилися на `hci0`. Значит его нужно разблокировать  


    2. Проверяем, не заблакирован ли он, на уровне soft  
    ```bash
    rfkill list
    ```
    `0: hci0: Bluetooth`  
    `    Soft blocked: yes` >>> ***заблокирован***  
    `    Hard blocked: no`  
    `1: hci1: Bluetooth`  
    `    Soft blocked: no`  
    `    Hard blocked: no`  
    `2: phy0: Wireless LAN`  
    `    Soft blocked: no`  
    `    Hard blocked: no`  

    3. Разблокируем его  
    ```bash
    sudo rfkill unblock 0
    ```
    4. Блокируем встроенный  
    ```bash
    sudo rfkill block 1
    ```
    5. Проверяем  
    ```bash
    rfkill list
    ```
    `0: hci0: Bluetooth`  
    `    Soft blocked: no` >>> ***usb bluetooth разблокирован***  
    `    Hard blocked: no`  
    `1: hci1: Bluetooth`  
    `    Soft blocked: yes` >>> ***встроенный заблокирован***  
    `    Hard blocked: no`  
    `2: phy0: Wireless LAN`  
    `    Soft blocked: no`  
    `    Hard blocked: no`  

    6. Повторная проверка usb bluetooth адаптер  
    ```bash
    hciconfig
    ```
    `hci1:   Type: Primary  Bus: UART` >>> ***встроенный bluetooth адаптер***  
    `    BD Address: E4:5F:01:0D:3A:45  ACL MTU: 1021:8  SCO MTU: 64:1`  
    `    DOWN` >>> ***не работает***  
    `    RX bytes:3780 acl:0 sco:0 events:397 errors:0`  
    `    TX bytes:67416 acl:0 sco:0 commands:397 errors:0`  

    `hci0:   Type: Primary  Bus: USB` >>> ***внешний usb bluetooth адаптер***  
    `    BD Address: 00:1A:7D:DA:71:13  ACL MTU: 679:8  SCO MTU: 48:16`  
    `    UP RUNNING PSCAN ISCAN` >>> ***работает***  
    `    RX bytes:3322355 acl:5664 sco:0 events:277 errors:0`  
    `    TX bytes:5985 acl:187 sco:0 commands:71 errors:0`  

    7. Так же, можем отключить его вообще  
    ```bash
    echo "dtoverlay=disable-bt" >> "/boot/firmware/config.txt"
    ```
