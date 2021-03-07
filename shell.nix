{ pkgs ? import <nixpkgs> { } } : let
	dollar = expression : builtins.concatStringsSep "" [ "$" "{" ( builtins.toString expression ) "}" ] ;
	post-commit = pkgs.writeShellScriptBin "post-commit" ''
		while ! ${ pkgs.git }/bin/git push personal HEAD
		do
			${ pkgs.coreutils }/bin/sleep 1s
		done
	'' ;
	ssh-config = builtins.toFile "config" ''
Host upstream
HostName github.com
User git
IdentityFile ${ builtins.getEnv "PWD" }/.structures/dot-ssh/upstream.id-rsa
UserKnownHostsFile  ${ builtins.getEnv "PWD" }/.structures/dot-ssh/known-hosts

Host personal
HostName github.com
User git
IdentityFile ${ builtins.getEnv "PWD" }/.structures/dot-ssh/personal.id-rsa
UserKnownHostsFile  ${ builtins.getEnv "PWD" }/.structures/dot-ssh/known-hosts

Host report
HostName github.com
User git
IdentityFile ${ builtins.getEnv "PWD" }/.structures/dot-ssh/report.id-rsa
UserKnownHostsFile  ${ builtins.getEnv "PWD" }/.structures/dot-ssh/known-hosts
	'' ;
	fedora-partitions = builtins.toFile "partitions" ''
n
p


+8GB
w




	'' ;
	luks-setup = builtins.toFile "setup" ''
		YES
		blueberry
		blueberry


	'' ;
in pkgs.mkShell {
	buildInputs = [
		pkgs.vscode
		(
			pkgs.writeShellScriptBin "initial-configuration" ''
				${ pkgs.gnupg }/bin/gpg --batch --import ./.private/gpg-private-keys.asc &&
				${ pkgs.gnupg }/bin/gpg --import-ownertrust ./.private/gpg-ownertrust.asc &&
				${ pkgs.gnupg }/bin/gpg2 --import ./.private/gpg2-private-keys.asc &&
				${ pkgs.gnupg }/bin/gpg2 --import-ownertrust ./.private/gpg2-ownertrust.asc &&
				${ pkgs.coreutils }/bin/mkdir ${ builtins.getEnv "PWD" }/.structures &&
				${ pkgs.coreutils }/bin/mkdir ${ builtins.getEnv "PWD" }/.structures/dot-ssh &&
				${ pkgs.coreutils }/bin/chmod 0700 ${ builtins.getEnv "PWD" }/.structures/dot-ssh &&
				${ pkgs.coreutils }/bin/cat ${ ssh-config } > ${ builtins.getEnv "PWD" }/.structures/dot-ssh/config &&
				${ pkgs.coreutils }/bin/mkdir ${ builtins.getEnv "PWD" }/.structures/password-stores &&
				pass() {
					NAME=${ dollar 1 } &&
					URL=${ dollar 2 } &&
					BRANCH=${ dollar 3 } &&
					${ pkgs.coreutils }/bin/mkdir ${ builtins.getEnv "PWD" }/.structures/password-stores/${ dollar "NAME" } &&
					${ pkgs.git }/bin/git -C ${ builtins.getEnv "PWD" }/.structures/password-stores/${ dollar "NAME" } init &&
					${ pkgs.coreutils }/bin/ln --symbolic ${ post-commit }/bin/post-commit ${ builtins.getEnv "PWD" }/.structures/password-stores/${ dollar "NAME" }/.git/hooks &&
					${ pkgs.git }/bin/git -C ${ builtins.getEnv "PWD" }/.structures/password-stores/${ dollar "NAME" } config user.name "Emory Merryman" &&
					${ pkgs.git }/bin/git -C ${ builtins.getEnv "PWD" }/.structures/password-stores/${ dollar "NAME" } config user.email "emory.merryman@gmail.com" &&
					${ pkgs.git }/bin/git -C ${ builtins.getEnv "PWD" }/.structures/password-stores/${ dollar "NAME" } config core.sshCommand "${ pkgs.openssh }/bin/ssh -F ${ builtins.getEnv "PWD" }/.structures/dot-ssh/config" &&
					${ pkgs.git }/bin/git -C ${ builtins.getEnv "PWD" }/.structures/password-stores/${ dollar "NAME" } remote add personal ${ dollar "URL" } &&
					${ pkgs.git }/bin/git -C ${ builtins.getEnv "PWD" }/.structures/password-stores/${ dollar "NAME" } fetch personal ${ dollar "BRANCH" } &&
					${ pkgs.git }/bin/git -C ${ builtins.getEnv "PWD" }/.structures/password-stores/${ dollar "NAME" } checkout ${ dollar "BRANCH" }
				} &&
				pass boot https://github.com/nextmoose/secrets.git e411046b-b79e-4266-a8fd-d56a3dbcb77d &&
				export PASSWORD_STORE_DIR=${ builtins.getEnv "PWD" }/.structures/password-stores/boot &&
				${ pkgs.pass }/bin/pass show upstream.id-rsa > ${ builtins.getEnv "PWD" }/.structures/dot-ssh/upstream.id-rsa &&
				${ pkgs.pass }/bin/pass show personal.id-rsa > ${ builtins.getEnv "PWD" }/.structures/dot-ssh/personal.id-rsa &&
				${ pkgs.pass }/bin/pass show report.id-rsa > ${ builtins.getEnv "PWD" }/.structures/dot-ssh/report.id-rsa &&
				${ pkgs.pass }/bin/pass show known-hosts > ${ builtins.getEnv "PWD" }/.structures/dot-ssh/known-hosts &&
				${ pkgs.coreutils }/bin/chmod 0400 ${ builtins.getEnv "PWD" }/.structures/dot-ssh/config ${ builtins.getEnv "PWD" }/.structures/dot-ssh/upstream.id-rsa ${ builtins.getEnv "PWD" }/.structures/dot-ssh/personal.id-rsa ${ builtins.getEnv "PWD" }/.structures/dot-ssh/report.id-rsa  ${ builtins.getEnv "PWD" }/.structures/dot-ssh/known-hosts &&
				pass browser personal:nextmoose/secrets.git 5d3b3a2b-8e3d-454a-ae5b-117123eb2c85 &&
				pass challenge personal:nextmoose/challenge-secrets.git master &&
				pass system personal:nextmoose/secrets.git e411046b-b79e-4266-a8fd-d56a3dbcb77d  &&
				pass feature personal:nextmoose/secrets.git master &&
				${ pkgs.coreutils }/bin/true
			''
		)
		(
			pkgs.stdenv.mkDerivation {
				name = "wizardry" ;
				src = ./empty ;
				buildInputs = [ pkgs.makeWrapper ] ;
				installPhase = ''
					makeWrapper ${ pkgs.pass }/bin/pass $out/bin/browser-pass --set PASSWORD_STORE_DIR ${ builtins.getEnv "PWD" }/.structures/password-stores/browser &&
					makeWrapper ${ pkgs.pass }/bin/pass $out/bin/challenge-pass --set PASSWORD_STORE_DIR ${ builtins.getEnv "PWD" }/.structures/password-stores/challenge &&
					makeWrapper ${ pkgs.pass }/bin/pass $out/bin/system-pass --set PASSWORD_STORE_DIR ${ builtins.getEnv "PWD" }/.structures/password-stores/system &&
					makeWrapper ${ pkgs.pass }/bin/pass $out/bin/feature-pass --set PASSWORD_STORE_DIR ${ builtins.getEnv "PWD" }/.structures/password-stores/feature &&
					${ pkgs.coreutils }/bin/true
				'' ;
			}
		)
		(
			pkgs.writeShellScriptBin "fedora-sd-image" ''
				/usr/bin/sudo ${ pkgs.unixtools.fdisk }/bin/fdisk -l | ${ pkgs.gnugrep }/bin/grep "Disk /" | ${ pkgs.gnused }/bin/sed -e "s#Disk \(/[^:]*\):.*#\1#" | ${ pkgs.coreutils }/bin/sort | ${ pkgs.coreutils }/bin/uniq &&
				read -p "OUTPUT DEVICE?  " OUTPUT_DEVICE &&
				${ pkgs.findutils }/bin/find $( ${ pkgs.coreutils }/bin/dirname ${ dollar "OUTPUT_DEVICE" } ) -name "$( ${ pkgs.coreutils }/bin/basename ${ dollar "OUTPUT_DEVICE" } )[0-9]*" -exec ${ pkgs.umount }/bin/umount {} \; &&
				${ pkgs.curl }/bin/curl https://dl.fedoraproject.org/pub/fedora/linux/releases/33/Workstation/aarch64/images/Fedora-Workstation-33-1.3.aarch64.raw.xz | /usr/bin/sudo ${ pkgs.coreutils }/bin/dd of=${ dollar "OUTPUT_DEVICE" } bs=1M status=progress &&
				${ pkgs.coreutils }/bin/cat ${ fedora-partitions } | /usr/bin/sudo ${ pkgs.unixtools.fdisk }/bin/fdisk ${ dollar "OUTPUT_DEVICE" } &&
				/usr/bin/sudo ${ pkgs.utillinux }/bin/mkfs -t ext4 ${ dollar "OUTPUT_DEVICE" } &&
				MOUNT=$( ${ pkgs.mktemp }/bin/mktemp -d ) &&
				/usr/bin/sudo ${ pkgs.mount }/bin/mount ${ dollar "OUTPUT_DEVICE" }4 ${ dollar "MOUNT" } &&
				/usr/bin/sudo chown $( ${ pkgs.coreutils }/bin/whoami ):$( ${ pkgs.coreutils }/bin/whoami ) ${ dollar "MOUNT" } &&
				${ pkgs.coreutils }/bin/cp --recursive ${ builtins.getEnv "PWD" } ${ dollar "MOUNT" } &&
				/usr/bin/sudo ${ pkgs.umount }/bin/umount ${ dollar "MOUNT" } &&
				${ pkgs.coreutils }/bin/cat ${ luks-setup } | /usr/bin/sudo ${ pkgs.cryptsetup }/bin/cryptsetup luksFormat ${ dollar "OUTPUT_DEVICE" }4
			''
		)
		(
			pkgs.writeShellScriptBin "add-nix-partition" ''
				OUTPUT_DEVICE=${ dollar 1 } &&
				${ pkgs.coreutils }/bin/cat ${ fedora-partitions } | /usr/bin/sudo ${ pkgs.unixtools.fdisk }/bin/fdisk ${ dollar "OUTPUT_DEVICE" } &&
				NEW_INDEX=$( ${ pkgs.findutils }/bin/find $( ${ pkgs.coreutils }/bin/dirname ${ dollar "OUTPUT_DEVICE" } ) -name "$( ${ pkgs.coreutils }/bin/basename ${ dollar "OUTPUT_DEVICE" } )" | ${ pkgs.coreutils }/bin/wc --lines ) &&
				/usr/bin/sudo ${ pkgs.utillinux }/bin/mkfs -t ext4 ${ dollar "OUTPUT_DEVICE" }${ dollar "NEW_INDEX" } &&
				MOUNT=$( ${ pkgs.mktemp }/bin/mktemp -d ) &&
				/usr/bin/sudo ${ pkgs.mount }/bin/mount ${ dollar "OUTPUT_DEVICE" }${ dollar "NEW_INDEX" } ${ dollar "MOUNT" } &&
				/usr/bin/sudo chown $( ${ pkgs.coreutils }/bin/whoami ):$( ${ pkgs.coreutils }/bin/whoami ) ${ dollar "MOUNT" } &&
				/usr/bin/sudo ${ pkgs.umount }/bin/umount ${ dollar "MOUNT" } &&
				/usr/bin/sudo ${ pkgs.mount }/bin/mount ${ dollar "OUTPUT_DEVICE" }2 ${ dollar "MOUNT" } &&
				${ pkgs.coreutils }/bin/echo "LABEL=nix         /nix  ext4    defaults,x-systemd.growfs    0 0" | /usr/bin/sudo ${ pkgs.coreutils }/bin/tee --append ${ dollar "MOUNT" }/etc/fstab &&
				/usr/bin/sudo ${ pkgs.umount }/bin/umount ${ dollar "MOUNT" } &&
				${ pkgs.coreutils }/bin/rm --recursive --force ${ dollar "MOUNT" }
			''
		)
		(
			pkgs.writeShellScriptBin "add-wizardry-partition" ''
				OUTPUT_DEVICE=${ dollar 1 } &&
				INDEX=${ dollar 2 } &&
				${ pkgs.gnused }/bin/sed -e "s#4#${ dollar "INDEX" }#" ${ fedora-partitions } | /usr/bin/sudo ${ pkgs.unixtools.fdisk }/bin/fdisk ${ dollar "OUTPUT_DEVICE" }${ dollar "INDEX" } &&
				/usr/bin/sudo ${ pkgs.utillinux }/bin/mkfs -t ext4 ${ dollar "OUTPUT_DEVICE" } &&
				MOUNT=$( ${ pkgs.mktemp }/bin/mktemp -d ) &&
				/usr/bin/sudo ${ pkgs.mount }/bin/mount ${ dollar "OUTPUT_DEVICE" }${ dollar "INDEX" } ${ dollar "MOUNT" } &&
				/usr/bin/sudo chown $( ${ pkgs.coreutils }/bin/whoami ):$( ${ pkgs.coreutils }/bin/whoami ) ${ dollar "MOUNT" } &&
				${ pkgs.coreutils }/bin/cp --recursive ${ builtins.getEnv "PWD" } ${ dollar "MOUNT" } &&
				/usr/bin/sudo ${ pkgs.umount }/bin/umount ${ dollar "MOUNT" } &&
				${ pkgs.coreutils }/bin/rm --recursive --force ${ dollar "MOUNT" }
			''
		)
		(
			pkgs.writeShellScriptBin "encrypt-wizardry-partition" ''
				OUTPUT_DEVICE=${ dollar 1 } &&
				INDEX=${ dollar 2 } &&
				${ pkgs.umount }/bin/umount ${ dollar "OUTPUT_DEVICE" }/${ dollar "INDEX" } &&
				${ pkgs.coreutils }/bin/cat ${ luks-setup } | /usr/bin/sudo ${ pkgs.cryptsetup }/bin/cryptsetup luksFormat ${ dollar "OUTPUT_DEVICE" }${ dollar "INDEX" }
			''
		)
		(
			pkgs.writeShellScriptBin "lvm-stuff" ''
				OUTPUT_DEVICE=${ dollar 1 } &&
				${ pkgs.lvm2 }/bin/pvcreate
				# FIGURE THIS STUFF OUT
			''
		)
	] ;
}
