#!/bin/sh

/usr/bin/sudo /usr/bin/dnf update --assumeyes &&
/usr/bin/sudo /usr/bin/dnf install --assumeyes curl &&
/usr/bin/sudo /usr/bin/mkdir /nix &&
/usr/bin/sudo /usr/bin/chown $( /usr/bin/whoami ):$( /usr/bin/whoami ) /nix &&
/usr/bin/curl -L https://nixos.org/nix/install | /usr/bin/sh &&
/usr/bin/sudo /usr/bin/dnf install --assumeyes direnv &&
(
    /usr/bin/cat >> ${HOME}/.bashrc <<EOF
source ${HOME}.nix-profile/etc/profile.d/nix.sh
eval "\$( /usr/bin/direnv hook bash )"
EOF
) &&
/usr/bin/sudo /usr/bin/dnf install --assumeyes snapd &&
/usr/bin/sudo /usr/bin/ln -s /var/lib/snapd/snap /snap &&
/usr/bin/sudo snap install rpi-imager
