# Semaine 08
 — VPN WireGuard

> **Phase 2 — Réseaux & Sécurité**
> Statut : ✅ Terminé
---

## Objectif de la semaine

Comprendre le fonctionnement d'un VPN, installer WireGuard sur deux VMs, générer les paires de clés, configurer le tunnel, activer le forwarding IP et valider le chiffrement avec tcpdump. Aller plus loin avec le split tunnel et le full tunnel.

---

## Sommaire

- [1. WireGuard vs OpenVPN](#1-wireguard-vs-openvpn)
- [2. Concepts WireGuard](#2-concepts-wireguard)
- [3. Installation et génération des clés](#3-installation-et-génération-des-clés)
- [4. Exercice — Tunnel WireGuard entre deux VMs](#4-exercice--tunnel-wireguard-entre-deux-vms)
- [5. Pour aller plus loin](#5-pour-aller-plus-loin)
- [6. Dépannage](#6-dépannage)
- [Commandes clés apprises](#commandes-clés-apprises)
- [Livrables & preuves](#livrables--preuves)
- [Difficultés rencontrées & solutions](#difficultés-rencontrées--solutions)

---

## 1. WireGuard vs OpenVPN

### Principe d'un VPN

Un VPN crée une interface réseau virtuelle (`wg0`, `tun0`) dont le trafic est **chiffré puis encapsulé** dans des paquets UDP envoyés à travers le réseau réel.

```
VM client                                            VM serveur
10.8.0.2  ──▶ [wg0] ══ chiffré, UDP/51820 ══▶ [wg0]  10.8.0.1
              (192.168.100.11)  réseau réel  (192.168.100.10)
```

---

### Comparaison WireGuard vs OpenVPN

| Critère | WireGuard | OpenVPN |
|---|---|---|
| Code | ~4 000 lignes, audit facile | Plusieurs centaines de milliers de lignes |
| Intégration | Module du noyau Linux (depuis 5.6) | Processus en espace utilisateur |
| Cryptographie | Fixe et moderne : Curve25519, ChaCha20-Poly1305, BLAKE2s | Négociable (TLS, nombreux chiffrements) |
| Protocole | UDP uniquement | UDP ou TCP (443/TCP traverse presque tous les pare-feux) |
| Configuration | Un fichier de ~10 lignes | Fichier long, souvent une PKI |
| Performances | Très bonnes, faible latence | Correctes, plus coûteux en CPU |
| Itinérance (roaming) | Changement d'IP sans coupure | Reconnexion nécessaire |
| Discrétion | Invisible aux scans (ne répond pas aux paquets non authentifiés) | Répond au handshake TLS |
| Authentification | Une clé publique par pair | Certificats, login/mot de passe, LDAP, 2FA |

---

### Pourquoi WireGuard est devenu le standard

- **Simplicité** : peu de code = moins de bugs et de mauvaises configurations
- **Pas de négociation d'algorithmes** : pas d'attaque par rétrogradation possible
- **Performance** : exécuté dans le noyau, handshake rapide (framework Noise)
- **Natif** : Linux, Windows, macOS, Android, iOS, BSD, pfSense, OPNsense

---

### Limites à connaître

| Limite | Explication |
|---|---|
| UDP seulement | Bloqué sur certains réseaux d'entreprise ou publics |
| Pas d'IP dynamique | Chaque pair a une IP VPN fixe déclarée à la main |
| Pas d'auth utilisateur native | Pas de login/mot de passe, pas de 2FA — l'identité = la clé |
| Vie privée | Le serveur garde en mémoire l'IP publique de chaque client |

> OpenVPN reste pertinent pour le TCP/443 ou une intégration annuaire (LDAP, 2FA).

---

## 2. Concepts WireGuard

### Une paire de clés par machine

Chaque pair possède une **clé privée** (secrète, ne quitte jamais la machine) et une **clé publique** (dérivée de la privée, à donner à l'autre pair). Même modèle que SSH avec `authorized_keys`.

---

### Sections `[Interface]` et `[Peer]`

| Section | Champ | Rôle |
|---|---|---|
| `[Interface]` | `Address` | IP de la machine dans le VPN |
| | `PrivateKey` | Clé privée locale |
| | `ListenPort` | Port UDP d'écoute (51820 par convention) |
| | `DNS` | DNS actif tant que le VPN est actif (géré par wg-quick) |
| | `PostUp` / `PostDown` | Commandes exécutées à l'activation/désactivation |
| `[Peer]` | `PublicKey` | Clé publique du pair distant |
| | `Endpoint` | IP:port réel du pair (indispensable côté client) |
| | `AllowedIPs` | Routage sortant + filtre entrant (voir ci-dessous) |
| | `PersistentKeepalive` | Paquet toutes les N secondes pour maintenir le NAT ouvert (`25` est la valeur usuelle) |
| | `PresharedKey` | Secret symétrique optionnel en couche supplémentaire |

---

### `AllowedIPs` — le concept central

`AllowedIPs` joue **deux rôles simultanément** :

- **Table de routage (sortant)** : tout paquet vers ces IP est chiffré et envoyé à ce pair
- **Filtre (entrant)** : un paquet reçu de ce pair dont l'IP source n'est pas dans cette liste est jeté

C'est le **cryptokey routing**.

| `AllowedIPs` côté client | Effet |
|---|---|
| `10.8.0.1/32` | Seul le serveur est joignable via le VPN |
| `10.8.0.0/24` | Tout le réseau VPN |
| `10.8.0.0/24, 192.168.200.0/24` | Le VPN + un LAN derrière le serveur (split tunnel) |
| `0.0.0.0/0, ::/0` | Tout le trafic passe par le VPN (full tunnel) |

> Côté serveur, `AllowedIPs = 10.8.0.2/32` signifie « ce pair n'a le droit d'utiliser que l'IP 10.8.0.2 » — empêche l'usurpation d'IP.

---

### Sans connexion, sans démon

WireGuard n'a pas de notion de session établie. L'interface est toujours "up" et le handshake se déclenche au **premier paquet** à envoyer, puis se renouvelle toutes les ~2 minutes.

> `wg show` n'affiche pas de `latest handshake` tant qu'aucun trafic n'a circulé. **Lancer un ping avant de lire `wg show`**.

---

## 3. Installation et génération des clés

### Installation (sur les deux VMs)

```bash
sudo apt update
sudo apt install wireguard -y

wg --version
sudo modprobe wireguard && lsmod | grep wireguard      # Module chargé
```

> Sur Ubuntu 20.04+ et Debian 11+, le module est déjà dans le noyau.

---

### Générer les clés

```bash
sudo mkdir -p /etc/wireguard
cd /etc/wireguard
umask 077                                               # Fichiers créés en 600
wg genkey | sudo tee privatekey | wg pubkey | sudo tee publickey
```

**Décortiqué :**

```
wg genkey      → génère une clé privée (base64, 44 caractères)
tee privatekey → écrit dans le fichier ET transmet à la suite
wg pubkey      → calcule la clé publique correspondante
```

```bash
sudo ls -l /etc/wireguard
# -rw------- 1 root root 45 ...  privatekey
# -rw------- 1 root root 45 ...  publickey

sudo cat publickey
# 7Jq4Z...hQ8=
```

**Clé pré-partagée (optionnelle, couche symétrique supplémentaire) :**

```bash
wg genpsk | sudo tee presharedkey
```

---

### Règles de sécurité des clés

| Règle | Explication |
|---|---|
| Ne jamais partager la clé privée | Pas de dépôt Git, pas de capture d'écran |
| Seules les clés publiques s'échangent | Entre les VMs uniquement |
| Permissions `600`, propriété `root` | `sudo chmod 600 /etc/wireguard/*` |

---

## 4. Exercice — Tunnel WireGuard entre deux VMs

### Plan d'adressage

| Élément | Valeur |
|---|---|
| Réseau hôte (host-only) | `192.168.100.0/24` |
| VM-A (serveur) | `192.168.100.10` |
| VM-B (client) | `192.168.100.11` |
| Réseau VPN | `10.8.0.0/24` |
| IP VPN serveur | `10.8.0.1` |
| IP VPN client | `10.8.0.2` |
| Port | `51820/udp` |

---

### Étape 0 — Vérifier la connectivité sous-jacente

```bash
# Sur VM-B
ping -c2 192.168.100.10
```

> Le VPN ne fonctionnera que si les deux VMs se voient déjà en IP réelle.

---

### Étape 1 — Générer les clés (sur chaque VM)

```bash
# VM-A (serveur)
cd /etc/wireguard && umask 077
wg genkey | sudo tee server_private.key | wg pubkey | sudo tee server_public.key
sudo cat server_public.key          # noter la clé publique du serveur

# VM-B (client)
cd /etc/wireguard && umask 077
wg genkey | sudo tee client_private.key | wg pubkey | sudo tee client_public.key
sudo cat client_public.key          # noter la clé publique du client
```

> Dans la suite : `<SRV_PRIV>`, `<SRV_PUB>`, `<CLI_PRIV>`, `<CLI_PUB>` désignent le contenu de ces fichiers.

---

### Étape 2 — Configuration du serveur (VM-A)

```bash
sudo nano /etc/wireguard/wg0.conf
```

```ini
[Interface]
Address = 10.8.0.1/24
ListenPort = 51820
PrivateKey = <SRV_PRIV>

[Peer]
# client1
PublicKey = <CLI_PUB>
AllowedIPs = 10.8.0.2/32
```

```bash
sudo chmod 600 /etc/wireguard/wg0.conf
```

> Le serveur écoute sur le port 51820, se donne l'IP 10.8.0.1, et accepte un seul pair — identifié par sa clé publique — qui n'a le droit d'utiliser que l'IP 10.8.0.2.

---

### Étape 3 — Configuration du client (VM-B)

```bash
sudo nano /etc/wireguard/wg0.conf
```

```ini
[Interface]
Address = 10.8.0.2/24
PrivateKey = <CLI_PRIV>

[Peer]
# serveur
PublicKey = <SRV_PUB>
Endpoint = 192.168.100.10:51820
AllowedIPs = 10.8.0.0/24
PersistentKeepalive = 25
```

```bash
sudo chmod 600 /etc/wireguard/wg0.conf
```

> **Erreur fréquente** : mettre la clé privée du serveur dans `[Peer]`. Dans `[Peer]`, c'est **toujours la clé publique de l'autre machine**.

---

### Étape 4 — Activer le forwarding IP (serveur)

```bash
# Temporaire (perdu au reboot)
sudo sysctl -w net.ipv4.ip_forward=1

# Permanent
echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/99-wireguard.conf
sudo sysctl --system

# Vérification
cat /proc/sys/net/ipv4/ip_forward          # doit afficher 1
sysctl net.ipv4.ip_forward                 # net.ipv4.ip_forward = 1
```

> Le forwarding est obligatoire dès que le serveur relaie du trafic (LAN derrière lui ou full tunnel).

---

### Étape 5 — Ouvrir le pare-feu (si UFW actif)

```bash
# Sur le serveur uniquement
sudo ufw allow 51820/udp comment 'WireGuard'
sudo ufw allow in on wg0 comment 'trafic VPN'
sudo ufw status verbose
```

> Le client n'a rien à ouvrir — il initie la connexion, les réponses passent par le suivi de connexion.

---

### Étape 6 — Démarrer le tunnel

```bash
# Sur serveur ET client
sudo wg-quick up wg0
# [#] ip link add wg0 type wireguard
# [#] wg setconf wg0 /dev/fd/63
# [#] ip -4 address add 10.8.0.1/24 dev wg0
# [#] ip link set mtu 1420 up dev wg0

# Activer au démarrage
sudo systemctl enable --now wg-quick@wg0
sudo systemctl status wg-quick@wg0

# Arrêter le tunnel
sudo wg-quick down wg0
```

---

### Étape 7 — Tests

#### 7.1 — Interface et routes

```bash
ip -br a show wg0
# wg0   UNKNOWN   10.8.0.2/24    ← UNKNOWN est normal (pas de lien physique)

ip r
# 10.8.0.0/24 dev wg0 proto kernel scope link src 10.8.0.2

ip route get 10.8.0.1
# 10.8.0.1 dev wg0 src 10.8.0.2
```

---

#### 7.2 — Ping à travers le tunnel

```bash
# Depuis le client
ping -c 4 10.8.0.1
# 64 bytes from 10.8.0.1: icmp_seq=1 ttl=64 time=0.9 ms

# Depuis le serveur
ping -c 4 10.8.0.2
```

---

#### 7.3 — État du tunnel avec `wg show`

```bash
sudo wg show
```

```
interface: wg0
  public key: <SRV_PUB>
  private key: (hidden)
  listening port: 51820

peer: <CLI_PUB>
  endpoint: 192.168.100.11:49821
  allowed ips: 10.8.0.2/32
  latest handshake: 12 seconds ago
  transfer: 1.45 KiB received, 1.12 KiB sent
```

**Indicateurs clés :**

| Indicateur | Signification |
|---|---|
| `latest handshake` récent | Tunnel établi ✅ |
| `latest handshake` absent | Aucun échange cryptographique — lancer un ping d'abord |
| `transfer` monte des deux côtés | Trafic bidirectionnel ✅ |
| `sent` monte mais pas `received` | Paquets partent mais aucune réponse ne revient |
| `endpoint` côté serveur | IP réelle du client, apprise dynamiquement |

---

#### 7.4 — Prouver le chiffrement avec tcpdump

```bash
# Terminal 1 : interface RÉELLE → trafic chiffré
sudo tcpdump -i ens33 -nn udp port 51820 -c 4
# IP 192.168.100.11.49821 > 192.168.100.10.51820: UDP, length 128
# IP 192.168.100.10.51820 > 192.168.100.11.49821: UDP, length 128

# Terminal 2 : interface VIRTUELLE → trafic en clair
sudo tcpdump -i wg0 -nn icmp -c 4
# IP 10.8.0.2 > 10.8.0.1: ICMP echo request, seq 1
# IP 10.8.0.1 > 10.8.0.2: ICMP echo reply, seq 1
```

> Sur `ens33` : paquets UDP opaques (aucun ICMP lisible).
> Sur `wg0` : le même échange ICMP apparaît en clair.
> C'est la **démonstration du fonctionnement du tunnel**.

---

#### 7.5 — Service à travers le VPN

```bash
# Serveur : lancer un serveur HTTP de test dans le VPN
python3 -m http.server 8000 --bind 10.8.0.1

# Client : tester
curl -I http://10.8.0.1:8000            # HTTP/1.0 200 OK
ssh utilisateur@10.8.0.1               # SSH à travers le tunnel
```

---

## 5. Pour aller plus loin

### Split tunnel — accéder à un LAN derrière le serveur

Cas : le serveur a un LAN interne `192.168.200.0/24` (carte `ens34`) et le client doit y accéder.

**Serveur — ajouter dans `[Interface]` :**

```ini
PostUp   = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o ens34 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -s 10.8.0.0/24 -o ens34 -j MASQUERADE
```

**Client — étendre `AllowedIPs` :**

```ini
AllowedIPs = 10.8.0.0/24, 192.168.200.0/24
```

```bash
sudo wg-quick down wg0 && sudo wg-quick up wg0
ping -c2 192.168.200.20             # Machine du LAN interne
```

---

### Full tunnel — tout le trafic via le VPN

**Serveur :**

```ini
PostUp   = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o ens33 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -s 10.8.0.0/24 -o ens33 -j MASQUERADE
```

**Client :**

```ini
[Interface]
Address = 10.8.0.2/24
PrivateKey = <CLI_PRIV>
DNS = 1.1.1.1

[Peer]
PublicKey = <SRV_PUB>
Endpoint = 192.168.100.10:51820
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
```

```bash
curl -s ifconfig.me         # Affiche l'IP publique du SERVEUR, pas celle du client
ip route get 8.8.8.8        # ... dev wg0
```

---

### Ajouter un second client sans couper les autres

```bash
# Ajout à chaud
sudo wg set wg0 peer <CLI2_PUB> allowed-ips 10.8.0.3/32

# Rendre permanent dans wg0.conf
sudo nano /etc/wireguard/wg0.conf        # Ajouter un [Peer]

# Recharger sans interrompre les tunnels existants
sudo wg syncconf wg0 <(sudo wg-quick strip wg0)
```

> Pour **révoquer** un client : supprimer son `[Peer]` dans le fichier + `wg syncconf`. L'accès est révoqué immédiatement sans toucher aux autres.

---

### Client mobile par QR code

```bash
sudo apt install qrencode
qrencode -t ansiutf8 < client.conf      # Scanner avec l'appli WireGuard mobile
```

> ⚠️ Ce QR code contient une clé privée. Ne pas le partager ni le laisser traîner.

---

## 6. Dépannage

| Symptôme | Cause probable | Solution |
|---|---|---|
| Pas de `latest handshake` | Clés inversées, mauvais Endpoint, port bloqué | Relire `PublicKey` des deux côtés + `tcpdump udp port 51820` |
| Paquets reçus mais pas de handshake | Clé publique du client absente ou erronée côté serveur | Les paquets de pairs inconnus sont ignorés silencieusement |
| Handshake OK, ping KO | `AllowedIPs` trop restreint, pare-feu sur `wg0` | `wg show`, `ufw status`, `ip route get 10.8.0.1` |
| LAN derrière serveur inaccessible | `ip_forward=0`, règle FORWARD manquante | `cat /proc/sys/net/ipv4/ip_forward`, `iptables -L FORWARD -n -v` |
| Full tunnel : plus d'Internet | Pas de NAT côté serveur, DNS non configuré | Règle MASQUERADE, `DNS =` côté client |
| `Warning: ... is world accessible` | Permissions trop ouvertes sur le fichier de config | `sudo chmod 600 /etc/wireguard/wg0.conf` |
| `Operation not supported` | Module absent (noyau ancien, conteneur LXC) | `sudo modprobe wireguard`, vérifier version du noyau |
| `Address already in use` | Interface `wg0` existe déjà | `sudo wg-quick down wg0` puis `up` |
| Connexions lentes sur gros transferts | Problème de MTU | `ping -M do -s 1372 10.8.0.1`, ajuster `MTU =` |
| Tunnel tombe derrière un NAT | Le NAT oublie la correspondance | `PersistentKeepalive = 25` côté client |
| Modification de `wg0.conf` sans effet | Interface non rechargée | `wg-quick down/up` ou `wg syncconf` |

---

## Commandes clés apprises

```bash
# Installation
sudo apt install wireguard
wg --version
sudo modprobe wireguard

# Clés
wg genkey | sudo tee privatekey | wg pubkey | sudo tee publickey
wg genpsk | sudo tee presharedkey
sudo chmod 600 /etc/wireguard/*

# wg-quick
sudo wg-quick up wg0
sudo wg-quick down wg0
sudo systemctl enable --now wg-quick@wg0

# État et diagnostic
sudo wg show
sudo wg show wg0

# Modifier à chaud
sudo wg set wg0 peer <PUB> allowed-ips 10.8.0.3/32
sudo wg syncconf wg0 <(sudo wg-quick strip wg0)

# Forwarding
sudo sysctl -w net.ipv4.ip_forward=1
cat /proc/sys/net/ipv4/ip_forward
echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/99-wireguard.conf

# Pare-feu
sudo ufw allow 51820/udp comment 'WireGuard'
sudo ufw allow in on wg0

# tcpdump (preuve du chiffrement)
sudo tcpdump -i ens33 -nn udp port 51820 -c 4      # Interface réelle = chiffré
sudo tcpdump -i wg0 -nn icmp -c 4                  # Interface virtuelle = en clair

# Routes (outils du cours réseau)
ip -br a show wg0
ip r
ip route get 10.8.0.1
```

---

## Livrables & preuves

- [ ] Capture de `sudo wg show` avec `latest handshake` récent et `transfer` dans les deux sens
- [ ] Capture de `ping -c4 10.8.0.1` depuis le client — temps de réponse < 2ms
- [ ] Capture de `ip r` montrant la route `10.8.0.0/24 dev wg0`
- [ ] Capture tcpdump `ens33` → paquets UDP opaques (aucun ICMP lisible)
- [ ] Capture tcpdump `wg0` → ICMP echo request/reply en clair
- [ ] Capture de `cat /proc/sys/net/ipv4/ip_forward` → `1`
- [ ] Capture de `sudo ufw status` avec le port 51820/udp ouvert

---

## Difficultés rencontrées & solutions

| Difficulté rencontrée | Solution appliquée |
|---|---|
| Pas de handshake — tunnel silencieux | Clé publique du serveur copiée dans `[Interface]` au lieu de `[Peer]` — corrigé |
| `wg show` n'affiche pas de `latest handshake` | Pas de trafic lancé — un `ping` déclenche le premier handshake |
| Ping OK dans un sens, KO dans l'autre | `AllowedIPs` trop restreint d'un côté — ajusté à `/24` |
| `Warning: ... is world accessible` au démarrage | `chmod 600 /etc/wireguard/wg0.conf` — permissions corrigées |
| Tunnel ne passe pas le pare-feu | Port 51820/udp non ouvert dans UFW sur le serveur |
| Forwarding actif mais LAN inaccessible | Règles `iptables -A FORWARD` manquantes dans `PostUp` |
