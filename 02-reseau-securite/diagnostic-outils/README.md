# Semaine 05

— Réseau Linux : outils de diagnostic

> **Phase 2 — Réseaux & Sécurité**
> Statut : ✅ Terminé

---

## Objectif de la semaine

Maîtriser les outils modernes de diagnostic réseau sous Linux : inspecter les interfaces et la table de routage avec `ip`, lister les ports ouverts avec `ss`, tester la connectivité avec `ping` / `traceroute` / `mtr`, interroger le DNS avec `dig`, capturer le trafic avec `tcpdump` et tester des services HTTP avec `curl`.

---

## Sommaire

- [1. La commande ip — paquet iproute2](#1-la-commande-ip--paquet-iproute2)
- [2. ss — sockets et ports ouverts](#2-ss--sockets-et-ports-ouverts)
- [3. Tester la connectivité et le DNS](#3-tester-la-connectivité-et-le-dns)
- [4. tcpdump — capturer le trafic](#4-tcpdump--capturer-le-trafic)
- [5. curl et wget](#5-curl-et-wget)
- [6. Exercice — Lister et identifier tous les ports ouverts](#6-exercice--lister-et-identifier-tous-les-ports-ouverts)
- [Réflexe de diagnostic](#réflexe-de-diagnostic)
- [Commandes clés apprises](#commandes-clés-apprises)
- [Livrables & preuves](#livrables--preuves)
- [Difficultés rencontrées & solutions](#difficultés-rencontrées--solutions)

---

## 1. La commande ip — paquet iproute2

`ifconfig`, `route`, `arp` et `netstat` appartiennent au paquet `net-tools`, déprécié et souvent absent des installations récentes. `ip` et `ss` les remplacent.

### Tableau de correspondance ancien → moderne

| Ancienne commande | Équivalent moderne |
| --- | --- |
| `ifconfig` | `ip a` (ou `ip addr`) |
| `ifconfig eth0 up` | `ip link set eth0 up` |
| `route -n` | `ip r` (ou `ip route`) |
| `route add default gw X` | `ip route add default via X` |
| `arp -a` | `ip neigh` |
| `netstat -tulpn` | `ss -tulpn` |

---

### `ip a` — adresses (couche 3)

```bash
ip a                    # Toutes les interfaces avec leurs adresses
ip -br a                # Version compacte et lisible
ip a show ens33         # Une seule interface
```

**Exemple de sortie `ip a` :**

```javascript
2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP
    link/ether 00:0c:29:4a:b1:7e brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.20/24 brd 192.168.1.255 scope global dynamic ens33
    inet6 fe80::20c:29ff:fe4a:b17e/64 scope link
```

**Décoder la sortie :**

| Élément | Signification |
| --- | --- |
| `ens33` | Nom de l'interface (eth0, enp0s3, ens33 selon la distribution) |
| `UP` | Interface activée administrativement |
| `LOWER_UP` | Câble ou lien détecté — UP sans LOWER_UP = problème physique |
| `link/ether` | Adresse MAC |
| `inet 192.168.1.20/24` | Adresse IPv4 et masque CIDR |
| `dynamic` | Adresse obtenue par DHCP |
| `mtu 1500` | Taille maximale des trames |

**Version compacte :**

```bash
ip -br a
# lo      UNKNOWN  127.0.0.1/8
# ens33   UP       192.168.1.20/24 fe80::20c:29ff:fe4a:b17e/64
```

---

### `ip link` — couche 2

```bash
ip link                         # Liste des interfaces, état, MAC
ip -s link show ens33           # Statistiques : paquets, erreurs, drops
sudo ip link set ens33 down     # Désactiver une interface
sudo ip link set ens33 up       # Réactiver une interface
```

> Dans `ip -s link`, des compteurs `errors` et `dropped` non nuls révèlent souvent un problème de câble, de duplex ou de saturation.

---

### `ip r` — table de routage

```bash
ip r                            # Afficher la table de routage complète
ip route get 8.8.8.8            # Par où sortirait un paquet vers 8.8.8.8 ?
```

**Exemple de sortie :**

```javascript
default via 192.168.1.1 dev ens33 proto dhcp metric 100
192.168.1.0/24 dev ens33 proto kernel scope link src 192.168.1.20
```

| Ligne | Signification |
| --- | --- |
| `default via 192.168.1.1` | Passerelle par défaut — tout ce qui n'est pas local passe par elle |
| `192.168.1.0/24 dev ens33` | Réseau directement connecté |

```bash
ip route get 8.8.8.8
# 8.8.8.8 via 192.168.1.1 dev ens33 src 192.168.1.20
```

---

### Modifier la configuration (temporaire — perdu au reboot)

```bash
sudo ip addr add 192.168.1.50/24 dev ens33          # Ajouter une IP
sudo ip addr del 192.168.1.50/24 dev ens33          # Supprimer une IP
sudo ip route add 10.10.0.0/16 via 192.168.1.254    # Ajouter une route statique
sudo ip route del 10.10.0.0/16                       # Supprimer une route
sudo ip route add default via 192.168.1.1            # Changer la passerelle
```

> Pour rendre les modifications permanentes : Netplan (Ubuntu), `/etc/network/interfaces` (Debian), `nmcli` (NetworkManager) ou `systemd-networkd`.

---

### `ip neigh` — table ARP

```bash
ip neigh                        # Afficher les voisins ARP connus
```

**Exemple :**

```javascript
192.168.1.1  dev ens33 lladdr 00:50:56:c0:00:08 REACHABLE
192.168.1.15 dev ens33 lladdr 00:0c:29:aa:bb:cc STALE
```

| État | Signification |
| --- | --- |
| `REACHABLE` | Voisin récemment confirmé |
| `STALE` | À revérifier (cache expiré) |
| `FAILED` | Pas de réponse ARP — machine éteinte ou mauvais VLAN |

---

## 2. ss — sockets et ports ouverts

`ss` (**socket statistics**) lit directement les informations du noyau. Plus rapide que `netstat` et permet des filtres puissants.

### Options à retenir : `-tulpn`

| Option | Signification |
| --- | --- |
| `-t` | Sockets TCP |
| `-u` | Sockets UDP |
| `-l` | Uniquement les sockets en écoute (listening) |
| `-p` | Affiche le processus associé (nécessite sudo) |
| `-n` | Pas de résolution de noms — affiche `22` et non `ssh` |
| `-a` | Toutes les sockets (écoute + connexions établies) |
| `-s` | Résumé statistique |

```bash
sudo ss -tulpn                  # La commande la plus utilisée
ss -tn state established        # Connexions TCP établies
ss -s                           # Résumé statistique
```

---

### Lire la colonne `Local Address`

| Adresse | Signification |
| --- | --- |
| `0.0.0.0:22` | Écoute sur toutes les interfaces IPv4 → joignable depuis le réseau |
| `127.0.0.1:8080` | Écoute uniquement en local → invisible de l'extérieur |
| `[::]:22` | Toutes les interfaces IPv6 |
| `192.168.1.20:80` | Écoute uniquement sur cette IP |

---

### Filtres utiles

```bash
ss -tn state established                        # Connexions TCP actives
ss -tn state established '( dport = :443 )'    # Connexions vers port 443
ss -tulpn 'sport = :22'                         # Qui écoute sur le port 22 ?
ss -tn dst 192.168.1.15                         # Connexions vers une IP
ss -tan | grep -c TIME-WAIT                     # Compter les TIME-WAIT
```

---

## 3. Tester la connectivité et le DNS

### `ping` — test ICMP

```bash
ping -c 4 8.8.8.8               # 4 paquets vers Google DNS
ping -c 2 -i 0.2 192.168.1.1    # Intervalle de 0.2 secondes
ping -s 1472 192.168.1.1        # Taille de paquet personnalisée
ping -I ens33 8.8.8.8           # Forcer une interface source
```

> Un ping échoué ne prouve pas que la machine est éteinte : un pare-feu peut bloquer l'ICMP.

---

### Méthode de diagnostic — du plus proche au plus loin

```bash
ping -c2 127.0.0.1          # 1. Pile TCP/IP locale OK ?
ping -c2 192.168.1.20       # 2. Sa propre IP
ping -c2 192.168.1.1        # 3. La passerelle → LAN OK ?
ping -c2 8.8.8.8            # 4. Internet en IP → routage/NAT OK ?
ping -c2 google.com         # 5. Par nom → DNS OK ?
```

**Interprétation :**

| Résultat | Cause probable |
| --- | --- |
| Étape 1 échoue | Pile réseau locale cassée |
| Étape 3 échoue | Problème LAN, vSwitch ou VLAN |
| Étape 4 passe, étape 5 échoue | Problème DNS uniquement |

---

### `traceroute` et `mtr`

```bash
traceroute -n 8.8.8.8          # Tracer le chemin vers 8.8.8.8 (sans résolution DNS)
traceroute -T -n 8.8.8.8       # Utiliser TCP au lieu d'UDP (contourne certains firewalls)
mtr -rwc 20 8.8.8.8            # Rapport continu — 20 cycles
```

> `* * *` dans traceroute = le routeur ne répond pas (filtrage), ce n'est pas forcément une panne.
> Dans `mtr` : une perte qui persiste jusqu'au **dernier saut** est réelle. Une perte sur un saut intermédiaire seulement est du rate-limiting ICMP.

---

### DNS : `dig`, `nslookup`, `host`

```bash
dig example.com +short              # Réponse courte (IP uniquement)
dig example.com A                   # Enregistrement IPv4
dig example.com MX                  # Serveurs de messagerie
dig example.com NS                  # Serveurs de noms
dig @8.8.8.8 example.com            # Interroger un serveur DNS précis
dig -x 8.8.8.8 +short               # Résolution inverse (PTR)
dig +trace example.com              # Suivre la délégation depuis les racines
```

**Lire la sortie de `dig` :**

| Champ | Signification |
| --- | --- |
| `status: NOERROR` | Requête réussie |
| `status: NXDOMAIN` | Le nom n'existe pas |
| `status: SERVFAIL` | Erreur côté serveur DNS |
| `TTL` | Durée de mise en cache de la réponse |
| `Query time` | Temps de réponse du serveur DNS |

```bash
nslookup example.com 8.8.8.8        # Interroger un serveur précis (ancien)
host example.com                    # Sortie lisible
host -t MX example.com             # Enregistrement MX uniquement
```

> Si `dig @8.8.8.8 monsite.fr` fonctionne mais `dig monsite.fr` échoue → le résolveur dans `/etc/resolv.conf` est en cause.

---

## 4. tcpdump — capturer le trafic

```bash
sudo tcpdump -i ens33 -nn           # Capturer sur ens33, sans résolution de noms
sudo tcpdump -i any -nn             # Toutes les interfaces
```

### Options principales

| Option | Rôle |
| --- | --- |
| `-i ens33` | Interface à écouter |
| `-nn` | Pas de résolution DNS ni de noms de ports |
| `-c 10` | S'arrêter après 10 paquets |
| `-v` / `-vv` | Plus de détails |
| `-A` | Contenu en ASCII (utile pour HTTP en clair) |
| `-X` | Contenu en hexadécimal et ASCII |
| `-w fichier.pcap` | Écrire dans un fichier (ouvrable dans Wireshark) |
| `-r fichier.pcap` | Relire un fichier pcap |

---

### Filtres BPF

```bash
sudo tcpdump -i ens33 -nn port 80                           # Trafic sur le port 80
sudo tcpdump -i ens33 -nn host 192.168.1.15                # Vers/depuis une IP
sudo tcpdump -i ens33 -nn src 192.168.1.15                 # Uniquement source
sudo tcpdump -i ens33 -nn net 10.0.0.0/8                   # Un réseau entier
sudo tcpdump -i ens33 -nn icmp                             # Uniquement ping
sudo tcpdump -i ens33 -nn udp port 53                      # Requêtes DNS
sudo tcpdump -i ens33 -nn 'tcp port 22 and host 192.168.1.15'
sudo tcpdump -i ens33 -nn 'port 80 or port 443'
sudo tcpdump -i ens33 -nn 'tcp[tcpflags] & tcp-syn != 0'   # Seulement les SYN
```

---

### Exemple 1 — Observer un ping

```bash
# Terminal 1
sudo tcpdump -i ens33 -nn -c 4 icmp

# Terminal 2
ping -c 2 192.168.1.1
```

Sortie attendue :

```javascript
10:02:11.104 IP 192.168.1.20 > 192.168.1.1: ICMP echo request, seq 1
10:02:11.105 IP 192.168.1.1 > 192.168.1.20: ICMP echo reply, seq 1
```

---

### Exemple 2 — Observer le handshake TCP

```bash
sudo tcpdump -i ens33 -nn 'tcp port 80 and host 192.168.1.15' -c 6
```

**Séquence des flags TCP :**

| Flag | Signification |
| --- | --- |
| `[S]` | SYN — demande de connexion |
| `[S.]` | SYN-ACK — acceptation |
| `[.]` | ACK — confirmation |
| `[P.]` | PUSH — données envoyées |
| `[F.]` | FIN — fermeture |
| `[R.]` | RST — reset — port fermé ou connexion refusée |

> Un `[S]` qui se répète sans réponse = pare-feu qui filtre ou service absent.
> Un `[R.]` = port fermé.

---

### Exemple 3 — Vérifier le DNS

```bash
# Terminal 1
sudo tcpdump -i ens33 -nn udp port 53

# Terminal 2
dig example.com
```

On voit la requête `A? example.com.` et la réponse avec l'IP.

---

### Sauvegarder pour Wireshark

```bash
sudo tcpdump -i ens33 -w capture.pcap port 443
# Ouvrir capture.pcap dans Wireshark pour analyse graphique
```

---

## 5. curl et wget

### `curl` — tester des services HTTP

```bash
curl http://example.com                                     # Corps de la réponse
curl -I http://example.com                                  # En-têtes uniquement (HEAD)
curl -v http://example.com                                  # Détail complet requête + réponse
curl -s -o /dev/null -w "%{http_code}\n" http://example.com # Juste le code HTTP
curl -L http://example.com                                  # Suit les redirections
curl -k https://192.168.1.15                                # Ignore les erreurs de certificat
curl --max-time 5 http://192.168.1.15                       # Timeout à 5 secondes
```

**Cas d'usage avancés :**

```bash
curl -H "Authorization: Bearer TOKEN" http://api.local/data        # Header custom
curl -X POST -H "Content-Type: application/json" \
     -d '{"nom":"test"}' http://api.local/items                     # POST JSON

curl --resolve monsite.local:80:192.168.1.15 http://monsite.local/ # Tester un vhost sans DNS
curl -H "Host: monsite.local" http://192.168.1.15/                 # Idem

curl -s -o /dev/null -w "DNS:%{time_namelookup}s connect:%{time_connect}s total:%{time_total}s\n" \
     https://example.com                                            # Mesurer les temps
```

---

### Codes HTTP à retenir

| Code | Signification |
| --- | --- |
| `200` | OK — succès |
| `301` | Redirection permanente |
| `302` | Redirection temporaire |
| `401` | Non authentifié |
| `403` | Accès interdit |
| `404` | Ressource introuvable |
| `500` | Erreur interne du serveur |
| `502` | Bad Gateway |
| `503` | Service indisponible |
| `504` | Timeout de la passerelle |

**Codes d'erreur curl fréquents :**

| Code curl | Cause |
| --- | --- |
| `(6)` | Could not resolve host — problème DNS |
| `(7)` | Failed to connect — port fermé, service arrêté ou filtré |
| `(28)` | Timeout dépassé |
| `(60)` | Certificat SSL non vérifiable |

---

### `wget` — télécharger des fichiers

```bash
wget http://example.com/fichier.iso                         # Télécharger
wget -O sortie.html http://example.com                      # Nom de fichier choisi
wget -c http://example.com/gros.iso                         # Reprendre un téléchargement
wget --spider http://example.com                            # Vérifier l'existence sans télécharger
wget -S --spider http://example.com                         # Idem avec les en-têtes
wget -r -np -l 2 http://example.com/docs/                   # Téléchargement récursif limité
```

> En règle générale : `curl` pour tester des APIs et diagnostiquer, `wget` pour télécharger des fichiers.

---

## 6. Exercice — Lister et identifier tous les ports ouverts

**Objectif :** Lister tous les ports en écoute sur la VM, identifier chaque service et évaluer son exposition réseau.

---

### Étape 1 — Lister les ports

```bash
sudo ss -tulpn
```

**Exemple de sortie (VM avec SSH, Nginx, MariaDB) :**

```javascript
Netid  State   Local Address:Port   Process
udp    UNCONN  127.0.0.53%lo:53     users:(("systemd-resolve",...))
udp    UNCONN  192.168.1.20%ens33:68 users:(("systemd-network",...))
tcp    LISTEN  0.0.0.0:22           users:(("sshd",...))
tcp    LISTEN  0.0.0.0:80           users:(("nginx",...))
tcp    LISTEN  127.0.0.1:3306       users:(("mariadbd",...))
```

---

### Étape 2 — Identifier chaque service

| Port | Proto | Écoute sur | Processus | Rôle | Exposition |
| --- | --- | --- | --- | --- | --- |
| 53 | UDP+TCP | `127.0.0.53` | systemd-resolved | Résolveur DNS local | ✅ Local uniquement |
| 68 | UDP | IP ens33 | systemd-networkd | Client DHCP | ✅ Normal |
| 22 | TCP | `0.0.0.0` | sshd | Accès SSH distant | ⚠️ Exposé réseau |
| 80 | TCP | `0.0.0.0` | nginx | Serveur web HTTP | ⚠️ Exposé réseau |
| 3306 | TCP | `127.0.0.1` | mariadbd | Base de données | ✅ Local uniquement |

---

### Étape 3 — Vérifier et recouper

```bash
sudo ss -tulpn 'sport = :3306'              # Qui écoute sur 3306 ?
sudo lsof -i :80                            # Autre méthode
ps -fp 845                                  # Détails du processus PID 845
systemctl status mariadb                    # Unité systemd correspondante
grep -w 3306 /etc/services                  # Nom officiel du port
```

**Vérifier depuis l'extérieur (depuis une autre VM) :**

```bash
nmap -sT -p- 192.168.1.20                  # Scanner tous les ports TCP
nc -zv 192.168.1.20 3306                   # Ce port est-il joignable ?
```

**Confirmer avec le trafic :**

```bash
sudo tcpdump -i ens33 -nn port 80 -c 5
# Puis depuis un autre poste : curl http://192.168.1.20
```

---

### Étape 4 — Analyse et principe de moindre exposition

```javascript
Ce qui est joignable du réseau : SSH (22) et HTTP (80) → voulu
Ce qui est local : DNS stub, chrony, MariaDB → correct

Si on voyait 0.0.0.0:3306 → PROBLÈME
  → Corriger : bind-address = 127.0.0.1 dans /etc/mysql/mariadb.conf.d/
  → Ou filtrer avec UFW : sudo ufw deny 3306
```

```bash
sudo systemctl disable --now nom_du_service     # Désactiver un service inutile
```

**Si un port inconnu apparaît :**

```bash
ss -tulpn                               # 1. Identifier le PID
ls -l /proc/PID/exe                     # 2. Retrouver le binaire
dpkg -S /chemin/du/binaire              # 3. Retrouver le paquet
                                        # 4. Décider : garder, restreindre ou supprimer
```

---

## Réflexe de diagnostic

```javascript
Ma machine a-t-elle une IP, une route ?   →  ip -br a    ip r
Le réseau répond-il ?                     →  ping (passerelle → IP externe → nom)
Où ça casse ?                             →  traceroute / mtr
Le nom se résout-il ?                     →  dig
Le service écoute-t-il ?                  →  ss -tulpn
Le service répond-il correctement ?       →  curl -v
Que se passe-t-il sur le fil ?            →  tcpdump -nn
```

---

## Commandes clés apprises

```bash
# ip
ip a              ip -br a          ip a show ens33
ip link           ip -s link show ens33
ip r              ip route get 8.8.8.8
ip neigh
sudo ip addr add 192.168.1.50/24 dev ens33
sudo ip route add 10.0.0.0/8 via 192.168.1.254

# ss
sudo ss -tulpn
ss -tn state established
ss -tulpn 'sport = :22'
ss -s

# ping / traceroute / mtr
ping -c 4 8.8.8.8
traceroute -n 8.8.8.8
mtr -rwc 20 8.8.8.8

# dig
dig example.com +short
dig example.com A
dig @8.8.8.8 example.com
dig -x 8.8.8.8 +short
dig +trace example.com

# tcpdump
sudo tcpdump -i ens33 -nn port 80
sudo tcpdump -i ens33 -nn host 192.168.1.15
sudo tcpdump -i ens33 -nn icmp
sudo tcpdump -i ens33 -nn udp port 53
sudo tcpdump -i ens33 -w capture.pcap port 443

# curl / wget
curl -I http://example.com
curl -v http://example.com
curl -s -o /dev/null -w "%{http_code}\n" http://example.com
wget --spider http://example.com
```

---

## Livrables & preuves

- [ ] Capture de `ip -br a` et `ip r` sur la VM
- [ ] Capture de `sudo ss -tulpn` avec tous les ports identifiés
- [ ] Capture de la méthode de diagnostic `ping` étape par étape
- [ ] Capture de `dig example.com +short` et `dig @8.8.8.8 example.com`
- [ ] Capture tcpdump d'un ping (ICMP request + reply)
- [ ] Capture tcpdump du handshake TCP (SYN, SYN-ACK, ACK)
- [ ] Tableau d'analyse des ports rempli avec les services de ta VM

---

## Difficultés rencontrées & solutions

| Difficulté rencontrée | Solution appliquée |
| --- | --- |
| `ifconfig` introuvable sur Debian | Utiliser `ip a` — ou installer `net-tools` si vraiment nécessaire |
| `ss -p` n'affiche pas le processus | Ajouter `sudo` — les PID des autres utilisateurs nécessitent les droits root |
| `ping google.com` échoue mais `ping 8.8.8.8` fonctionne | Problème DNS — vérifier `/etc/resolv.conf` et tester avec `dig` |
| `traceroute` bloqué sur `* * *` | Normal si le routeur filtre l'ICMP — utiliser `-T` (TCP) pour contourner |
| `tcpdump` ne capture rien | Vérifier le nom de l'interface avec `ip -br a` — utiliser `-i any` pour toutes |
| `curl` renvoie code `(7)` | Port fermé ou service arrêté — vérifier avec `ss -tulpn` |
| `dig` retourne `NXDOMAIN` | Le nom n'existe pas — tester avec `dig @8.8.8.8` pour isoler le résolveur local |
