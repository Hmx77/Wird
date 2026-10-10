#!/usr/bin/env bash
# Disposable GitHub-hosted runners only. Fail closed if rules cannot be installed.
set -euo pipefail
case "$(uname -s)" in
  Linux)
    for cidr in 169.254.0.0/16 100.100.100.200/32; do
      sudo iptables -I OUTPUT 1 -d "$cidr" -j REJECT
      sudo iptables -C OUTPUT -d "$cidr" -j REJECT
    done
    for cidr in fe80::/10 fd00::/8; do
      sudo ip6tables -I OUTPUT 1 -d "$cidr" -j REJECT
      sudo ip6tables -C OUTPUT -d "$cidr" -j REJECT
    done
    ;;
  Darwin)
    # Append a first-match block to the runner's existing PF rules.
    rules="${RUNNER_TEMP:?}/wird-pf.conf"
    { cat /etc/pf.conf; printf '\nblock drop out quick to { 169.254.0.0/16, 100.100.100.200, fe80::/10, fd00::/8 }\n'; } > "$rules"
    sudo pfctl -nf "$rules"
    sudo pfctl -f "$rules"
    sudo pfctl -E
    ;;
  *) echo 'Unsupported runner: metadata firewall not installed.' >&2; exit 1;;
esac
