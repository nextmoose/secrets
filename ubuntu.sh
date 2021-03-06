#!/bin/sh

/usr/bin/sudo /usr/bin/apt-get update --assume-yes &&
/usr/bin/sudo /usr/bin/apt-get install --assume-yes curl &&
/usr/bin/curl -L https://nixos.org/nix/install | /usr/bin/sudo /usr/bin/sh &&
/usr/bin/sudo /usr/bin/apt-get install --assume-yes direnv &&
/usr/bin/echo eval "\$( /usr/bin/direnv hook bash )" >> ${HOME}/.bashrc
