#!/bin/bash
#
# Bootstrap VPS initial config
#
# Copyright (C) 2020 Rodrigo Silva (MestreLion) <linux@rodrigosilva.com>
# License: GPLv3 or later, at your choice. See <http://www.gnu.org/licenses/gpl>
#
# Tasks performed:
# - Install git from distribution repositories
# - Clone project git repository, by default from Github
# - Force-update the local git repository
# - Run the installer
#
# Instructions:
# - Choose "Ubuntu 20.04" image (/etc/ssh/sshd_config.d/ does not exist in 18.04)
# - Set root password (root SSH login will be disabled by default)
# - Log in via Cloud Provider VPS Web Console
# - Copy in terminal:
#
#  bash <(wget -qO - -- 'https://github.com/MestreLion/vps/raw/master/bootstrap.sh')
#
###############################################################################

set -Eeuo pipefail  # exit on any error
trap '>&2 echo "error: line $LINENO, status $?: $BASH_COMMAND"' ERR

#------------------------------------------------------------------------------

export VPS_CONFIG=${1:-${VPS_CONFIG:-"/etc/vps/vps.conf"}}
if [[ -r "$VPS_CONFIG" ]]; then source "$VPS_CONFIG"; fi

export VPS_REPO=${VPS_REPO:-"https://github.com/MestreLion/vps.git"}
export VPS_DIR=${VPS_DIR:-"/opt/vps"}

#------------------------------------------------------------------------------

for arg in "$@"; do if [[ "$arg" == '-h' || "$arg" == '--help' ]]; then
	echo "Bootstrap VPS initial setup"
	echo "Install git, clone or update local repository, run installer"
	echo "See $VPS_REPO for details"
	echo "Usage: bootstrap.sh [CONFIG_FILE]"
	exit
fi; done

if [[ "$(id -u)" -ne 0 ]]; then
	echo "You must run this as root" >&2
	exit 1
fi

#------------------------------------------------------------------------------

if ! dpkg-query --show git &>/dev/null; then
	apt install -y git
fi

if [[ ! -d "$VPS_DIR" ]]; then
	git clone -- "$VPS_REPO" "$VPS_DIR"
fi

git -C "$VPS_DIR" fetch
git -C "$VPS_DIR" checkout --force master
git -C "$VPS_DIR" reset --hard origin/master

trap - ERR  # Since we got this far, remove the trap

"$VPS_DIR"/install.sh
