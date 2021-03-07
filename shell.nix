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
in pkgs.mkShell {
	buildInputs = [
		pkgs.vscode
		(
			pkgs.writeShellScriptBin "configure" ''
				${ pkgs.gnupg }/bin/gpg --batch --import ./.private/gpg-private-keys.asc &&
				${ pkgs.gnupg }/bin/gpg --import-ownertrust ./.private/gpg-ownertrust.asc &&
				${ pkgs.gnupg }/bin/gpg2 --import ./.private/gpg2-private-keys.asc &&
				${ pkgs.gnupg }/bin/gpg2 --import-ownertrust ./.private/gpg2-ownertrust.asc &&
				${ pkgs.coreutils }/bin/mkdir ${ builtins.getEnv "PWD" }/.structures &&
				${ pkgs.coreutils }/mkdir ${ builtins.getEnv "PWD" }/.structures/dot-ssh &&
				${ pkgs.coreutils }/bin/chmod 0700 ${ builtins.getEnv "PWD" }/.structures/dot-ssh &&
				${ pkgs.coreutils }/bin/cat ${ ssh-config } > ${ builtins.getEnv "PWD" }/.structures/dot-ssh/config &&
				${ pkgs.coreutils }/bin/chmod 0400 ${ builtins.getEnv "PWD" }/.structures/dot-ssh/config ${ builtins.getEnv "PWD" }/.structures/dot-ssh/upstream.id-rsa ${ builtins.getEnv "PWD" }/.structures/dot-ssh/personal.id-rsa ${ builtins.getEnv "PWD" }/.structures/dot-ssh/report.id-rsa  ${ builtins.getEnv "PWD" }/.structures/dot-ssh/known-hosts &&
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
				pass boot https://github.com/nextmoose/secrets.git bbb3c3a5-1aad-42fe-9aed-e87068f661d1 &&
				export PASSWORD_STORE_DIR=${ builtins.getEnv "PWD" }/.structures/password-stores/boot &&
				${ pkgs.pass }/bin/pass show upstream.id-rsa > ${ builtins.getEnv "PWD" }/.structures/dot-ssh/upstream.id-rsa &&
				${ pkgs.pass }/bin/pass show personal.id-rsa > ${ builtins.getEnv "PWD" }/.structures/dot-ssh/personal.id-rsa &&
				${ pkgs.pass }/bin/pass show report.id-rsa > ${ builtins.getEnv "PWD" }/.structures/dot-ssh/report.id-rsa &&
				${ pkgs.pass }/bin/pass show known-hosts.id-rsa > ${ builtins.getEnv "PWD" }/.structures/dot-ssh/known-hosts &&
				pass browser personal:nextmoose/secrets.git 5d3b3a2b-8e3d-454a-ae5b-117123eb2c85 &&
				pass challenge personal:nextmoose/challenge-secrets.git master &&
				pass system personal:nextmoose/secrets.git master &&
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
	] ;
}
