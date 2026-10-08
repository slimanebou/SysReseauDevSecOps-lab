<div align="center">

# 🖥️ SysReseauDevSecOps-lab

### Systèmes • Réseaux • Cybersécurité • DevOps • Cloud


[![Debian](https://img.shields.io/badge/Debian-Linux-A81D24?style=flat&logo=debian&logoColor=white)](https://debian.org/)
[![Windows Server](https://img.shields.io/badge/Windows_Server-2022-0078D6?style=flat&logo=windows&logoColor=white)](https://microsoft.com/)
[![VMware](https://img.shields.io/badge/VMware-Workstation-607078?style=flat&logo=vmware&logoColor=white)](https://vmware.com/)
[![Proxmox](https://img.shields.io/badge/Proxmox-VE-E57000?style=flat&logo=proxmox&logoColor=white)](https://proxmox.com/)
[![pfSense](https://img.shields.io/badge/pfSense-Firewall_&_NAT-212121?style=flat&logo=pfsense&logoColor=white)](https://pfsense.org/)
[![iptables](https://img.shields.io/badge/iptables-Firewall-D22115?style=flat&logo=linux&logoColor=white)](https://netfilter.org/)
[![UFW](https://img.shields.io/badge/UFW-Firewall-E95420?style=flat&logo=ubuntu&logoColor=white)](https://ubuntu.com/)
[![WireGuard](https://img.shields.io/badge/WireGuard-VPN-88171A?style=flat&logo=wireguard&logoColor=white)](https://wireguard.com/)
[![Bind9](https://img.shields.io/badge/Bind9-DNS-005571?style=flat&logo=bind9&logoColor=white)](https://isc.org/bind/)
[![DHCP](https://img.shields.io/badge/DHCP-ISC_Server-005571?style=flat&logo=linux&logoColor=white)](https://isc.org/)
[![Nmap](https://img.shields.io/badge/Nmap-Scanning-4682B4?style=flat&logo=nmap&logoColor=white)](https://nmap.org/)
[![tcpdump](https://img.shields.io/badge/tcpdump-Packet_Analysis-39457E?style=flat&logo=wireshark&logoColor=white)](https://tcpdump.org/)
[![Active Directory](https://img.shields.io/badge/Active_Directory-DS_&_GPO-0078D6?style=flat&logo=windows&logoColor=white)](https://microsoft.com/)
[![Nginx](https://img.shields.io/badge/Nginx-Web_Server-009639?style=flat&logo=nginx&logoColor=white)](https://nginx.org/)
[![SSH](https://img.shields.io/badge/SSH-Secure_Administration-333333?style=flat&logo=openssh&logoColor=white)](https://openssh.com/)
[![Docker](https://img.shields.io/badge/Docker-Conteneurisation-2496ED?style=flat&logo=docker&logoColor=white)](https://docker.com/)
[![Docker Compose](https://img.shields.io/badge/Docker_Compose-Orchestration-2496ED?style=flat&logo=docker&logoColor=white)](https://docker.com/)
[![Ansible](https://img.shields.io/badge/Ansible-Automation-EE0000?style=flat&logo=ansible&logoColor=white)](https://ansible.com/)
[![Terraform](https://img.shields.io/badge/Terraform-IaC-7B42BC?style=flat&logo=terraform&logoColor=white)](https://terraform.io/)
[![Azure](https://img.shields.io/badge/Azure-Cloud-0078D4?style=flat&logo=microsoftazure&logoColor=white)](https://azure.microsoft.com/)
[![GitLab CI/CD](https://img.shields.io/badge/GitLab_CI%2FCD-Pipelines-FCA121?style=flat&logo=gitlab&logoColor=white)](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/)
[![Prometheus](https://img.shields.io/badge/Prometheus-Monitoring-E6522C?style=flat&logo=prometheus&logoColor=white)](https://prometheus.io/)
[![Grafana](https://img.shields.io/badge/Grafana-Dashboards-F46800?style=flat&logo=grafana&logoColor=white)](https://grafana.com/)
[![Bash](https://img.shields.io/badge/Bash-Scripting-4EAA25?style=flat&logo=gnubash&logoColor=white)](https://gnu.org/software/bash/)
[![Python](https://img.shields.io/badge/Python-Automation-3776AB?style=flat&logo=python&logoColor=white)](https://python.org/)
[![Git](https://img.shields.io/badge/Git-Version_Control-F05032?style=flat&logo=git&logoColor=white)](https://git-scm.com/)
[![GitHub](https://img.shields.io/badge/GitHub-Versioning-181717?style=flat&logo=github&logoColor=white)](https://github.com/)

</div>

---

## 📌 À propos

**SysReseauDevSecOps-lab** est mon laboratoire technique consacré à l'administration système, aux réseaux, à la cybersécurité, au DevOps et au Cloud.

Ce dépôt regroupe mes travaux pratiques, configurations, scripts, architectures et projets techniques réalisés dans des environnements virtualisés.

L'objectif est de mettre en pratique les concepts étudiés à travers des environnements reproductibles, documentés et proches de cas d'utilisation réels.

---

## 🗂️ Organisation du laboratoire

Le dépôt est structuré autour de quatre piliers techniques :

| Domaine | Contenu | Statut |
|---|---|:---:|
| 🐧 **[01-systeme-linux](./01-systeme-linux/)** | Administration, services, logs, Bash, SSH et sécurité Linux | ✅ |
| 🌐 **[02-reseau-securite](./02-reseau-securite/)** | Diagnostic, firewall, DNS/DHCP, VPN, VLAN et pfSense | ✅ |
| 🪟 **[03-systeme-windows-ad](./03-systeme-windows-ad/)** | Windows Server, AD DS, utilisateurs, groupes et GPO | 🔄 |
| 🚀 **[04-devops-cloud](./04-devops-cloud/)** | Docker, Ansible, Terraform, Azure, CI/CD et observabilité | 🔄 |

> Chaque dossier possède sa propre documentation détaillée avec les configurations, commandes, tests et projets associés.

---

## 📂 Structure du dépôt

```text
SysReseauDevSecOps-lab/
│
├── 01-systeme-linux/       ← Administration système, logs & Bash
│
├── 02-reseau-securite/     ← Diagnostic, pare-feu, DNS/DHCP, VPN & pfSense
│
├── 03-systeme-windows-ad/  ← Active Directory, GPO & services Windows
│
├── 04-devops-cloud/        ← Docker, Ansible, Terraform, Azure & CI/CD
│
└── README.md               ← Vitrine principale
```

---

## 🛠️ Environnement technique

```text
OS & Systèmes          Debian Server 22.04 • Windows Server 2022

Virtualisation         VMware Workstation • Proxmox VE

Réseau & Sécurité      iptables • UFW • pfSense • WireGuard
                       Bind9 • DHCP • tcpdump • nmap

Annuaire & Identités   Active Directory DS, utilisateurs/groupes, GPO

Services Windows       DNS, DHCP 

DevOps                 Docker • Docker Compose • Ansible
                       Terraform • Git • GitLab CI/CD

Cloud                  Microsoft Azure

Observabilité          Prometheus • Grafana • Node Exporter

Automatisation         Bash • Python
```

---

## 🔐 Démarche & Rigueur Technique

Chaque projet et laboratoire suit une méthodologie d'ingénierie rigoureuse :

$$\text{Conception} \longrightarrow \text{Déploiement} \longrightarrow \text{Configuration} \longrightarrow \text{Sécurisation} \longrightarrow \text{Validation} \longrightarrow \text{Documentation}$$

---

### Principes directeurs appliqués dans chaque Lab :
- **Segmentation & Isolation :** Cloisonnement des réseaux (VLANs, DMZ) et des services (conteneurs, règles pare-feu).
- **Moindre privilège (Least Privilege) :** Restriction des accès (sudoers dédiés, clés SSH chiffrées, comptes de service dédiés).
- **Automatisation :** Suppression des tâches répétitives via des scripts Bash.
- **Traçabilité & Observabilité :** Journalisation centralisée (`journald`, `rsyslog`), suivi d'audit (`auditd`) et tableaux de bord.
- **Validation & Recette :** Recette systématique des configurations (tests de montée en charge, scans Nmap, captures `tcpdump`).
- **Documentation exhaustive :** Rédaction de bilans techniques et de guides de reproduction pour chaque infrastructure.

---

## 🎯 Objectif du dépôt

Ce laboratoire évolue progressivement avec l'acquisition et la mise en pratique de nouvelles compétences dans les domaines :

`System Administration` • `Networking` • `Cybersecurity` • `DevOps` • `Cloud` • `Automation`

L'objectif est de construire un environnement technique cohérent permettant de **concevoir, configurer, sécuriser, automatiser et documenter des infrastructures informatiques**.

---

<div align="center">

### Build • Secure • Automate • Monitor

**SysReseauDevSecOps-lab**

</div>