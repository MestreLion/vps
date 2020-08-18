#!/bin/bash
#
# Installer for VPS Setup
#
# Copyright (C) 2020 Rodrigo Silva (MestreLion) <linux@rodrigosilva.com>
# License: GPLv3 or later, at your choice. See <http://www.gnu.org/licenses/gpl>
#
# Tasks performed:
# - If a config file is not provided, create and install one from template
# - Install the bash-completion file
# - Install the executable(s)
#
###############################################################################

set -Eeuo pipefail  # exit on any error
trap '>&2 echo "error in line $LINENO, code $?, command: $BASH_COMMAND"' ERR

export VPS_CONFIG=${1:-${VPS_CONFIG:-'/etc/vps/vps.conf'}}
if [[ -r "$VPS_CONFIG" ]]; then source "$VPS_CONFIG"; fi

###############################################################################

VPS_DIR=${VPS_DIR:-$(dirname "$(readlink -f "$0")")}
VPS_VERBOSE=${VPS_VERBOSE:-1}
VPS_INTERACTIVE=${VPS_INTERACTIVE:-1}

execdir=/usr/local/bin
bashcompdir=/usr/share/bash-completion/completions  # no /usr/local :-(

confirm() {
	# Non-empty garbage will always evaluate to and behave as NO
	local message=${1:-"Confirm?"}
	local default=NO

	if ((VPS_INTERACTIVE)); then
		read -p "$message (y/n, default $default): " resp
		case "${resp:-$default}" in [Yy]*);; *) return 1;; esac
	fi
}
show_settings() {
	if ! ((VPS_VERBOSE)); then return; fi
	set | grep '^VPS_' | sort || :
}


if [[ ! -f "$VPS_CONFIG" ]]; then
	install --mode 600 -DT -- "$VPS_DIR"/vps.template.conf "$VPS_CONFIG"
fi

if ((VPS_INTERACTIVE)); then
	while true; do
		editor "$VPS_CONFIG"
		source "$VPS_CONFIG"
		show_settings
		if confirm "Proceed with those settings?"; then break; fi
	done
else
	source "$VPS_CONFIG"
fi

install -- "$VPS_DIR"/vps-setup "$execdir"

if [[ -d "$bashcompdir" ]]; then
	install -T -- "$VPS_DIR"/vps.bash-completion "$bashcompdir"/vps-setup
fi
