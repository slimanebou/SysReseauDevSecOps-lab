# Semaine 07
 — DNS (Bind9) & DHCP

> **Phase 2 — Réseaux & Sécurité**
> Statut : ✅ Terminé

---

## Objectif de la semaine

Comprendre l'architecture DNS hiérarchique, installer et configurer Bind9 comme serveur DNS autoritaire pour `lab.internal` (zone directe + zone inverse), déployer isc-dhcp-server avec une plage dynamique et une réservation statique, et valider la chaîne complète depuis un client.

---

## Sommaire

- [1. Comprendre le DNS](#1-comprendre-le-dns)
- [2. Installer et configurer Bind9](#2-installer-et-configurer-bind9)
- [3. DHCP avec isc-dhcp-server](#3-dhcp-avec-isc-dhcp-server)
- [4. Outils de test](#4-outils-de-test)
- [5. Exercice — Lab DNS + DHCP complet](#5-exercice--lab-dns--dhcp-complet)
- [6. Dépannage](#6-dépannage)
- [Commandes clés apprises](#commandes-clés-apprises)
- [Livrables & preuves](#livrables--preuves)
- [Difficultés rencontrées & solutions](#difficultés-rencontrées--solutions)

---

## 1. Comprendre le DNS

### Rôle et hiérarchie

Le DNS traduit des noms (`www.example.com`) en adresses IP et inversement. C'est une base de données **hiérarchique et distribuée** : aucun serveur ne connaît tout, chacun connaît sa zone.

```
                     . (racine)
                     │
        ┌────────────┼────────────┐
       com          org          fr        ← TLD
        │
     example
        │
       www                                 → www.example.com.
```

> Le point final (`example.com.`) représente la racine. Il est **obligatoire** dans les fichiers de zone Bind — son absence est la faute la plus fréquente.

---

### Les acteurs du DNS

| Acteur | Rôle |
|---|---|
| **Stub resolver** | Client sur ta machine (libc, systemd-resolved) — pose la question et attend la réponse finale |
| **Résolveur récursif** | Serveur (FAI, 1.1.1.1, ton bind9) — fait tout le travail de recherche et met en cache |
| **Serveur autoritaire** | Détient la zone, répond de façon définitive pour ses domaines |
| **Serveurs racine / TLD** | N'ont pas la réponse finale — indiquent qui interroger ensuite |

---

### Récursif vs itératif

```
Client ──(récursive: www.example.com ?)──▶ Résolveur (cache vide)
                                               │
                     (itératif) ──▶ Racine     : "demande aux serveurs .com"
                     (itératif) ──▶ Serveur .com : "demande à ns1.example.com"
                     (itératif) ──▶ ns1.example.com : "www = 93.184.216.34"
                                               │
Client ◀────── 93.184.216.34 (mis en cache, TTL) ─┘
```

```bash
dig +trace www.example.com      # Rejouer ce chemin complet
```

---

### Cache et TTL

```bash
dig example.com +noall +answer
# example.com.    3600  IN  A  93.184.216.34
# 10 secondes plus tard :
# example.com.    3590  IN  A  93.184.216.34   ← TTL décroît
```

| TTL | Avantage | Inconvénient |
|---|---|---|
| Long (86400 = 24h) | Moins de trafic | Changement d'IP long à propager |
| Court (300 = 5min) | Changements rapides | Plus de requêtes DNS |

> Avant une migration, baisser le TTL **quelques jours à l'avance**.

---

### Types d'enregistrements

| Type | Rôle | Exemple |
|---|---|---|
| `A` | Nom → IPv4 | `web IN A 192.168.100.20` |
| `AAAA` | Nom → IPv6 | `web IN AAAA 2001:db8::20` |
| `CNAME` | Alias vers un autre nom | `www IN CNAME web.lab.internal.` |
| `MX` | Serveur de messagerie (priorité basse = prioritaire) | `@ IN MX 10 mail.lab.internal.` |
| `TXT` | Texte libre (SPF, DKIM) | `@ IN TXT "v=spf1 mx -all"` |
| `NS` | Serveurs de noms de la zone | `@ IN NS ns1.lab.internal.` |
| `SOA` | Métadonnées de la zone (un seul par zone) | voir ci-dessous |
| `PTR` | IP → Nom (résolution inverse) | `20 IN PTR web.lab.internal.` |
| `SRV` | Localise un service (Active Directory, LDAP) | `_ldap._tcp IN SRV 0 100 389 dc1` |

---

### Le SOA en détail

```
@ IN SOA ns1.lab.internal. admin.lab.internal. (
        2026100101 ; serial   ← version de la zone (AAAAMMJJNN)
        3600       ; refresh  ← fréquence de vérification par les secondaires
        900        ; retry    ← délai si le primaire ne répond pas
        604800     ; expire   ← durée avant qu'un secondaire cesse de répondre
        300 )      ; negative ← TTL du cache négatif (NXDOMAIN)
```

> Le **serial doit être incrémenté à chaque modification** de la zone. Sans ça, les secondaires et `rndc reload` ne voient pas le changement.

---

### Règles importantes

| Règle | Explication |
|---|---|
| CNAME ne coexiste pas avec d'autres enregistrements | Jamais de CNAME sur l'apex `@` |
| MX et NS pointent vers un nom avec enregistrement A | Jamais vers un CNAME ni directement vers une IP |
| DNS utilise UDP/53 et TCP/53 | Les deux doivent être ouverts dans le pare-feu |

---

## 2. Installer et configurer Bind9

### Installation

```bash
sudo apt update
sudo apt install bind9 bind9-utils bind9-dnsutils -y
systemctl status bind9
```

---

### Organisation des fichiers (Debian/Ubuntu)

| Fichier | Rôle |
|---|---|
| `/etc/bind/named.conf` | Fichier principal — inclut les autres |
| `/etc/bind/named.conf.options` | Options globales (écoute, forwarders, ACL) |
| `/etc/bind/named.conf.local` | Tes zones |
| `/etc/bind/named.conf.default-zones` | Zones par défaut (localhost, racine) |
| `/var/cache/bind/` | Cache et zones secondaires |

---

### Les trois rôles d'un serveur DNS

| Rôle | Description |
|---|---|
| **Autoritaire** | Répond pour ses propres zones (`lab.internal`) |
| **Récursif / cache** | Résout aussi `google.com` pour les clients |
| **Forwarder** | Délègue la récursion externe à un résolveur amont (1.1.1.1) |

> ⚠️ Un résolveur récursif ouvert à tout Internet peut servir aux attaques DDoS par amplification. **Toujours limiter la récursion au LAN**.

---

### `named.conf.options`

```
acl "lan" {
    127.0.0.1;
    192.168.100.0/24;
};

options {
    directory "/var/cache/bind";

    listen-on { 127.0.0.1; 192.168.100.10; };
    listen-on-v6 { none; };

    allow-query     { lan; };
    recursion yes;
    allow-recursion { lan; };

    forwarders { 1.1.1.1; 9.9.9.9; };
    dnssec-validation auto;
};
```

> `listen-on` précis évite le conflit avec `systemd-resolved` qui écoute déjà sur `127.0.0.53:53`.

---

### `named.conf.local` — déclarer les zones

```
zone "lab.internal" {
    type primary;
    file "/etc/bind/zones/db.lab.internal";
    allow-transfer { none; };
};

zone "100.168.192.in-addr.arpa" {
    type primary;
    file "/etc/bind/zones/db.192.168.100";
    allow-transfer { none; };
};
```

**Construire le nom de zone inverse :**

```
192.168.100.0/24  →  écrire les octets à l'envers  →  100.168.192.in-addr.arpa
10.0.0.0/8        →  10.in-addr.arpa
172.16.5.0/24     →  5.16.172.in-addr.arpa
```

---

### Fichier de zone directe

```bash
sudo mkdir -p /etc/bind/zones
sudo nano /etc/bind/zones/db.lab.internal
```

```
$TTL 86400
@   IN  SOA ns1.lab.internal. admin.lab.internal. (
            2026100101  ; serial
            3600        ; refresh
            900         ; retry
            604800      ; expire
            300 )       ; negative cache TTL

; Serveurs de noms
@       IN  NS      ns1.lab.internal.

; Messagerie et texte
@       IN  MX  10  mail.lab.internal.
@       IN  TXT     "v=spf1 mx -all"

; Enregistrements A
ns1     IN  A       192.168.100.10
web     IN  A       192.168.100.20
db      IN  A       192.168.100.21
mail    IN  A       192.168.100.25

; Alias
www     IN  CNAME   web.lab.internal.
```

**Pièges fréquents :**

| Piège | Explication |
|---|---|
| `ns1.lab.internal.` avec point final | Nom absolu — sans le point, Bind ajoute la zone et obtient `ns1.lab.internal.lab.internal.` |
| `ns1` sans point | Nom relatif — Bind ajoute automatiquement `.lab.internal` |
| `@` | Désigne la zone elle-même (`lab.internal.`) |

---

### Fichier de zone inverse

```bash
sudo nano /etc/bind/zones/db.192.168.100
```

```
$TTL 86400
@   IN  SOA ns1.lab.internal. admin.lab.internal. (
            2026100101
            3600
            900
            604800
            300 )

@       IN  NS      ns1.lab.internal.

10      IN  PTR     ns1.lab.internal.
20      IN  PTR     web.lab.internal.
21      IN  PTR     db.lab.internal.
25      IN  PTR     mail.lab.internal.
```

> `20 IN PTR web.lab.internal.` → désigne `20.100.168.192.in-addr.arpa.` → donc l'IP `192.168.100.20`.

---

### Valider, démarrer, recharger

```bash
sudo named-checkconf && echo "named.conf OK"
sudo named-checkzone lab.internal /etc/bind/zones/db.lab.internal
sudo named-checkzone 100.168.192.in-addr.arpa /etc/bind/zones/db.192.168.100

sudo systemctl restart bind9
sudo systemctl enable bind9
sudo ss -tulpn | grep :53                   # Vérifier que bind écoute sur 53
```

**Modifier une zone sans redémarrer :**

```bash
# 1. Éditer le fichier et incrémenter le serial
# 2. Vérifier
sudo named-checkzone lab.internal /etc/bind/zones/db.lab.internal
# 3. Recharger une seule zone
sudo rndc reload lab.internal
sudo rndc flush                             # Vider le cache si besoin
```

---

## 3. DHCP avec isc-dhcp-server

### Le protocole DORA

```
Client                              Serveur DHCP
  │──── DISCOVER (broadcast) ───────▶│  "Quelqu'un a une IP pour moi ?"
  │◀─── OFFER  (192.168.100.100) ────│  "Je te propose celle-ci"
  │──── REQUEST ────────────────────▶│  "Je prends celle-là"
  │◀─── ACK (bail + options) ────────│  "Confirmé pour X secondes"
```

| Port | Rôle |
|---|---|
| UDP/67 | Serveur DHCP |
| UDP/68 | Client DHCP |

> ISC DHCP est en fin de vie (remplacé par Kea depuis 2022) mais reste le plus enseigné. Les concepts sont identiques dans Kea.

---

### Installation

```bash
sudo apt install isc-dhcp-server -y
```

---

### Étape 1 — Choisir l'interface d'écoute

```bash
sudo nano /etc/default/isc-dhcp-server
```

```
INTERFACESv4="ens34"
INTERFACESv6=""
```

> Le serveur DHCP doit écouter **uniquement sur l'interface du réseau interne**. Jamais sur l'interface NAT (sinon conflit avec le DHCP de la box ou de VMware).

---

### Étape 2 — `/etc/dhcp/dhcpd.conf`

```
authoritative;
ddns-update-style none;

default-lease-time 600;
max-lease-time 7200;

subnet 192.168.100.0 netmask 255.255.255.0 {
    range 192.168.100.100 192.168.100.150;
    option routers 192.168.100.1;
    option domain-name-servers 192.168.100.10;
    option domain-name "lab.internal";
    option broadcast-address 192.168.100.255;
}

host web {
    hardware ethernet 00:0c:29:aa:bb:cc;
    fixed-address 192.168.100.20;
}
```

**Points clés :**

| Directive | Rôle |
|---|---|
| `authoritative` | Ce serveur fait référence — répond NAK aux demandes invalides |
| `range` | Plage d'IPs dynamiques (.100 à .150) |
| `option routers` | Passerelle envoyée aux clients |
| `option domain-name-servers` | Adresse du DNS (notre bind9) |
| `host` + `hardware ethernet` | Réservation statique par adresse MAC |

> La réservation doit être **hors de la plage dynamique** (`.20` hors de `.100-.150`).

---

### Étape 3 — Valider et démarrer

```bash
sudo dhcpd -t -cf /etc/dhcp/dhcpd.conf         # Test de syntaxe
sudo systemctl enable --now isc-dhcp-server
sudo systemctl status isc-dhcp-server
sudo ss -ulpn | grep :67                        # Vérifier l'écoute
```

---

### Voir les baux actifs

```bash
sudo dhcp-lease-list                            # Résumé lisible
sudo cat /var/lib/dhcp/dhcpd.leases             # Fichier brut
sudo journalctl -u isc-dhcp-server -f           # Logs en direct
```

---

### Piège VMware

Si tu utilises un réseau VMware host-only ou NAT, VMware lance son propre DHCP — deux DHCP sur le même segment répondent à tour de rôle.

**Désactiver le DHCP VMware :**

```
Virtual Network Editor → VMnet concerné → décocher "Use local DHCP service"
```

---

## 4. Outils de test

### `dig` — interroger le serveur DNS

```bash
dig @localhost web.lab.internal +short          # Réponse courte
dig @localhost www.lab.internal +short          # Suit le CNAME automatiquement
dig @localhost -x 192.168.100.20 +short         # Résolution inverse (PTR)
dig @localhost lab.internal MX +short           # Enregistrement MX
dig @localhost lab.internal NS +short           # Serveurs de noms
dig @localhost lab.internal SOA +short          # Enregistrement SOA
dig @localhost lab.internal TXT +short          # Enregistrement TXT
dig @localhost google.com +short                # Test récursion + forwarders
dig @localhost lab.internal AXFR                # Transfert de zone (doit être refusé)
dig +trace www.example.com                      # Suivre la délégation depuis les racines
```

**Lire la sortie complète de `dig` :**

| Champ | Signification |
|---|---|
| `status: NOERROR` | Réponse OK |
| `status: NXDOMAIN` | Nom inexistant |
| `status: SERVFAIL` | Problème côté serveur (zone qui ne charge pas) |
| `status: REFUSED` | ACL qui refuse le client |
| `flags: aa` | Authoritative Answer — réponse depuis la propre zone |
| `flags: ra` | Recursion Available — récursion disponible |

```bash
dig @localhost web.lab.internal | grep flags
# flags: qr aa rd ra   ← aa confirme que c'est une réponse autoritaire
```

---

### `nslookup` et `host`

```bash
nslookup web.lab.internal localhost
nslookup 192.168.100.20 localhost               # Résolution inverse
nslookup -type=MX lab.internal localhost
host web.lab.internal localhost
```

---

### Contrôles côté serveur

```bash
sudo named-checkconf                                                   # Syntaxe named.conf
sudo named-checkzone lab.internal /etc/bind/zones/db.lab.internal      # Syntaxe zone directe
sudo named-checkzone 100.168.192.in-addr.arpa /etc/bind/zones/db.192.168.100

sudo rndc reload                                # Recharger toutes les zones
sudo rndc reload lab.internal                   # Recharger une seule zone
sudo rndc flush                                 # Vider le cache
sudo rndc status
sudo journalctl -u bind9 -f
```

---

## 5. Exercice — Lab DNS + DHCP complet

### Plan d'adressage

| Machine | Rôle | IP |
|---|---|---|
| `ns1` | Serveur DNS + DHCP | `192.168.100.10` (statique) |
| `web` | Serveur web (réservation DHCP) | `192.168.100.20` |
| `db` | Base de données | `192.168.100.21` |
| `mail` | Serveur messagerie | `192.168.100.25` |
| `client1` | Poste de test | DHCP : `.100` à `.150` |

Réseau : `192.168.100.0/24` · ns1 a deux interfaces : `ens33` (NAT) et `ens34` (réseau interne).

---

### Étape 1 — IP statique sur ns1 (Netplan)

```bash
sudo nano /etc/netplan/50-cloud-init.yaml
```

```yaml
network:
  version: 2
  ethernets:
    ens33:
      dhcp4: true
    ens34:
      dhcp4: false
      addresses: [192.168.100.10/24]
```

```bash
sudo netplan apply
ip -br a                        # Vérifier : ens34 a 192.168.100.10/24
```

---

### Étape 2 — Installer Bind9

```bash
sudo apt install bind9 bind9-utils bind9-dnsutils -y
```

---

### Étape 3 — Options globales

```bash
sudo nano /etc/bind/named.conf.options
```

```
acl "lan" {
    127.0.0.1;
    192.168.100.0/24;
};

options {
    directory "/var/cache/bind";

    listen-on { 127.0.0.1; 192.168.100.10; };
    listen-on-v6 { none; };

    allow-query     { lan; };
    recursion yes;
    allow-recursion { lan; };

    forwarders { 1.1.1.1; 9.9.9.9; };
    dnssec-validation auto;
};
```

---

### Étape 4 — Déclarer les zones

```bash
sudo nano /etc/bind/named.conf.local
```

```
zone "lab.internal" {
    type primary;
    file "/etc/bind/zones/db.lab.internal";
    allow-transfer { none; };
};

zone "100.168.192.in-addr.arpa" {
    type primary;
    file "/etc/bind/zones/db.192.168.100";
    allow-transfer { none; };
};
```

---

### Étape 5 — Zone directe

```bash
sudo mkdir -p /etc/bind/zones
sudo nano /etc/bind/zones/db.lab.internal
```

```
$TTL 86400
@   IN  SOA ns1.lab.internal. admin.lab.internal. (
            2026100101  ; serial
            3600        ; refresh
            900         ; retry
            604800      ; expire
            300 )       ; negative cache TTL

@       IN  NS      ns1.lab.internal.
@       IN  MX  10  mail.lab.internal.
@       IN  TXT     "v=spf1 mx -all"

ns1     IN  A       192.168.100.10
web     IN  A       192.168.100.20
db      IN  A       192.168.100.21
mail    IN  A       192.168.100.25

www     IN  CNAME   web.lab.internal.
```

---

### Étape 6 — Zone inverse

```bash
sudo nano /etc/bind/zones/db.192.168.100
```

```
$TTL 86400
@   IN  SOA ns1.lab.internal. admin.lab.internal. (
            2026100101
            3600
            900
            604800
            300 )

@       IN  NS      ns1.lab.internal.

10      IN  PTR     ns1.lab.internal.
20      IN  PTR     web.lab.internal.
21      IN  PTR     db.lab.internal.
25      IN  PTR     mail.lab.internal.
```

---

### Étape 7 — Valider et démarrer Bind9

```bash
sudo named-checkconf && echo "named.conf OK"
sudo named-checkzone lab.internal /etc/bind/zones/db.lab.internal
sudo named-checkzone 100.168.192.in-addr.arpa /etc/bind/zones/db.192.168.100

sudo systemctl restart bind9
sudo systemctl enable bind9
sudo ss -tulpn | grep :53
```

---

### Étape 8 — Tests DNS

```bash
dig @localhost web.lab.internal +short
# 192.168.100.20

dig @localhost www.lab.internal +short
# web.lab.internal.
# 192.168.100.20

dig @localhost -x 192.168.100.20 +short
# web.lab.internal.

dig @localhost lab.internal MX +short
# 10 mail.lab.internal.

dig @localhost lab.internal SOA +short
# ns1.lab.internal. admin.lab.internal. 2026100101 3600 900 604800 300

dig @localhost inexistant.lab.internal | grep status
# status: NXDOMAIN

dig @localhost google.com +short
# 142.250.xx.xx   ← forwarders + récursion fonctionnent

dig @localhost lab.internal AXFR
# Transfer failed.   ← transfert refusé (allow-transfer { none; })
```

**Test du cache :**

```bash
dig @localhost google.com | grep "Query time"
# 1ère requête : Query time: 45 msec

dig @localhost google.com | grep "Query time"
# 2ème requête : Query time: 0 msec   ← réponse depuis le cache
```

---

### Étape 9 — Installer le DHCP

```bash
sudo apt install isc-dhcp-server -y

sudo nano /etc/default/isc-dhcp-server
# INTERFACESv4="ens34"
```

```bash
sudo nano /etc/dhcp/dhcpd.conf
```

```
authoritative;
ddns-update-style none;

default-lease-time 600;
max-lease-time 7200;

subnet 192.168.100.0 netmask 255.255.255.0 {
    range 192.168.100.100 192.168.100.150;
    option routers 192.168.100.1;
    option domain-name-servers 192.168.100.10;
    option domain-name "lab.internal";
    option broadcast-address 192.168.100.255;
}

host web {
    hardware ethernet 00:0c:29:aa:bb:cc;
    fixed-address 192.168.100.20;
}
```

```bash
sudo dhcpd -t -cf /etc/dhcp/dhcpd.conf
sudo systemctl enable --now isc-dhcp-server
sudo ss -ulpn | grep :67
```

---

### Étape 10 — Ouvrir le pare-feu (lien avec semaine 06)

```bash
sudo ufw allow from 192.168.100.0/24 to any port 53          # DNS (TCP + UDP)
sudo ufw allow in on ens34 to any port 67 proto udp           # DHCP
sudo ufw status verbose
```

---

### Étape 11 — Test côté client

```bash
# Sur client1 — activer DHCP sur l'interface
sudo netplan apply
ip -br a                        # IP dans 192.168.100.100-150
ip r                            # default via 192.168.100.1
resolvectl status ens33         # DNS Server: 192.168.100.10

# Résolution sans préciser le serveur
dig web.lab.internal +short     # 192.168.100.20
ping -c2 web.lab.internal
nslookup mail.lab.internal
```

---

### Étape 12 — Observer côté serveur

```bash
sudo dhcp-lease-list
# MAC                IP                hostname   valid until
# 00:0c:29:11:22:33  192.168.100.101   client1    ...

sudo journalctl -u isc-dhcp-server -n 20
# DHCPDISCOVER from 00:0c:29:11:22:33 via ens34
# DHCPOFFER on 192.168.100.101 to 00:0c:29:11:22:33
# DHCPREQUEST for 192.168.100.101 from ...
# DHCPACK on 192.168.100.101 to ...
```

**Observer les 4 étapes DORA avec tcpdump :**

```bash
sudo tcpdump -i ens34 -nn 'port 67 or port 68' -c 8
# 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request  (Discover)
# 192.168.100.10.67 > 192.168.100.101.68: BOOTP/DHCP, Reply (Offer)
# ...
```

**Observer les requêtes DNS :**

```bash
sudo tcpdump -i ens34 -nn udp port 53
# client : A? web.lab.internal.
# serveur : A 192.168.100.20
```

---

### Étape 13 — Modifier une zone

```bash
# 1. Éditer le fichier
sudo nano /etc/bind/zones/db.lab.internal
# Ajouter : app IN A 192.168.100.30
# Incrémenter le serial : 2026100101 → 2026100102

# 2. Vérifier
sudo named-checkzone lab.internal /etc/bind/zones/db.lab.internal

# 3. Recharger
sudo rndc reload lab.internal

# 4. Tester
dig @localhost app.lab.internal +short
# 192.168.100.30
```

---

## 6. Dépannage

| Symptôme | Cause probable | Solution |
|---|---|---|
| bind9 ne démarre pas | Erreur de syntaxe | `named-checkconf` + `journalctl -u bind9` |
| `address already in use` | Conflit avec systemd-resolved sur le port 53 | Restreindre `listen-on` à `127.0.0.1` + IP du serveur |
| Zone non chargée, SERVFAIL | Erreur dans le fichier de zone | `named-checkzone` |
| NXDOMAIN pour un nom déclaré | Point final oublié **ou** serial non incrémenté | Relire le fichier + `rndc reload` |
| REFUSED | Client non dans l'ACL | Vérifier `allow-query` et `allow-recursion` |
| Pas de `aa` dans la réponse | Réponse depuis le cache | Vérifier la déclaration de la zone |
| Résolution externe KO | Forwarders injoignables | `ping 1.1.1.1` depuis ns1 |
| Client n'obtient pas d'IP | Mauvaise interface ou DHCP VMware actif | `journalctl -u isc-dhcp-server` + désactiver DHCP VMware |
| Client reçoit une IP inattendue | Second serveur DHCP répond | `nmap --script broadcast-dhcp-discover` |
| DHCP refuse de démarrer | Pas d'IP statique dans le sous-réseau déclaré | L'interface doit avoir une IP dans `192.168.100.0/24` |
| IP obtenue mais pas de résolution | `option domain-name-servers` absent | Relire `dhcpd.conf` + `resolvectl status` |

---

## Commandes clés apprises

```bash
# Bind9
sudo apt install bind9 bind9-utils bind9-dnsutils
sudo named-checkconf
sudo named-checkzone lab.internal /etc/bind/zones/db.lab.internal
sudo systemctl restart bind9
sudo rndc reload lab.internal
sudo rndc flush
sudo rndc status

# dig
dig @localhost web.lab.internal +short
dig @localhost -x 192.168.100.20 +short
dig @localhost lab.internal MX +short
dig @localhost lab.internal SOA +short
dig +trace www.example.com
dig @localhost google.com | grep "Query time"

# nslookup / host
nslookup web.lab.internal localhost
nslookup -type=MX lab.internal localhost
host web.lab.internal localhost

# DHCP
sudo apt install isc-dhcp-server
sudo dhcpd -t -cf /etc/dhcp/dhcpd.conf
sudo systemctl enable --now isc-dhcp-server
sudo dhcp-lease-list
sudo cat /var/lib/dhcp/dhcpd.leases
sudo journalctl -u isc-dhcp-server -f

# Tcpdump DNS + DHCP
sudo tcpdump -i ens34 -nn udp port 53
sudo tcpdump -i ens34 -nn 'port 67 or port 68' -c 8
```

---

## Livrables & preuves

- [ ] Capture de `sudo ss -tulpn | grep :53` — bind9 écoute sur 53
- [ ] Capture de `dig @localhost web.lab.internal +short` → `192.168.100.20`
- [ ] Capture de `dig @localhost -x 192.168.100.20 +short` → `web.lab.internal.`
- [ ] Capture de `dig @localhost www.lab.internal +short` → CNAME suivi
- [ ] Capture de `dig @localhost google.com` — 1ère (45ms) vs 2ème requête (0ms)
- [ ] Capture de `dig @localhost lab.internal AXFR` → `Transfer failed.`
- [ ] Capture de `sudo dhcp-lease-list` avec un bail actif
- [ ] Capture de `sudo journalctl -u isc-dhcp-server` montrant les 4 étapes DORA
- [ ] Capture tcpdump des échanges DORA (ports 67/68)

---

## Difficultés rencontrées & solutions

| Difficulté rencontrée | Solution appliquée |
|---|---|
| bind9 refuse de démarrer — `address already in use` | Restreindre `listen-on` à `127.0.0.1; 192.168.100.10;` au lieu de `0.0.0.0` |
| NXDOMAIN pour un nom pourtant déclaré | Oubli du point final sur un enregistrement NS ou MX — ex: `ns1.lab.internal` sans point |
| Serial non incrémenté — zone non rechargée | Toujours incrémenter le serial AVANT `rndc reload` |
| Client n'obtient pas d'IP | DHCP VMware actif sur le même VMnet — désactivé dans Virtual Network Editor |
| Réservation DHCP ignorée | IP de réservation dans la plage dynamique — déplacée hors de `range` |
| `dig @localhost google.com` échoue | ns1 n'avait pas d'accès Internet via ens33 — vérifier la route par défaut |
