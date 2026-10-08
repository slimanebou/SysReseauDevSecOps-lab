# GW - Routeur, pare-feu et passerelle VPN

## Rôle

La VM `gw` constitue le cœur du lab réseau.

Elle assure :

- le routage entre WAN, DMZ et LAN ;
- l'accès Internet des réseaux internes ;
- le NAT ;
- le DNAT vers le serveur web ;
- le filtrage avec iptables ;
- le VPN WireGuard ;
- le rôle de bastion SSH.

---

## Interfaces réseau

| Interface | Zone | Adresse |
|---|---|---|
| `ens33` | WAN | DHCP |
| `ens34` | DMZ | `10.10.10.1/24` |
| `ens35` | LAN | `10.10.20.1/24` |
| `wg0` | VPN | `10.8.0.1/24` |

---

## Routage

Le routage IPv4 est activé avec :

```ini
net.ipv4.ip_forward=1
```

Vérification :

```bash
cat /proc/sys/net/ipv4/ip_forward
```

Résultat attendu :

```text
1
```

---

## Pare-feu iptables

Les politiques principales sont :

```text
INPUT   DROP
FORWARD DROP
OUTPUT  ACCEPT
```

Le script principal est :

```text
firewall.sh
```

Application :

```bash
sudo chmod 750 firewall.sh
sudo ./firewall.sh apply
```

Affichage :

```bash
sudo ./firewall.sh show
```

---

## NAT

Le routeur réalise le masquerading pour permettre aux machines internes d'accéder à Internet.

```text
LAN / DMZ
    |
    v
   gw
    |
 MASQUERADE
    |
    v
 Internet
```

---

## DNAT

HTTP et HTTPS arrivant depuis le WAN sont redirigés vers :

```text
10.10.10.10
```

Ports :

```text
80/tcp
443/tcp
```

---

## WireGuard

Adresse VPN :

```text
10.8.0.1/24
```

Port :

```text
UDP/51820
```

Le poste `client` possède :

```text
10.8.0.2/24
```

Vérification :

```bash
sudo wg show
```

---

## SSH

SSH est accessible uniquement par le tunnel WireGuard.

```text
client
   |
WireGuard
   |
10.8.0.1
   |
 SSH
   |
  gw
```

Un accès SSH direct depuis le LAN doit être refusé.

---

## Diagnostic

Afficher les règles :

```bash
sudo iptables -L -n -v --line-numbers
```

NAT :

```bash
sudo iptables -t nat -L -n -v --line-numbers
```

Connexions :

```bash
sudo conntrack -L
```

Capture WAN :

```bash
sudo tcpdump -i ens33 -nn
```

Capture DMZ :

```bash
sudo tcpdump -i ens34 -nn
```

Capture LAN :

```bash
sudo tcpdump -i ens35 -nn
```

---

## Persistance

Sauvegarder les règles :

```bash
sudo netfilter-persistent save
```

Vérifier WireGuard :

```bash
sudo systemctl enable wg-quick@wg0
```

Après un redémarrage :

```bash
sudo iptables -S
sudo iptables -t nat -S
sudo wg show
cat /proc/sys/net/ipv4/ip_forward
```