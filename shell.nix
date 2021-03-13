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
					makeWrapper ${ pkgs.gnucash }/bin/gnucash $out/bin/gnucash &&
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
				NEW_INDEX=$( ${ pkgs.findutils }/bin/find $( ${ pkgs.coreutils }/bin/dirname ${ dollar "OUTPUT_DEVICE" } ) -name "$( ${ pkgs.coreutils }/bin/basename ${ dollar "OUTPUT_DEVICE" } )[0-9]*" | ${ pkgs.coreutils }/bin/wc --lines ) &&
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
				${ pkgs.coreutils }/bin/cat ${ fedora-partitions } | /usr/bin/sudo ${ pkgs.unixtools.fdisk }/bin/fdisk ${ dollar "OUTPUT_DEVICE" } &&
				NEW_INDEX=$( ${ pkgs.findutils }/bin/find $( ${ pkgs.coreutils }/bin/dirname ${ dollar "OUTPUT_DEVICE" } ) -name "$( ${ pkgs.coreutils }/bin/basename ${ dollar "OUTPUT_DEVICE" } )[0-9]*" | ${ pkgs.coreutils }/bin/wc --lines ) &&
				/usr/bin/sudo ${ pkgs.utillinux }/bin/mkfs -t ext4 ${ dollar "OUTPUT_DEVICE" }${ dollar "NEW_INDEX" } &&
				MOUNT=$( ${ pkgs.mktemp }/bin/mktemp -d ) &&
				/usr/bin/sudo ${ pkgs.mount }/bin/mount ${ dollar "OUTPUT_DEVICE" }${ dollar "NEW_INDEX" } ${ dollar "MOUNT" } &&
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
		(
			pkgs.writeShellScriptBin "ubuntu-400" ''
				${ pkgs.coreutils }/bin/echo To prepare for this, I ran sudo cp /etc/NetworkManager/system-connections/HOME-3DE8.nmconnection .private/HOME-3DE8.nmconnection &&
				${ pkgs.coreutils }/bin/echo This contains my ssid and wifi password.  I hope this is everything necessary to hook up wifi. &&
				${ pkgs.coreutils }/bin/echo This will only work for my wifi - not yours. &&
				${ pkgs.coreutils }/bin/echo But the goal is that the resulting sd-card is closer to "just use it" condition and needs less setup. &&
				MOUNT=$( ${ pkgs.mktemp }/bin/mktemp -d ) &&
				/usr/bin/sudo ${ pkgs.mount }/bin/mount ${ dollar 1 } ${ dollar "MOUNT" } &&
				/usr/bin/sudo ${ pkgs.coreutils }/bin/cp ${ builtins.getEnv "PWD" }/.private/HOME-3DE8.nmconnection ${ dollar "MOUNT" }/etc/NetworkManager/system-connections/HOME-3DE8.nmconnection &&
				/usr/bin/sudo ${ pkgs.coreutils }/bin/chmod 0600 ${ dollar "MOUNT" }/etc/NetworkManager/system-connections/HOME-3DE8.nmconnection &&
				/usr/bin/sudo ${ pkgs.umount }/bin/umount ${ dollar "MOUNT" } &&
				${ pkgs.coreutils }/bin/rm --recursive --force ${ dollar "MOUNT" }
			''
		)
		(
			pkgs.writeShellScriptBin "ubuntu-current-preseed-file" ''
				if [ ${ dollar "#" } == 0 ]
				then
					OUTPUT_FILE=${ builtins.getEnv "PWD" }/current-preseed.cfg
				else
					OUTPUT_FILE=${ dollar 1 }
				fi &&
				/usr/bin/sudo /usr/bin/debconf-get-selections --installer > ${ dollar "OUTPUT_FILE" } &&
				/usr/bin/sudo /usr/bin/debconf-get-selections >> ${ dollar "OUTPUT_FILE" } &&
				${ pkgs.coreutils }/bin/chmod 0400 ${ dollar "OUTPUT_FILE" }
			''
		)
		(
			pkgs.writeShellScriptBin "kludge-install-system-config-kickstart" ''
				# Based on https://askubuntu.com/a/1242391
				cd $( ${ pkgs.mktemp }/bin/mktemp -d ) &&
				${ pkgs.wget }/bin/wget http://old-releases.ubuntu.com/ubuntu/pool/universe/p/pygtk/python-gtk2_2.24.0-6_amd64.deb &&
				${ pkgs.wget }/bin/wget http://old-releases.ubuntu.com/ubuntu/pool/universe/p/pygtk/python-glade2_2.24.0-6_amd64.deb &&
				${ pkgs.wget }/bin/wget http://archive.ubuntu.com/ubuntu/pool/universe/s/system-config-kickstart/system-config-kickstart_2.5.20-0ubuntu25_all.deb &&
				/usr/bin/sudo /usr/bin/apt-get update --assume-yes &&
				/usr/bin/sudo /usr/bin/apt-get install --assume-yes ./*.deb
			''
		)
		(
			pkgs.writeShellScriptBin "ubuntu-10" ''
				MOUNT=$( ${ pkgs.mktemp }/bin/mktemp -d ) &&
				/usr/bin/sudo ${ pkgs.mount }/bin/mount /dev/sda2 ${ dollar "MOUNT" } &&
				/usr/bin/sudo ${ pkgs.coreutils }/bin/cp --recursive . ${ dollar "MOUNT" }/wizardry &&
				/usr/bin/sudo ${ pkgs.coreutils }/bin/chown -R $( ${ pkgs.coreutils }/bin/whoami ):$( ${ pkgs.coreutils }/bin/whoami ) ${ dollar "MOUNT" }/wizardry &&
				/usr/bin/sudo ${ pkgs.umount }/bin/umount ${ dollar "MOUNT" } &&
				${ pkgs.coreutils }/bin/rm --recursive --force ${ dollar "MOUNT" }
			''
		)
		(
			pkgs.writeShellScriptBin "install-rpi-clone" ''
				cd $( ${ pkgs.mktemp }/bin/mktemp -d ) &&
				${ pkgs.git }/bin/git clone https://github.com/billw2/rpi-clone.git &&
				cd rpi-clone &&
				/usr/bin/sudo ${ pkgs.coreutils }/bin/cp rpi-clone rpi-clone-setup /usr/local/sbin
			''
		)
		(
			let script = pkgs.writeShellScriptBin "ubuntu-backup" ''
				${ pkgs.coreutils }/bin/mkdir --parents ${ builtins.getEnv "PWD" }/backups &&
				(
					(
						${ pkgs.flock }/bin/flock -n 200 || exit 41
					) &&
					ONE=$( ${ pkgs.coreutils }/bin/top -bn1 | ${ pkgs.coreutils }/bin/head --lines 1 | ${ pkgs.gnused }/bin/sed -e "s#^top - [0-9][0-9]:[0-9][0-9]:[0-9][0-9] up [0-9][0-9]:[0-9][0-9],[ ]*[0-9]* user,[ ]*load average: \([^,]*\), \([^,]*\), \(.*\)\$#\1#" ) &&
					FIFTEEN=$( ${ pkgs.coreutils }/bin/top -bn1 | ${ pkgs.coreutils }/bin/head --lines 1 | ${ pkgs.gnused }/bin/sed -e "s#^top - [0-9][0-9]:[0-9][0-9]:[0-9][0-9] up [0-9][0-9]:[0-9][0-9],[ ]*[0-9]* user,[ ]*load average: \([^,]*\), \([^,]*\), \(.*\)\$#\3#" ) &&
					if [ -b /dev/sda ] && [ ! -f ${ builtins.getEnv "PWD" }/backups/semaphore ] && [ ${ dollar "ONE" } -lt 1 ] && [ ${ dollar "FIFTEEN" } -lt 1 ]
					then
						TSTAMP=$( ${ pkgs.coreutils }/bin/date +%Y%m%d%H%M ) &&
						${ pkgs.coreutils }/bin/dd if=/dev/sda bs=4M | ${ pkgs.gzip }/bin/gzip -9 > ${ builtins.getEnv "PWD" }/backups/${ dollar "TSTAMP" }.img.gz &&
						${ pkgs.coreutils }/bin/sha512sum ${ builtins.getEnv "PWD" }/backup.${ dollar "TSTAMP" }.img.gz | ${ pkgs.coreutils }/bin/cut --bytes -128 > ${ builtins.getEnv "PWD" }/backups/${ dollar "TSTAMP" }.img.gz.sha512 &&
						FLAG=0 &&
						${ pkgs.findutils }/bin/find ${ builtins.getEnv "PWD" }/backups -name *.img.gz -exec ${ pkgs.coreutils }/bin/stat --format "%W ${ builtins.getEnv "PWD" }/backups/%n" {}\; | ${ pkgs.coreutils }/bin/sort --key 1 --numeric | ${ pkgs.coreutils }/bin/tail --lines 2 | ${ pkgs.coreutils }/bin/cut --delimiter " " --fields 2 | while read FILE
						do
							if [ ${ dollar "FILE" } != ${ builtins.getEnv "PWD" }/backups/${ dollar "TSTAMP" }.img.gz ] &&
								[ ${ dollar "FLAG" } == 0 ] &&
								[ -f ${ dollar "FILE" }.sha512 ] &&
								${ pkgs.coreutils }/bin/diff -qrs ${ dollar "FILE" }.sha512 ${ builtins.getEnv "PWD" }/backups.${ dollar "TSTAMP" }.img.gz.sha512 &&
								${ pkgs.coreutils }/bin/diff -qrs ${ dollar "FILE" } ${ builtins.getEnv "PWD" }/backups.${ dollar "TSTAMP" }.img.gz
							then
								FLAG=1
							elif [ ${ dollar "FILE" } == ${ builtins.getEnv "PWD" }/backups/${ dollar "TSTAMP" }.img.gz ] &&
								[ FLAG==1 ]
							then
								${ pkgs.coreutils }/bin/rm ${ dollar "FILE" }
							fi
						done
					fi &&
					${ pkgs.coreutils }/bin/rm ${ builtins.getEnv "PWD" }/backups/lock
				) 200> ${ builtins.getEnv "PWD" }/backups/lock
			'' ; in pkgs.writeShellScriptBin "ubuntu-backup" "${ pkgs.coreutils }/bin/echo '* * * * *  ${ pkgs.coreutils }/bin/nice --adjustment 19 ${ script }/bin/ubuntu-backup ' | /usr/bin/sudo /usr/bin/crontab -"
		)
		(
			pkgs.writeShellScriptBin "ubuntu-restore" ''
				(
					(
						${ pkgs.flock }/bin/flock -n 200 || exit 41
					) &&
					${ pkgs.findutils }/bin/find ${ builtins.getEnv "PWD" }/backups -name *.img.gz -exec ${ pkgs.coreutils }/bin/stat --format "%W ${ builtins.getEnv "PWD" }/backups/%n" | ${ pkgs.coreutils }/bin/sort --key 1 --numeric | ${ pkgs.coreutils }/bin/tail --lines 1 | ${ pkgs.coreutils }/bin/cut --delimiter " " --fields 2 | while read FILE
					do
						${ pkgs.gzip }/bin/gunzip ${ dollar 1 } | /usr/bin/sudo ${ pkgs.coreutils }/bin/dd of=/dev/sda bs=4M
					done
				) 200> ${ builtins.getEnv "PWD" }/backups/lock
			''
		)
		(
			pkgs.writeShellScriptBin "gnucash" ''

			''
		)
		pkgs.jq
		pkgs.s3fs
		(
			let
				policy-document = builtins.toFile "policy.json" ''
					{
						"Version": "2012-10-17",
						"Statement": [
							{
								"Sid": "VisualEditor0",
								"Effect": "Allow",
								"Action": [
									"s3:PutObject",
									"s3:GetObject",
									"s3:ListBucket",
									"s3:DeleteObject"
								],
								"Resource": [
									"arn:aws:s3:::${ dollar "BUCKET_NAME" }",
									"arn:aws:s3:::${ dollar "BUCKET_NAME" }/*"
								]
							}
						]
					}
				'' ;
				configure-gnucash = pkgs.writeShellScriptBin "configure-gnucash" ''
					export PASSWORD_STORE_DIR=${ builtins.getEnv "PWD" }/.structures/password-stores/system &&
					${ pkgs.pass }/bin/pass show &&
					export AWS_SECRET_ACCESS_KEY=$( ${ pkgs.pass }/bin/pass show aws/iam/${ dollar "AWS_ACCESS_KEY_ID" } ) &&
					export AWS_DEFAULT_REGION=us-east-1 &&
					BUCKET_NAME=$( ${ pkgs.libuuid }/bin/uuidgen ) &&
					USER_NAME=$( ${ pkgs.libuuid }/bin/uuidgen ) &&
					PASSWD_FILE=$( ${ pkgs.mktemp }/bin/mktemp ) &&
					# GROUP_NAME=$( ${ pkgs.libuuid }/bin/uuidgen ) &&
					POLICY_NAME=$( ${ pkgs.libuuid }/bin/uuidgen ) &&
					COMMIT_HASH=$( ${ pkgs.git }/bin/git -C ${ builtins.getEnv "PWD" } rev-parse HEAD ) &&
					${ pkgs.coreutils }/bin/echo BUCKET_NAME=${ dollar "BUCKET_NAME" } &&
					${ pkgs.coreutils }/bin/echo USER_NAME=${ dollar "USER_NAME" } &&
					# ${ pkgs.coreutils }/bin/echo GROUP_NAME=${ dollar "GROUP_NAME" } &&
					${ pkgs.coreutils }/bin/echo POLICY_NAME=${ dollar "POLICY_NAME" } &&
					${ pkgs.coreutils }/bin/echo PASSWD_FILE=${ dollar "PASSWD_FILE" } &&
					${ pkgs.awscli2 }/bin/aws s3api create-bucket --acl private --bucket ${ dollar "BUCKET_NAME" } &&
					${ pkgs.awscli2 }/bin/aws s3api put-bucket-versioning --bucket ${ dollar "BUCKET_NAME" } --versioning-configuration Status=Enabled &&
					${ pkgs.awscli2 }/bin/aws s3api put-bucket-encryption --bucket ${ dollar "BUCKET_NAME" } --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}' &&
					${ pkgs.awscli2 }/bin/aws iam create-user --user-name ${ dollar "USER_NAME" } --tags Key=CommitHash,Value=${ dollar "COMMIT_HASH" } &&
					${ pkgs.awscli2 }/bin/aws iam create-access-key --user-name ${ dollar "USER_NAME" } | ${ pkgs.jq }/bin/jq --raw-output "[.AccessKey.AccessKeyId,.AccessKey.SecretAccessKey] | join(\":\")" > ${ dollar "PASSWD_FILE" } &&
					${ pkgs.coreutils }/bin/chmod 0400 ${ dollar "PASSWD_FILE" } &&
					# ${ pkgs.awscli2 }/bin/aws iam create-group --group-name ${ dollar "GROUP_NAME" } &&
					# ${ pkgs.awscli2 }/bin/aws iam add-user-to-group --group-name ${ dollar "GROUP_NAME" } --user-name ${ dollar "USER_NAME" } &&
					POLICY_DOCUMENT=$( ${ pkgs.mktemp }/bin/mktemp ) &&
					${ pkgs.gnused }/bin/sed -e "s#\${ dollar "BUCKET_NAME" }#${ dollar "BUCKET_NAME" }#" -e "w${ dollar "POLICY_DOCUMENT" }" ${ policy-document } &&
					POLICY_ARN=$( ${ pkgs.awscli2 }/bin/aws iam create-policy --policy-name ${ dollar "POLICY_NAME" } --policy-document file://${ dollar "POLICY_DOCUMENT" } | ${ pkgs.jq }/bin/jq --raw-output ".Policy.Arn" ) &&
					${ pkgs.awscli2 }/bin/aws iam attach-user-policy --user-name ${ dollar "USER_NAME" } --policy-arn ${ dollar "POLICY_ARN" } &&
					${ pkgs.coreutils }/bin/echo PASSWD_FILE=${ dollar "PASSWD_FILE" } &&
					${ pkgs.coreutils }/bin/true
					# CREATE A BUCKET
					# CREATE A POLICY BINDING USER AND BUCKET
					# REPORT GENERATED VALUES
				'' ;
			in pkgs.stdenv.mkDerivation {
				name = "aws-setup" ;
				src = ./empty ;
				buildInputs = [ pkgs.makeWrapper ] ;
				installPhase = ''
					makeWrapper ${ configure-gnucash }/bin/configure-gnucash $out/bin/configure-gnucash --set AWS_ACCESS_KEY_ID AKIAYZXVAKILN3BH7BWG --set AWS_DEFAULT_REGION us-east-1 --set AWS_DEFAULT_OUTPUT json
				'' ;
			}
		)
		pkgs.awscli2
		pkgs.libuuid
	] ;
}
