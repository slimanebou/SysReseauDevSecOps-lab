<div align="center">

# 🖥️ sysreseau-lab
### Lab personnel d'ingénierie Système & Réseau — Master 2 IRS

[![Linux](https://img.shields.io/badge/Linux-Ubuntu_22.04-E95420?style=flat&logo=ubuntu&logoColor=white)](https://ubuntu.com/)
[![Docker](https://img.shields.io/badge/Docker-Conteneurisation-2496ED?style=flat&logo=docker&logoColor=white)](https://docker.com/)
[![Ansible](https://img.shields.io/badge/Ansible-Automatisation-EE0000?style=flat&logo=ansible&logoColor=white)](https://ansible.com/)
[![pfSense](https://img.shields.io/badge/pfSense-Firewall_&_NAT-212121?style=flat&logo=pfsense&logoColor=white)](https://pfsense.org/)
[![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-CI/CD-2088FF?style=flat&logo=githubactions&logoColor=white)](https://github.com/features/actions)
[![Prometheus](https://img.shields.io/badge/Prometheus-Monitoring-E6522C?style=flat&logo=prometheus&logoColor=white)](https://prometheus.io/)
[![Grafana](https://img.shields.io/badge/Grafana-Dashboards-F46800?style=flat&logo=grafana&logoColor=white)](https://grafana.com/)
[![Windows Server](https://img.shields.io/badge/Windows_Server-Active_Directory-0078D6?style=flat&logo=windows&logoColor=white)](https://microsoft.com/)

---

*Lab d'apprentissage progressif — 14 semaines · 3 soirs/semaine · 45 min/session*

</div>

---

## Présentation

Ce dépôt documente mon parcours d'apprentissage pratique en administration **Systèmes & Réseaux** dans le cadre de ma deuxième année de Master en Ingénierie Réseaux et Systèmes (2026–2027).

L'objectif est de construire un **mini datacenter virtualisé** sur VMware Workstation couvrant l'ensemble des compétences attendues d'un ingénieur Sys&Réseaux en entreprise :
- Administration Linux avancée (services, stockage, sécurité)
- Segmentation réseau : VLAN, pare-feu pfSense, NAT, VPN WireGuard
- Services réseau : DNS (Bind9), DHCP, Active Directory
- Conteneurisation Docker et orchestration via Docker Compose
- Automatisation de configuration avec Ansible
- Pipeline CI/CD avec GitHub Actions
- Supervision avec Prometheus et Grafana

Chaque semaine est documentée avec les commandes apprises, les livrables produits et les difficultés rencontrées.

---

## Progression — 14 semaines

### Phase 1 — Administration Linux & Système
- [ ] [Semaine 01 — Linux fondations & terminal](./01-linux-fondations/README.md)
- [ ] [Semaine 02 — SSH sécurisé & Bash scripting](./02-ssh-bash/README.md)
- [ ] [Semaine 03 — Stockage, logs & automatisation cron](./03-stockage-logs/README.md)

### Phase 2 — Réseaux & Sécurité
- [ ] [Semaine 04 — Diagnostic réseau Linux & pare-feu UFW](./04-reseau-diagnostic/README.md)
- [ ] [Semaine 05 — DNS (Bind9), DHCP & VPN WireGuard](./05-dns-dhcp-vpn/README.md)
- [ ] [Semaine 06 — VLAN, pfSense & routage inter-VLAN](./06-vlan-pfsense/README.md)

### Phase 3 — Virtualisation & Services d'entreprise
- [ ] [Semaine 07 — Active Directory & Windows Server](./07-active-directory/README.md)
- [ ] [Semaine 08 — Services internes, MySQL & prise en main à distance](./08-services-internes/README.md)
- [ ] [Semaine 09 — Monitoring : Prometheus & Grafana](./09-monitoring/README.md)

### Phase 4 — DevOps & Automatisation
- [ ] [Semaine 10 — Docker & conteneurisation](./10-docker/README.md)
- [ ] [Semaine 11 — Ansible : automatisation de configuration](./11-ansible/README.md)
- [ ] [Semaine 12 — CI/CD avec GitHub Actions](./12-cicd/README.md)

### Phase 5 — Portfolio & Préparation stage
- [ ] [Semaine 13 — GitHub pro & documentation finale](./13-github-portfolio/README.md)
- [ ] [Semaine 14 — CV, pitch STAR & simulation entretien](./14-cv-entretiens/README.md)

---

## Stack technique

| Domaine | Technologies |
|---|---|
| Hyperviseur | VMware Workstation |
| Systèmes | Ubuntu Server 22.04, Windows Server 2022 |
| Réseau & Sécurité | pfSense, WireGuard, Bind9, isc-dhcp-server, UFW, iptables |
| Annuaire | Active Directory, DHCP/DNS Windows Server |
| Conteneurisation | Docker Engine, Docker Compose |
| Automatisation | Ansible, Bash scripting |
| CI/CD | GitHub Actions |
| Monitoring | Prometheus, Grafana, Node Exporter |
| Versioning | Git, GitHub |

---

## Suivi de progression

| Semaine | Statut | Compétence principale | Livrable |
|---|---|---|---|
| S01 | ⬜ | Linux terminal | VM Ubuntu + scripts |
| S02 | ⬜ | SSH + Bash | Script health_check.sh |
| S03 | ⬜ | Stockage + Cron | LVM + backup_etc.sh |
| S04 | ⬜ | Réseau + UFW | Cheatsheet réseau |
| S05 | ⬜ | DNS + DHCP + VPN | Lab DNS fonctionnel |
| S06 | ⬜ | VLAN + pfSense | Lab réseau 3 VLANs |
| S07 | ⬜ | Active Directory | AD + GPO documenté |
| S08 | ⬜ | Services internes | MySQL + RDP/SSH |
| S09 | ⬜ | Monitoring | Dashboard Grafana |
| S10 | ⬜ | Docker | Stack Docker Compose |
| S11 | ⬜ | Ansible | Playbook master |
| S12 | ⬜ | CI/CD | Pipeline GitHub Actions |
| S13 | ⬜ | Portfolio | README pro |
| S14 | ⬜ | Entretiens | Pitch STAR + CV |

---

<div align="center">
*Étudiant M2 Ingénierie Réseaux et Systèmes · En recherche de stage (début 2027)*
</div>
