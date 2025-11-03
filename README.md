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


#### Проверка USB Адаптера
```bash
hciconfig
```

`hci0:   Type: Primary  Bus: USB`  
`        BD Address: 00:1A:7D:DA:71:13  ACL MTU: 679:8  SCO MTU: 48:16`  
`        DOWN НЕ работает`  
`        RX bytes:706 acl:0 sco:0 events:22 errors:0`  
`        TX bytes:68 acl:0 sco:0 commands:22 errors:0`  
Проверяем   

    rfkill list all

Ecли видим `Soft blocked: yes`. Он заблокирован  

`0: hci0: Bluetooth`  
`        Soft blocked: yes`  
`        Hard blocked: no`  
`1: hci1: Bluetooth`  
`        Soft blocked: no`  
`        Hard blocked: no`  

Разблокируем его  

    sudo rfkill unblock all

Проверяем   

    rfkill list all

Видим `Soft blocked: yes`. `Изменился на Soft blocked: no`  

`0: hci0: Bluetooth`  
`        Soft blocked: no`  
`        Hard blocked: no`  
`1: hci1: Bluetooth`  
`        Soft blocked: no`  
`        Hard blocked: no`  
