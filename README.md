# HAXAGON workstation container with sysbox runtime

**Still in early state of work!!!**

Listens on port 22 (SSH) and 7681 (HTTP terminal)

## Options

| ENVIRONMENT  | default |Popis |
| - | - | - |
| **Vzdálený přístup** | | |
| USERNAME | admin | Uživatelské jméno pro vzdálený přístup
| PASSWORD | admin | Heslo jméno pro vzdálený přístup
| SHELL | /bin/bash | Výchozí shell uživatele
| SUDO | false | Přidá uživatele do skupiny sudo
| WEB_SHELL | false | Spuštění webové konzole
| **Entrypoint** | | |
| ENTRYPOINT_PATH | /tmp/entrypoint.sh | Cesta ke scriptu, který se spustí při startu kontejneru (musí být spustitelný, nesmí být `/var/lib/entrypoint.sh`)
| ENTRYPOINT_REMOVE | true | Odstranění scriptu po ukončení
| ENTRYPOINT_DEBUG | true | Zapnutí bash debug modu pro entrypoint
