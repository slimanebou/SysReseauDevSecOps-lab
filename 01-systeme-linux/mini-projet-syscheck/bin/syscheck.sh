#!/usr/bin/env bash
#
# syscheck.sh - Vérifie l'espace disque, la charge CPU, la mémoire et les services critiques.
# Codes de sortie : 0 = OK | 1 = alerte(s) | 2 = erreur d'usage | 3 = erreur interne

set -Eeuo pipefail
umask 027

# ------------------------------------------------------------------- Constantes
readonly VERSION="1.0.0"
readonly SCRIPT_NAME=${0##*/}
readonly EX_OK=0 EX_ALERT=1 EX_USAGE=2 EX_SOFTWARE=3

# ---------------------------------------- Paramètres (modifiables via options)
LOG_FILE=${SYSCHECK_LOG:-/var/log/syscheck.log}
LOCK_FILE=${SYSCHECK_LOCK:-/run/lock/syscheck.lock}
DISK_THRESHOLD=80        # alerte si utilisation disque > 80 %
LOAD_THRESHOLD=100       # alerte si load 1 min / cœurs > 100 %
MEM_MIN_FREE=20          # alerte si mémoire disponible < 20 %
QUIET=false
LOG_READY=false
SERVICES=()
ALERTS=()

# --------------------------------------------------------------- Journalisation
log() {
    local level=$1; shift
    local line
    line="$(date '+%F %T') [$level] $*"

    if [[ $level == ERROR ]]; then
        printf '%s\n' "$line" >&2
    elif [[ $QUIET != true || $level != INFO ]]; then
        printf '%s\n' "$line"
    fi

    if [[ $LOG_READY == true ]]; then
        printf '%s\n' "$line" >> "$LOG_FILE"
    fi
}

die() {
    local code=$1; shift
    log ERROR "$*"
    exit "$code"
}

trap 'log ERROR "Échec ligne $LINENO : $BASH_COMMAND (code $?)"' ERR

usage() {
    cat <<EOF
Usage : $SCRIPT_NAME [options]

Vérifie l'espace disque, la charge CPU, la mémoire et l'état des services systemd.
Les résultats sont horodatés et consignés dans $LOG_FILE.

Options :
  -d, --disk SEUIL      alerte si un disque dépasse SEUIL %          (défaut : $DISK_THRESHOLD)
  -l, --load SEUIL      alerte si load 1 min / cœurs dépasse SEUIL % (défaut : $LOAD_THRESHOLD)
  -m, --mem SEUIL       alerte si la mémoire disponible < SEUIL %    (défaut : $MEM_MIN_FREE)
  -s, --service NOM     service à vérifier (répétable)               (défaut : ssh cron)
  -q, --quiet           n'affiche que les alertes et erreurs sur stdout
  -h, --help            affiche cette aide
  -V, --version         affiche la version

Variables d'environnement : SYSCHECK_LOG, SYSCHECK_LOCK
Codes de sortie : 0 OK, 1 alerte(s), 2 erreur d'usage, 3 erreur interne.
EOF
}

# --------------------------------------------------------- Analyse des arguments
need_value() {
    (( $# >= 2 )) || die "$EX_USAGE" "L'option $1 attend une valeur"
}

validate_int() {
    local name=$1 value=$2 min=$3 max=$4
    if [[ ! $value =~ ^[0-9]{1,4}$ ]] || (( 10#$value < min || 10#$value > max )); then
        die "$EX_USAGE" "Valeur invalide pour $name : '$value' (entier entre $min et $max)"
    fi
}

parse_args() {
    while (( $# > 0 )); do
        case $1 in
            -d|--disk)    need_value "$@"; DISK_THRESHOLD=$2; shift 2 ;;
            -l|--load)    need_value "$@"; LOAD_THRESHOLD=$2; shift 2 ;;
            -m|--mem)     need_value "$@"; MEM_MIN_FREE=$2;   shift 2 ;;
            -s|--service) need_value "$@"; SERVICES+=("$2");  shift 2 ;;
            -q|--quiet)   QUIET=true; shift ;;
            -h|--help)    usage; exit "$EX_OK" ;;
            -V|--version) echo "$SCRIPT_NAME $VERSION"; exit "$EX_OK" ;;
            -*)           usage >&2; die "$EX_USAGE" "Option inconnue : $1" ;;
            *)            die "$EX_USAGE" "Argument inattendu : $1" ;;
        esac
    done

    validate_int "disque"  "$DISK_THRESHOLD" 1 100
    validate_int "charge"  "$LOAD_THRESHOLD" 1 1000
    validate_int "mémoire" "$MEM_MIN_FREE"   1 99

    DISK_THRESHOLD=$((10#$DISK_THRESHOLD))
    LOAD_THRESHOLD=$((10#$LOAD_THRESHOLD))
    MEM_MIN_FREE=$((10#$MEM_MIN_FREE))

    if (( ${#SERVICES[@]} == 0 )); then
        SERVICES=(ssh cron)
    fi

    local svc re='^[A-Za-z0-9@._-]+$'
    for svc in "${SERVICES[@]}"; do
        [[ $svc =~ $re ]] || die "$EX_USAGE" "Nom de service invalide : '$svc'"
    done
}

# ------------------------------------------------------------------ Garde-fous
check_dependencies() {
    local cmd
    for cmd in awk df date flock hostname nproc systemctl; do
        command -v "$cmd" >/dev/null 2>&1 \
            || die "$EX_SOFTWARE" "Commande requise introuvable : $cmd"
    done
    [[ -r /proc/loadavg && -r /proc/meminfo ]] \
        || die "$EX_SOFTWARE" "/proc/loadavg ou /proc/meminfo est illisible"
}

setup_log() {
    touch "$LOG_FILE" 2>/dev/null \
        || die "$EX_USAGE" "Fichier de log non inscriptible : $LOG_FILE (lancer en root ?)"
    LOG_READY=true
}

acquire_lock() {
    exec 9>"$LOCK_FILE"
    flock -n 9 || die "$EX_SOFTWARE" "Une autre instance de syscheck est déjà en cours d'exécution"
}

# ----------------------------------------------------------------- Évaluations
evaluate_max() {
    local label=$1 value=$2 threshold=$3
    if (( value > threshold )); then
        log WARN "$label : ${value}% (seuil ${threshold}%) ALERTE"
        ALERTS+=("${label// /_}=${value}%")
    else
        log INFO "$label : ${value}% (seuil ${threshold}%) OK"
    fi
}

evaluate_min() {
    local label=$1 value=$2 threshold=$3
    if (( value < threshold )); then
        log WARN "$label : ${value}% (minimum ${threshold}%) ALERTE"
        ALERTS+=("${label// /_}=${value}%")
    else
        log INFO "$label : ${value}% (minimum ${threshold}%) OK"
    fi
}

# --------------------------------------------------------------- Vérifications
check_disks() {
    local pct mount
    while read -r pct mount; do
        evaluate_max "Disque $mount" "$pct" "$DISK_THRESHOLD"
    done < <(df -P -x tmpfs -x devtmpfs -x squashfs -x overlay \
             | awk 'NR > 1 && $5 ~ /^[0-9]+%$/ { gsub(/%/, "", $5); print $5, $6 }')
}

check_load() {
    local load1 cores pct
    read -r load1 _ < /proc/loadavg
    cores=$(nproc)
    pct=$(awk -v l="$load1" -v c="$cores" 'BEGIN { printf "%d", l * 100 / c }')
    evaluate_max "Charge CPU (load ${load1}, ${cores} cœur(s))" "$pct" "$LOAD_THRESHOLD"
}

check_memory() {
    local free_pct
    free_pct=$(awk '/^MemTotal:/ { t = $2 } /^MemAvailable:/ { a = $2 }
                    END { if (t > 0) printf "%d", a * 100 / t; else print 0 }' /proc/meminfo)
    evaluate_min "Mémoire disponible" "$free_pct" "$MEM_MIN_FREE"
}

check_service() {
    local svc=$1
    if systemctl is-active --quiet "$svc"; then
        log INFO "Service $svc : actif OK"
    else
        log WARN "Service $svc : INACTIF ALERTE"
        ALERTS+=("service:$svc")
    fi
}

# ------------------------------------------------------------------------ Main
main() {
    parse_args "$@"
    check_dependencies
    setup_log
    acquire_lock

    log INFO "Début de la vérification sur $(hostname)"

    check_disks
    check_load
    check_memory

    local svc
    for svc in "${SERVICES[@]}"; do
        check_service "$svc"
    done

    if (( ${#ALERTS[@]} == 0 )); then
        log INFO "Résultat : STATUS=OK"
        exit "$EX_OK"
    fi
    log WARN "Résultat : STATUS=ALERT (${#ALERTS[@]}) : ${ALERTS[*]}"
    exit "$EX_ALERT"
}

main "$@"