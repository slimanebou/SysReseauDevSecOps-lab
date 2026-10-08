# WEB - Serveur Nginx en DMZ

## Rôle

La VM `web` représente le serveur exposé dans la **DMZ**.

Elle héberge :

- Nginx ;
- HTTP ;
- HTTPS ;
- un certificat TLS auto-signé ;
- UFW comme pare-feu local.

---

## Configuration réseau

```text
Interface : ens33
Adresse   : 10.10.10.10/24
Gateway   : 10.10.10.1
Zone      : DMZ
```

Configuration :

```ini
auto lo
iface lo inet loopback

auto ens33
iface ens33 inet static
    address 10.10.10.10/24
    gateway 10.10.10.1
```

---

## Serveur Nginx

Installation :

```bash
sudo apt update
sudo apt install nginx openssl
```

Services exposés :

| Port | Service |
|---|---|
| 80 | HTTP |
| 443 | HTTPS |
| 22 | SSH uniquement depuis `gw` |

---

## HTTPS

Un certificat auto-signé est utilisé pour le lab.

```bash
sudo openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
  -keyout /etc/ssl/private/lab.key \
  -out /etc/ssl/certs/lab.crt \
  -subj "/CN=web.lab.internal"
```

Vérification :

```bash
curl -kI https://127.0.0.1
```

---

## Pare-feu local

La VM utilise UFW.

Politique :

```text
Incoming : DENY
Outgoing : ALLOW
```

Services autorisés :

```text
80/tcp
443/tcp
22/tcp depuis 10.10.10.1 uniquement
```

La règle SSH permet uniquement au routeur `gw` de se connecter.

---

## Isolation

La VM se trouve dans la DMZ.

Elle ne doit pas pouvoir initier de connexion vers le LAN :

```text
DMZ                           LAN

web ----------------------X client
10.10.10.10                 10.10.20.10
              BLOQUÉ
```

Cette isolation limite les possibilités de rebond vers le réseau interne en cas de compromission du serveur.

---

## Vérifications

État Nginx :

```bash
sudo systemctl status nginx
```

Ports :

```bash
sudo ss -tlnp
```

Pare-feu :

```bash
sudo ufw status verbose
```

Test HTTP :

```bash
curl -I http://127.0.0.1
```

Test HTTPS :

```bash
curl -kI https://127.0.0.1
```

Test Internet :

```bash
curl -I https://deb.debian.org
```