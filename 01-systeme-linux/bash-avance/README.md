# Bash avancé : scripts robustes

> **Phase 3 — Virtualisation & Services**
> Statut : ✅ Terminé

---

## Objectif

Écrire des scripts Bash de niveau production : fonctions réutilisables, gestion des arguments courts et longs, gestion d'erreurs avec `set -Eeuo pipefail` et `trap`, heredocs, tableaux associatifs et expressions régulières.

---

## Sommaire

- [1. Fonctions Bash](#1-fonctions-bash)
- [2. Gestion des arguments](#2-gestion-des-arguments)
- [3. Gestion d'erreurs](#3-gestion-derreurs)
- [4. Here documents](#4-here-documents)
- [5. Arrays et boucles avancées](#5-arrays-et-boucles-avancées)
- [6. Expressions régulières avec =~](#6-expressions-régulières-avec-)
- [7. Exercice — Script monitor.sh réécrit](#7-exercice--script-monitorsh-réécrit)
- [Commandes clés apprises](#commandes-clés-apprises)
- [Difficultés rencontrées & solutions](#difficultés-rencontrées--solutions)

---

## 1. Fonctions Bash

```bash
saluer() {
    local nom=${1:-inconnu}      # Utiliser 'local' pour éviter d'impacter le shell global
    echo "Bonjour, $nom"
}
```

| Élément | Rôle |
|---|---|
| `local` | Déclare une variable **locale** à la fonction (ne pollue pas le shell global) |
| `${1:-inconnu}` | Valeur par défaut si l'argument `$1` est vide ou non défini |
| `return N` | Renvoie un **statut** de succès/échec (0 à 255, 0 = succès) |
| `echo` / `printf` | Retourne une **valeur** capturable via `$(...)` |

**Exemple d'utilisation :**

```bash
resultat=$(saluer "Alice")      # Capture la sortie
if saluer "Alice" >/dev/null; then   # Teste le code de retour
    echo "OK"
fi
```

> **💡 Bonne pratique :** une fonction renvoie soit un **statut** (`return`), soit une **valeur** (`echo`) — éviter de mélanger les deux dans le même flux.

---

## 2. Gestion des arguments

Mode `while/case` pour options courtes et longues :

```bash
while (( $# > 0 )); do
    case $1 in
        -c|--cpu)     CPU_THRESHOLD=$2; shift 2 ;;
        -l|--log)     LOG_FILE=$2; shift 2 ;;
        -q|--quiet)   QUIET=true; shift ;;
        -h|--help)    usage; exit 0 ;;
        --)           shift; break ;;
        *)            echo "Option invalide: $1" >&2; exit 2 ;;
    esac
done
```

| Élément | Rôle |
|---|---|
| `$#` | Nombre d'arguments restants |
| `$1` | Premier argument |
| `shift N` | Décale les arguments de N positions (les consomme) |
| `shift 2` | Consomme l'option ET sa valeur (`-c 80`) |
| `--) shift; break` | Fin des options : tout ce qui suit est un argument positionnel |
| `*) ... exit 2` | Option inconnue → erreur explicite (code 2 = usage) |
| `>&2` | Redirige vers stderr (canal d'erreur) |

**Codes de sortie conventionnels :**

| Code | Signification |
|---|---|
| `0` | Succès |
| `1` | Erreur générale |
| `2` | Erreur d'utilisation (mauvais arguments) |
| `3` | Instance déjà en cours (verrou) |
| `127` | Commande introuvable |

---

## 3. Gestion d'erreurs

### Le mode strict : `set -Eeuo pipefail`

| Option | Effet |
|---|---|
| `-e` | Arrêt du script au premier échec de commande |
| `-u` | Erreur si une variable non définie est appelée |
| `-o pipefail` | Capture l'échec intermédiaire dans un pipeline (`cmd1 \| cmd2`) |
| `-E` | Héritage du `trap ERR` dans les sous-fonctions |

### Piégeage d'erreurs et nettoyage (trap)

```bash
tmp=$(mktemp -d)
cleanup() { rm -rf "$tmp"; }
trap cleanup EXIT
trap 'echo "Erreur ligne $LINENO" >&2' ERR
```

| Signal | Déclenchement |
|---|---|
| `EXIT` | À la fin du script (succès ou échec) — idéal pour le nettoyage |
| `ERR` | Dès qu'une commande échoue (avec `set -e`) |
| `INT` | Interruption (Ctrl+C) |
| `TERM` | Demande d'arrêt (kill) |

**Exemple de nettoyage complet :**

```bash
cleanup() {
    rm -rf "$tmp"
    echo "Nettoyage effectué" >&2
}
trap cleanup EXIT
trap 'echo "Interrompu par l'utilisateur" >&2; exit 130' INT
```

> **💡 Astuce :** `mktemp -d` crée un dossier temporaire unique et sûr, toujours nettoyé par le `trap EXIT`.

---

## 4. Here documents

```bash
# Générer un fichier texte ou de service proprement
sudo tee /etc/systemd/system/monitor.service >/dev/null <<'EOF'
[Unit]
Description=Surveillance systeme
[Service]
ExecStart=/usr/local/bin/monitor.sh
EOF
```

| Élément | Rôle |
|---|---|
| `<<'EOF'` | Heredoc **quoté** : aucune expansion de variable (fichier écrit tel quel) |
| `<<EOF` | Heredoc **non quoté** : les variables `$var` sont **étendues** |
| `tee` | Écrit le contenu à la fois dans le fichier et sur stdout |
| `>/dev/null` | Masque la sortie de `tee` (le contenu n'est pas affiché) |

**Différence clé :**

```bash
cat <<EOF
Le répertoire courant est $PWD
EOF

cat <<'EOF'
Le répertoire courant est $PWD   # $PWD écrit littéralement
EOF
```

---

## 5. Arrays et boucles avancées

```bash
# Tableau associatif (Bash 4+)
declare -A services=( [ssh]=2222 [http]=80 [https]=443 )

for nom in "${!services[@]}"; do
    port=${services[$nom]}
    echo "Service $nom sur le port $port"
done

# Lecture de fichier ligne par ligne sans sous-shell
while IFS= read -r ligne; do
    echo "Ligne : $ligne"
done < <(grep "ERROR" /var/log/syslog)
```

| Élément | Rôle |
|---|---|
| `declare -A` | Déclare un **tableau associatif** (clé → valeur, Bash 4+) |
| `"${!services[@]}"` | Liste toutes les **clés** du tableau |
| `"${services[@]}"` | Liste toutes les **valeurs** |
| `"${services[$nom]}"` | Accède à la valeur d'une clé |
| `IFS= read -r` | Lecture brute sans interpréter les espaces et backslashes |
| `< <(...)` | Substitution de processus : alimente la boucle **sans sous-shell** (les variables modifiées dans la boucle persistent !) |

> **⚠️ Piège classique :** `done < fichier` ou un pipe `| while` créent un **sous-shell** : les variables modifiées dans la boucle sont perdues ensuite. `< <(...)` évite ce problème.

---

## 6. Expressions régulières avec =~

```bash
ip="192.168.100.20"
re='^([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})$'

if [[ $ip =~ $re ]]; then
    echo "IP valide. Premier octet : ${BASH_REMATCH[1]}"
fi
```

| Élément | Rôle |
|---|---|
| `[[ ... =~ ... ]]` | Test de correspondance regex (sans guillemets autour de la regex !) |
| `^...$` | Ancres : correspondance complète de la chaîne |
| `([0-9]{1,3})` | Groupe de capture : 1 à 3 chiffres |
| `${BASH_REMATCH[0]}` | Correspondance complète |
| `${BASH_REMATCH[1]}` | Premier groupe de capture |
| `${BASH_REMATCH[2]}` | Deuxième groupe de capture, etc. |

> **⚠️ Attention :** la regex ne doit **pas** être entre guillemets dans `[[ =~ ]]` : `[[ $ip =~ $re ]]` ✅ mais `[[ $ip =~ "$re" ]]` ❌ (devient une simple chaîne).

---

## 7. Exercice — Script monitor.sh réécrit

Exemple d'intégration complète des notions (mode strict, options, fonctions, trap et gestion d'erreurs) :

```bash
#!/usr/bin/env bash
set -Eeuo pipefail

readonly SCRIPT_NAME=${0##*/}
LOCK_DIR="/tmp/${SCRIPT_NAME}.lock"

cleanup() { rmdir "$LOCK_DIR" 2>/dev/null || true; }
trap cleanup EXIT

if ! mkdir "$LOCK_DIR" 2>/dev/null; then
    echo "Erreur : Une instance de $SCRIPT_NAME tourne deja." >&2
    exit 3
fi

# Logique du script
echo "Surveillance en cours..."
```

**Points clés du script :**

| Élément | Rôle |
|---|---|
| `#!/usr/bin/env bash` | Shebang portable (cherche bash dans le PATH) |
| `set -Eeuo pipefail` | Mode strict complet |
| `readonly SCRIPT_NAME=${0##*/}` | Nom du script (sans le chemin), en lecture seule |
| `LOCK_DIR` + `mkdir` | **Verrou d'instance** : `mkdir` est atomique, échoue si le dossier existe |
| `trap cleanup EXIT` | Supprime le verrou à la fin, même en cas d'erreur |
| `|| true` | Évite qu'un échec de `rmdir` déclenche `set -e` dans le trap |
| `exit 3` | Code dédié : instance déjà en cours |

### Validation du code avec shellcheck

```bash
shellcheck monitor.sh
```

`shellcheck` est un **linter statique** pour Bash : il détecte les erreurs de syntaxe, les pièges courants (`local x=$(cmd)`, guillemets manquants...) avant l'exécution. Indispensable en production.

---

## Commandes clés apprises

```bash
set -Eeuo pipefail; trap 'cleanup' EXIT; mktemp -d; declare -A; shellcheck script.sh
```

---

## Difficultés rencontrées & solutions

| Difficulté rencontrée | Solution appliquée |
|----------------------|--------------------|
| `local x=$(cmd)` masque le code d'erreur de `cmd` | Séparer la déclaration et l'affectation : `local x; x=$(cmd)` |
| L'incrémentation `(( i++ ))` stoppe le script sous `set -e` quand `i=0` | Utiliser l'expression arithmétique `i=$(( i + 1 ))` |

> **⚠️ Explication du second piège :** `(( i++ ))` renvoie le code 1 quand le résultat est 0 (l'ancienne valeur de `i`). Avec `set -e`, le script s'arrête. `i=$(( i + 1 ))` est une affectation pure, toujours réussie.

---

## Fiche mémo — Modèle de script Bash production

```bash
#!/usr/bin/env bash
set -Eeuo pipefail
readonly SCRIPT_NAME=${0##*/}

usage() { echo "Usage: $SCRIPT_NAME [-h] [-c seuil]" >&2; }

# --- Options ---
while (( $# > 0 )); do
    case $1 in
        -h|--help) usage; exit 0 ;;
        *) echo "Option invalide: $1" >&2; usage; exit 2 ;;
    esac
done

# --- Nettoyage ---
cleanup() { echo "Nettoyage..." >&2; }
trap cleanup EXIT

# --- Logique ---
main() {
    echo "OK"
}
main
```

### Checklist script de production

- [ ] Shebang `#!/usr/bin/env bash`
- [ ] `set -Eeuo pipefail` en première ligne
- [ ] Fonctions avec `local` et valeurs par défaut `${1:-...}`
- [ ] Gestion d'arguments `while/case` avec `usage()` et codes de sortie
- [ ] `trap cleanup EXIT` pour le nettoyage
- [ ] Heredoc quoté `<<'EOF'` pour les fichiers générés
- [ ] Tableaux associatifs `declare -A` pour les mappings
- [ ] Regex avec `[[ =~ ]]` et `${BASH_REMATCH[]}`
- [ ] Validation par `shellcheck` avant déploiement

---

*Document généré pour la Phase 3 — Module 5 : Bash avancé*
