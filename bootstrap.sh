#!/bin/bash
# bootstrap - Bootstrap VPS initial config
#
# Copyright (C) 2020 Rodrigo Silva (MestreLion) <linux@rodrigosilva.com>
# License: GPLv3 or later, at your choice. See <http://www.gnu.org/licenses/gpl>
#
# Instructions:
# - Choose "Ubuntu 20.04" image (/etc/ssh/sshd_config.d/ does not exist in 18.04)
# - Set root password (root SSH login will be disabled by this setup)
# - Log in via Cloud Provider VPS Web Console
# - Copy in terminal:
#
#  bash <(wget -qO - -- 'https://github.com/MestreLion/vps/raw/master/bootstrap.sh')
#
###############################################################################

set -Eeuo pipefail  # exits on any errors
trap '>&2 echo "error $? executing command in line $LINENO: $BASH_COMMAND"' ERR

export VPS_CONFIG=${1:-${VPS_CONFIG:-/etc/vps.conf}}

if [[ -r "$VPS_CONFIG" ]]; then
	set -a  # export all vars in config
	source "$VPS_CONFIG"
	set +a
fi

###############################################################################

VPS_REPO=${VPS_REPO:-'https://github.com/MestreLion/vps.git'}
VPS_DIR=${VPS_DIR:-'/opt/vps'}

if [[ "$(id -u)" -ne 0 ]]; then
	echo "You must run this as root" >&2
	exit 1
fi

if ! dpkg-query --show git &>/dev/null; then
	apt install -y git
fi

if [[ ! -d "$VPS_DIR" ]]; then
	git clone -- "$VPS_REPO" "$VPS_DIR"
fi

git -C "$VPS_DIR" pull --quiet

if [[ ! -f "$VPS_CONFIG" ]]; then
	cp --no-clobber -- "$VPS_DIR"/vps.template.conf "$VPS_CONFIG"
	nano "$VPS_CONFIG"
	set -a  # export all vars in config
	source "$VPS_CONFIG"
	set +a
fi

env | grep VPS_
