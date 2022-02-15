#!/bin/bash
#
# SPDX-License-Identifier: BSD-3-Clause
#
# Copyright 2022 Philipp Le
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
# THE POSSIBILITY OF SUCH DAMAGE.

function prep_tz() {
    TZ=${TZ:-UTC}
    cp /usr/share/zoneinfo/${TZ} /etc/localtime
    echo "${TZ}" >  /etc/timezone
}

function prep_user() {
    # Create user
    PUID=${PUID:-1000}
    PGID=${PGID:-1000}
    mkdir -p /data
    groupadd -g $PGID $USER_NAME
    useradd -u $PUID -N -g $USER_NAME -G users -d /data -s /bin/bash $USER_NAME
    echo -e "$USER_PASS\n$USER_PASS" | passwd $USER_NAME
    chown $USER_NAME:$USER_NAME /data
}

if [ "$1" == "help" ]; then
    echo "Usage: $0 [COMMAND]"
    echo "COMMAND is:"
    echo "  keygen       Generate server keys and store them in /config"
    echo "  base_config  Put base config in /config"
    echo "  start        Start the SSH server"
    echo "  shell        Start bash"
elif [ "$1" == "keygen" ]; then
    prep_tz
    ssh-keygen -t rsa -b 4096 -N "" -q -f /config/ssh_host_rsa_key
    ssh-keygen -t dsa -N "" -q -f /config/ssh_host_dsa_key
    ssh-keygen -t ecdsa -N "" -q -f /config/ssh_host_ecdsa_key
    ssh-keygen -t ed25519  -N "" -q -f /config/ssh_host_ed25519_key
elif [ "$1" == "base_config" ]; then
    prep_tz
    cp /etc/ssh/sshd_config /config/sshd_config
    sed -i '/^PasswordAuthentication/c\PasswordAuthentication no' /config/sshd_config
    sed -i '/^#HostKey \/etc\/ssh\/ssh_host_rsa_key/c\HostKey \/config\/ssh_host_rsa_key' /config/sshd_config
    sed -i '/^#HostKey \/etc\/ssh\/ssh_host_ecdsa_key/c\HostKey \/config\/ssh_host_ecdsa_key' /config/sshd_config
    sed -i '/^#HostKey \/etc\/ssh\/ssh_host_ed25519_key/c\HostKey \/config\/ssh_host_ed25519_key' /config/sshd_config
    sed -i '/^AuthorizedKeysFile/c\AuthorizedKeysFile \/config\/authorized_keys' /config/sshd_config
    chmod 0600 /config/sshd_config
elif [ "$1" == "edit_config" ]; then
    prep_tz
    nano /config/sshd_config
    chmod 0600 /config/sshd_config
elif [ "$1" == "start" ]; then
    prep_tz
    prep_user
    /usr/sbin/sshd -D -e -p 22 -f /config/sshd_config
elif [ "$1" == "shell" ]; then
    prep_tz
    prep_user
    bash
fi
