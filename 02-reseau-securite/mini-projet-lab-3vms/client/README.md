# CLIENT - Poste d'administration

## Rôle

La VM `client` représente le poste d'administration situé dans le LAN.

Elle permet :

- d'accéder au serveur web ;
- de tester les règles de filtrage ;
- d'établir le tunnel WireGuard ;
- d'administrer `gw` par SSH ;
- d'administrer `web` en passant par `gw`.

---

## Configuration réseau

```text
Interface : ens33
Adresse   : 10.10.20.10/24
Gateway   : 10.10.20.1
Zone      : LAN
```

Configuration :

```ini
auto lo
iface lo inet loopback

auto ens33
iface ens33 inet static
    address 10.10.20.10/24
    gateway 10.10.20.1
```

---

## WireGuard

Le client constitue le poste VPN.

```text
client                         gw

10.8.0.2  <=============== >  10.8.0.1
                 VPN
             WireGuard
             UDP/51820
```

Adresse WireGuard du client :

```text
10.8.0.2/24
```

Adresse WireGuard du routeur :

```text
10.8.0.1/24
```

---

## Activation du VPN

```bash
sudo wg-quick up wg0
```

Vérification :

```bash
sudo wg show
```

Tester :

```bash
ping -c 3 10.8.0.1
```

Arrêt :

```bash
sudo wg-quick down wg0
```

---

## Administration SSH

Le routeur est administré via le VPN :

```bash
ssh gw
```

Le serveur web est administré en utilisant `gw` comme bastion :

```bash
ssh web
```

Architecture :

```text
client
   |
   | WireGuard
   v
  gw
   |
   | SSH / ProxyJump
   v
 web
```

---

## Configuration SSH

Exemple :

```sshconfig
Host gw
    HostName 10.8.0.1
    User admin

Host web
    HostName 10.10.10.10
    User admin
    ProxyJump gw
```

---

## Tests

### Connectivité avec la gateway

```bash
ping -c2 10.10.20.1
```

### Accès au serveur web

```bash
curl -I http://10.10.10.10
```

HTTPS :

```bash
curl -kI https://10.10.10.10
```

### Vérification de WireGuard

```bash
sudo wg show
ping -c2 10.8.0.1
```

### Administration de gw

```bash
ssh gw hostname
```

Résultat attendu :

```text
gw
```

### Administration de web

```bash
ssh web hostname
```

Résultat attendu :

```text
web
```

---

## Tests de sécurité

### SSH direct vers web

```bash
nc -zv -w3 10.10.10.10 22
```

Résultat attendu :

```text
timeout
```

### SSH direct vers gw

```bash
nc -zv -w3 10.10.20.1 22
```

Résultat attendu :

```text
timeout
```

L'administration doit passer par WireGuard.

---

## Outils utilisés

```text
wireguard
ssh
curl
nmap
tcpdump
dnsutils
traceroute
netcat
```