# SECURITY.md — Hardening SSH

## Configuration SSH (/etc/ssh/sshd_config)

| Directive            | Valeur  | Raison                                        |
|---|---|---|
| Port                 | 2222    | Réduire l'exposition aux scans automatisés    |
| PermitRootLogin      | no      | Forcer l'usage d'un compte dédié + sudo       |
| PasswordAuthentication | no    | Authentification par clé uniquement           |
| PubkeyAuthentication | yes     | Clé ED25519 obligatoire                       |
| AllowUsers           | devops  | Liste blanche d'utilisateurs autorisés        |
| MaxAuthTries         | 3       | Limiter les tentatives par connexion          |
| LoginGraceTime       | 20      | Réduire la fenêtre d'authentification         |
| X11Forwarding        | no      | Désactiver les fonctions inutiles             |

## Type de clé

ED25519 (Curve25519) — plus sécurisé et plus rapide que RSA 2048.

## fail2ban

| Paramètre | Valeur                   |
|---|---|
| maxretry  | 3 tentatives             |
| findtime  | 600 secondes (10 min)    |
| bantime   | 3600 secondes (1 heure)  |
| Port      | 2222                     |
| Log       | /var/log/auth.log        |

## Checklist de validation

- [x] Connexion par clé ED25519 fonctionnelle
- [x] Connexion par mot de passe refusée
- [x] Connexion root directe refusée
- [x] fail2ban actif — jail sshd enabled
- [x] Port changé à 2222
- [x] Ban déclenché après 3 tentatives échouées