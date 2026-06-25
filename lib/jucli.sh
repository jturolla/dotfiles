#!/usr/bin/env bash
# jucli shared library — ukiyo-datacenter homelab CLI
set -euo pipefail

JUCLI_LAUNCHD_LABEL="com.ukiyo.datacenter"
JUCLI_GITHUB_ORG="ruabage"

jucli_root() {
  if [[ -n "${UKIYO_DATACENTER:-}" ]]; then
    printf '%s' "$UKIYO_DATACENTER"
  else
    printf '%s' "${HOME}/dev/ukiyo-datacenter"
  fi
}

jucli_docker_env() {
  export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:${HOME}/.orbstack/bin:${PATH}"
  export DOCKER_HOST="${DOCKER_HOST:-unix://${HOME}/.colima/default/docker.sock}"
}

jucli_lower() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]'
}

jucli_paint() {
  local status="$1" key
  key="$(jucli_lower "$status")"
  if [[ -t 1 && -z "${NO_COLOR:-}${JUCLI_NO_COLOR:-}" ]]; then
    case "$key" in
      up|idle) printf '\033[32m%s\033[0m' "$status" ;;
      busy|starting) printf '\033[33m%s\033[0m' "$status" ;;
      stopped|missing|down|not\ running) printf '\033[31m%s\033[0m' "$status" ;;
      *) printf '%s' "$status" ;;
    esac
  else
    printf '%s' "$status"
  fi
}

jucli_row() {
  local painted
  painted="$(jucli_paint "$2")"
  printf '  %-26s %-10b %s\n' "$1" "$painted" "${3:-}"
}

jucli_section() {
  echo
  echo "$1"
  printf '%*s\n' "${#1}" '' | tr ' ' '─'
}

jucli_docker_ok() {
  docker info &>/dev/null
}

jucli_container_state() {
  docker inspect -f '{{.State.Status}}' "$1" 2>/dev/null || echo "missing"
}

jucli_container_health() {
  case "$(jucli_container_state "$1")" in
    running) echo "up" ;;
    exited) echo "stopped" ;;
    missing) echo "missing" ;;
    *) jucli_container_state "$1" ;;
  esac
}

jucli_container_uptime() {
  docker inspect -f '{{.State.StartedAt}}' "$1" 2>/dev/null | cut -c1-16 | tr T ' ' || true
}

jucli_http_ok() {
  curl -fsS -o /dev/null -m 3 "$1" 2>/dev/null
}

jucli_runner_log_state() {
  local text="$1"
  if grep -q "Running job:" <<< "$text"; then
    printf 'busy|%s' "$(grep "Running job:" <<< "$text" | tail -1 | sed 's/.*Running job: //')"
  elif grep -q "Listening for Jobs" <<< "$text"; then
    printf 'idle|'
  elif grep -q "Connected to GitHub" <<< "$text"; then
    printf 'starting|connected'
  else
    printf 'starting|'
  fi
}

jucli_macos_runner_name() {
  local root="$1" file="${root}/data/github-runner/.runner"
  [[ -f "$file" ]] || return 1
  sed -n 's/.*"agentName"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$file" | head -1
}

jucli_macos_runner_status() {
  local root="$1" name="" state detail=""
  name="$(jucli_macos_runner_name "$root" 2>/dev/null || true)"
  local listener="${root}/data/github-runner/bin/Runner.Listener"
  if [[ -x "$listener" ]] && pgrep -f "$listener" >/dev/null 2>&1; then
    local log=""
    [[ -f /tmp/ukiyo-github-runner.log ]] && log="$(tail -40 /tmp/ukiyo-github-runner.log 2>/dev/null || true)"
    IFS='|' read -r state detail <<< "$(jucli_runner_log_state "$log")"
    case "$state" in
      idle) detail="${name:-macos}" ;;
      busy) detail="${name:-macos} — ${detail}" ;;
      *) detail="${name:-macos}" ;;
    esac
  elif [[ -n "$name" ]]; then
    state="stopped"
    detail="$name"
  else
    state="missing"
    detail="not configured"
  fi
  jucli_row "macOS" "$state" "$detail"
}

jucli_linux_runner_status() {
  local i container name state work job detail uptime
  for i in 1 2 3 4; do
    container="gh-linux-${i}"
    name="ukiyo-linux-${i}"
    case "$(jucli_container_health "$container")" in
      up)
        IFS='|' read -r work job <<< "$(jucli_runner_log_state "$(docker logs --tail 40 "$container" 2>&1)")"
        uptime="$(jucli_container_uptime "$container")"
        case "$work" in
          idle) state="idle"; detail="since ${uptime:-?}" ;;
          busy) state="busy"; detail="${job} (since ${uptime:-?})" ;;
          *) state="starting"; detail="$container" ;;
        esac
        ;;
      stopped) state="stopped"; detail="$name" ;;
      *) state="missing"; detail="$name" ;;
    esac
    jucli_row "linux-${i}" "$state" "$detail"
  done
}

jucli_launchd_status() {
  local plist="${HOME}/Library/LaunchAgents/${JUCLI_LAUNCHD_LABEL}.plist"
  if [[ ! -f "$plist" ]]; then
    jucli_row "launchd" "missing" "./scripts/install-launchd.sh"
    return
  fi
  local state="unknown"
  state="$(launchctl print "gui/$(id -u)/${JUCLI_LAUNCHD_LABEL}" 2>/dev/null | awk -F' = ' '/^[[:space:]]*state / {print $2; exit}' || true)"
  jucli_row "launchd" "${state:-unknown}" "$JUCLI_LAUNCHD_LABEL"
}

jucli_compose() {
  local root="$1"
  shift
  (cd "$root" && docker compose "$@" 2>/dev/null) || (cd "$root" && docker-compose "$@")
}

jucli_resolve_services() {
  local name="${1:-all}" key
  key="$(jucli_lower "$name")"
  key="${key//_/-}"
  case "$key" in
    all|everything)
      printf '%s\n' ha kb linux-1 linux-2 linux-3 linux-4 macos-runner
      ;;
    runners|github-runners|github|runners-linux|linux-runners|linux)
      printf '%s\n' linux-1 linux-2 linux-3 linux-4 macos-runner
      ;;
    ha|homeassistant) echo ha ;;
    kb|knowledgebase) echo kb ;;
    linux-[1-4]|runner-linux-[1-4])
      echo "${key/runner-/}" ;;
    macos-runner|runner-macos) echo macos-runner ;;
    *)
      echo "jucli: unknown service: $name" >&2
      return 1
      ;;
  esac
}

jucli_compose_service() {
  case "$1" in
    ha) echo homeassistant ;;
    kb) echo knowledgebase ;;
    linux-1) echo github-runner-linux-1 ;;
    linux-2) echo github-runner-linux-2 ;;
    linux-3) echo github-runner-linux-3 ;;
    linux-4) echo github-runner-linux-4 ;;
    *) echo "" ;;
  esac
}

jucli_cmd_status() {
  local root
  root="$(jucli_root)"
  jucli_docker_env

  echo "ukiyo-datacenter  ${root}"
  jucli_section "Host"
  if jucli_docker_ok; then
    jucli_row "docker" "up" "${DOCKER_HOST#unix://}"
  else
    jucli_row "docker" "down" "start Colima or OrbStack"
  fi
  jucli_launchd_status

  jucli_section "Services"
  if jucli_docker_ok; then
    local ha kb ha_u kb_u detail
    ha="$(jucli_container_health ha)"
    kb="$(jucli_container_health kb)"
    ha_u="$(jucli_container_uptime ha)"
    kb_u="$(jucli_container_uptime kb)"
    detail="http://localhost:8123"
    [[ -n "$ha_u" ]] && detail+="  (since ${ha_u})"
    if [[ "$ha" == "up" ]] && jucli_http_ok "http://localhost:8123"; then ha="up"; fi
    jucli_row "Home Assistant" "$ha" "$detail"
    detail="http://localhost:3000"
    [[ -n "$kb_u" ]] && detail+="  (since ${kb_u})"
    if [[ "$kb" == "up" ]] && jucli_http_ok "http://localhost:3000"; then kb="up"; fi
    jucli_row "Knowledge base" "$kb" "$detail"
  else
    echo "  Start Docker to inspect containers."
  fi

  jucli_section "GitHub Actions runners"
  if jucli_docker_ok; then
    jucli_linux_runner_status
  else
    echo "  Linux runners need Docker."
  fi
  jucli_macos_runner_status "$root"

  if jucli_docker_ok; then
    jucli_section "Summary"
    local idle=0 busy=0 down=0 i st
    for i in 1 2 3 4; do
      IFS='|' read -r st _ <<< "$(jucli_runner_log_state "$(docker logs --tail 5 "gh-linux-${i}" 2>&1 || true)")"
      case "$(jucli_container_health "gh-linux-${i}")" in
        up)
          case "$st" in idle) idle=$((idle + 1)) ;; busy) busy=$((busy + 1)) ;; esac
          ;;
        *) down=$((down + 1)) ;;
      esac
    done
    local mac="missing"
    if jucli_macos_runner_name "$root" &>/dev/null; then
      if pgrep -f "${root}/data/github-runner/bin/Runner.Listener" >/dev/null 2>&1; then
        mac="up"
      else
        mac="stopped"
      fi
    fi
    echo "  Linux: ${idle} idle, ${busy} busy, ${down} down  |  macOS: ${mac}"
  fi
  echo
}

jucli_cmd_start() {
  local root svc compose
  root="$(jucli_root)"
  jucli_docker_env
  while IFS= read -r svc; do
    [[ -z "$svc" ]] && continue
    if [[ "$svc" == "macos-runner" ]]; then
      echo "Starting macOS GitHub runner …"
      "${root}/scripts/start-github-runner.sh"
    else
      compose="$(jucli_compose_service "$svc")"
      [[ -n "$compose" ]] || continue
      echo "Starting ${svc} …"
      jucli_compose "$root" up -d "$compose"
    fi
  done < <(jucli_resolve_services "${*:-all}" | sort -u)
}

jucli_cmd_stop() {
  local root svc compose listener
  root="$(jucli_root)"
  jucli_docker_env
  while IFS= read -r svc; do
    [[ -z "$svc" ]] && continue
    if [[ "$svc" == "macos-runner" ]]; then
      listener="${root}/data/github-runner/bin/Runner.Listener"
      echo "Stopping macOS GitHub runner …"
      pkill -f "$listener" 2>/dev/null || true
    else
      compose="$(jucli_compose_service "$svc")"
      [[ -n "$compose" ]] || continue
      echo "Stopping ${svc} …"
      jucli_compose "$root" stop "$compose"
    fi
  done < <(jucli_resolve_services "${*:-all}" | sort -u)
}

jucli_cmd_restart() {
  jucli_cmd_stop "$@"
  jucli_cmd_start "$@"
}

jucli_cmd_logs() {
  local follow="" tail_n="50" svc=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -f|--follow) follow="-f"; shift ;;
      -n|--tail) tail_n="$2"; shift 2 ;;
      *) svc="$1"; shift ;;
    esac
  done
  svc="$(jucli_lower "${svc:?service required}")"
  jucli_docker_env
  if [[ "$svc" == "macos-runner" || "$svc" == "runner-macos" ]]; then
    if [[ "$follow" == "-f" ]]; then
      tail -f /tmp/ukiyo-github-runner.log
    else
      tail -n "$tail_n" /tmp/ukiyo-github-runner.log
    fi
    return
  fi
  local container=""
  case "$svc" in
    ha|homeassistant) container=ha ;;
    kb|knowledgebase) container=kb ;;
    linux-1|runner-linux-1) container=gh-linux-1 ;;
    linux-2|runner-linux-2) container=gh-linux-2 ;;
    linux-3|runner-linux-3) container=gh-linux-3 ;;
    linux-4|runner-linux-4) container=gh-linux-4 ;;
    *) echo "jucli: unknown service for logs: $svc" >&2; return 1 ;;
  esac
  if [[ "$follow" == "-f" ]]; then
    docker logs -f "$container"
  else
    docker logs --tail "$tail_n" "$container"
  fi
}

jucli_cmd_runners() {
  local root
  root="$(jucli_root)"
  jucli_docker_env

  if command -v gh &>/dev/null; then
    jucli_section "GitHub org ${JUCLI_GITHUB_ORG} (API)"
    if gh api "orgs/${JUCLI_GITHUB_ORG}/actions/runners" --jq '.runners[] | "\(.name)\t\(.status)\t\(.busy)\t\([.labels[].name] | join(","))"' 2>/dev/null; then
      :
    else
      echo "  (gh API unavailable — need admin:org scope)"
    fi
  fi

  jucli_section "Local"
  if jucli_docker_ok; then
    jucli_linux_runner_status
  fi
  jucli_macos_runner_status "$root"
  echo
}

jucli_cmd_urls() {
  jucli_section "URLs"
  echo "  Home Assistant       http://localhost:8123"
  echo "  Knowledge base       http://localhost:3000"
  echo
}

jucli_cmd_doctor() {
  local root issues=0
  root="$(jucli_root)"
  jucli_docker_env
  echo "jucli doctor"
  if [[ -f "${root}/docker-compose.yml" ]]; then
    echo "  ✓ datacenter root: ${root}"
  else
    echo "  ✗ missing docker-compose.yml in ${root}"
    issues=$((issues + 1))
  fi
  if jucli_docker_ok; then
    echo "  ✓ docker engine reachable"
  else
    echo "  ✗ docker engine not reachable"
    issues=$((issues + 1))
  fi
  local i
  for i in 1 2 3 4; do
    if [[ "$(jucli_container_health "gh-linux-${i}")" == "missing" ]]; then
      echo "  ✗ ukiyo-linux-${i} missing — docker compose up github-runner-linux-${i}"
      issues=$((issues + 1))
    fi
  done
  if jucli_macos_runner_name "$root" &>/dev/null; then
    echo "  ✓ macOS runner registered as $(jucli_macos_runner_name "$root")"
  else
    echo "  ✗ macOS runner not registered"
    issues=$((issues + 1))
  fi
  [[ -f "${HOME}/Library/LaunchAgents/${JUCLI_LAUNCHD_LABEL}.plist" ]] && echo "  ✓ launchd installed" || echo "  ○ launchd not installed (optional)"
  echo
  return "$issues"
}

jucli_usage() {
  cat <<EOF
jucli — ukiyo-datacenter homelab CLI

Usage:
  jucli [status]              Dashboard (default)
  jucli start [services…]     Start ha, kb, linux-1..4, macos-runner, runners, all
  jucli stop [services…]      Stop services
  jucli restart [services…]   Restart services
  jucli logs <service> [-f]   Tail logs (ha, kb, linux-N, macos-runner)
  jucli runners               Runner details (+ gh API if available)
  jucli urls                  Service URLs
  jucli doctor                Validate setup

Environment:
  UKIYO_DATACENTER            Path to ukiyo-datacenter (default: ~/dev/ukiyo-datacenter)
  DOCKER_HOST                 Docker socket (default: Colima)

EOF
}
