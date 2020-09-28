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
trap '>&2 echo "error: line $LINENO, status $?: $BASH_COMMAND"' ERR

#------------------------------------------------------------------------------

export VPS_CONFIG=${1:-${VPS_CONFIG:-'/etc/vps/vps.conf'}}
vpslib=$(dirname "$(readlink -f "$0")")/vpslib
if [[ -r "$vpslib" ]]; then source "$vpslib"; else
	echo "VPS Setup library not found: $(readlink -f "$vpslib")" >&2
	echo "Usage: ${0##*/} [CONFIG_FILE]" >&2
	exit 1
fi

VPS_DIR=${VPS_DIR:-$(dirname "$(readlink -f "$0")")}
VPS_VERBOSE=${VPS_VERBOSE:-1}
VPS_INTERACTIVE=${VPS_INTERACTIVE:-1}

#------------------------------------------------------------------------------

execdir=/usr/local/bin
bashcompdir=$(pkg-config bash-completion --variable=completionsdir 2>/dev/null ||
	echo '/usr/share/bash-completion/completions')  # no /usr/local :-(

#------------------------------------------------------------------------------

show_settings() {
	if ! ((VPS_VERBOSE)); then return; fi
	set | grep '^VPS_' | sort || :
}

#------------------------------------------------------------------------------

require_root

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
