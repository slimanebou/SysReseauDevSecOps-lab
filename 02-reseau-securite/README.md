# Module 02 — Infrastructure Réseau, Diagnostic & Sécurité

🎯 Objectifs

Ce module regroupe l'ensemble des compétences fondamentales et avancées en ingénierie réseau et sécurité sous Linux :
- Maîtrise de l'inspection de la couche réseau, de la table de routage, des sockets d'écoute et de l'analyse de trafic réseau (`iproute2`, `tcpdump`).
- Implémentation d'une politique de sécurité pare-feu stricte en *DEFAULT DENY*, filtrage *stateful* et gestion du NAT/PAT avec `iptables` et `UFW`.
- Déploiement et administration de services d'infrastructure critiques : résolveur/serveur autoritaire DNS (`Bind9`) et attribution dynamique d'IP (`isc-dhcp-server`).
- Interconnexion sécurisée d'équipements et de réseaux distants via des tunnels chiffrés haut débit avec `WireGuard`.
- Segmentation réseau avancée, routage inter-VLAN et filtrage périmétrique d'entreprise avec `pfSense`.

📂 Structure du module

| Dossier / Sujet | Compétence | Statut |
| :--- | :--- | :--- |
| **[01-diagnostic-outils](./diagnostic-outils/)** | Inspection réseau moderne (`ip`, `ss`), diagnostic ICMP/DNS/HTTP (`ping`, `traceroute`, `dig`, `curl`) & capture de paquets (`tcpdump`) | ✅ Terminé |
| **[02-firewall-ufw-iptables](./firewall-ufw-iptables/)** | Filtrage réseau *Netfilter*, pare-feu d'hôte `UFW` & `iptables`, politique *DEFAULT DENY*, NAT/PAT & redirection de ports | ✅ Terminé |
| **[03-services-dns-dhcp](./services-dns-dhcp/)** | Infrastructure DNS autoritaire & récursive avec `Bind9` (zones directe/inverse) et distribution IP dynamique/statique avec `isc-dhcp-server` | ✅ Terminé |
| **[04-vpn-wireguard](./vpn-wireguard/)** | Tunnels chiffrés point-à-point avec `WireGuard`, gestion des paires de clés ED25519, *Cryptokey Routing*, *split-tunnel* & *full-tunnel* | ✅ Terminé |
| **[05-vlan-pfsense](./vlan-pfsense/)** | Router-on-a-stick, segmentation VLANs, routage inter-VLAN, matrices de flux & pare-feu périmétrique avec `pfSense` | ⬜ Non terminé |
| **[06-mini-projet-lab-3vms](./mini-projet-lab-3vms/)** | **Mini-projet concret :** Architecture 3 VMs (Gateway/Router, Web DMZ & Client LAN) avec routage, NAT, filtrage et isolation de zones | ✅ Terminé |

🛠️ Outils & Technologies maîtrisés

- **Outils de Diagnostic & Analyse :** `ip` (`iproute2`), `ss`, `ping`, `traceroute`, `mtr`, `dig`, `nslookup`, `tcpdump`, `curl`, `wget`.
- **Pare-feu & Filtrage :** `UFW`, `iptables` (tables filter/nat, conntrack), `pfSense`, VLAN (802.1Q).
- **Services d'Infrastructure Réseau :** `Bind9` (DNS), `isc-dhcp-server` (DHCP), `Netplan`, `/etc/network/interfaces`.
- **VPN & Chiffrement :** `WireGuard` (`wg`, `wg-quick`), paires de clés Curve25519 / ED25519.