{ pkgs ? import <nixpkgs> { } } : let
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
				${ pkgs.coreutils }/bin/cat ${ ./.private/upstream.id-rsa.asc } > ${ builtins.getEnv "PWD" }/.structures/dot-ssh/upstream.id-rsa &&
				${ pkgs.coreutils }/bin/cat ${ ./.private/personal.id-rsa.asc } > ${ builtins.getEnv "PWD" }/.structures/dot-ssh/personal.id-rsa &&
				${ pkgs.coreutils }/bin/cat ${ ./.private/report.id-rsa.asc } > ${ builtins.getEnv "PWD" }/.structures/dot-ssh/report.id-rsa &&
				${ pkgs.coreutils }/bin/cat ${ ./.private/known-hosts.asc } > ${ builtins.getEnv "PWD" }/.structures/dot-ssh/known-hosts &&
				${ pkgs.coreutils }/bin/cat ${ ssh-config } > ${ builtins.getEnv "PWD" }/.structures/dot-ssh/config &&
				${ pkgs.coreutils }/bin/chmod 0400 ${ builtins.getEnv "PWD" }/.structures/dot-ssh/config ${ builtins.getEnv "PWD" }/.structures/dot-ssh/upstream.id-rsa ${ builtins.getEnv "PWD" }/.structures/dot-ssh/personal.id-rsa ${ builtins.getEnv "PWD" }/.structures/dot-ssh/report.id-rsa  ${ builtins.getEnv "PWD" }/.structures/dot-ssh/known-hosts &&
				${ pkgs.coreutils }/bin/mkdir ${ builtins.getEnv "PWD" }/.structures/password-stores &&
				${ pkgs.coreutils }/bin/mkdir ${ builtins.getEnv "PWD" }/.structures/password-stores/browser &&
				${ pkgs.git }/bin/git -C ${ builtins.getEnv "PWD" }/.structures/password-stores/browser init &&
				${ pkgs.coreutils }/bin/ln --symbolic ${ post-commit }/bin/post-commit ${ builtins.getEnv "PWD" }/.structures/password-stores/browser/.git/hooks &&
				${ pkgs.git }/bin/git -C ${ builtins.getEnv "PWD" }/.structures/password-stores/browser config user.name "Emory Merryman" &&
				${ pkgs.git }/bin/git -C ${ builtins.getEnv "PWD" }/.structures/password-stores/browser config user.email "emory.merryman@gmail.com" &&
				${ pkgs.git }/bin/git -C ${ builtins.getEnv "PWD" }/.structures/password-stores/browser config core.sshCommand "${ pkgs.openssh }/bin/ssh -F ${ builtins.getEnv "PWD" }/.structures/dot-ssh/config" &&
				${ pkgs.git }/bin/git -C ${ builtins.getEnv "PWD" }/.structures/password-stores/browser remote add personal personal:nextmoose/browser-secrets.git &&
				${ pkgs.git }/bin/git -C ${ builtins.getEnv "PWD" }/.structures/password-stores/browser fetch personal master &&
				${ pkgs.git }/bin/git -C ${ builtins.getEnv "PWD" }/.structures/password-stores/browser checkout master &&
				${ pkgs.coreutils }/bin/true
			''
		)
		(
			pkgs.stdenv.mkDerivation {
				name = "wizardry" ;
				src = ./empty ;
				buildInputs = [ pkgs.makeWrapper ] ;
				installPhase = ''
					makeWrapper ${ pkgs.pass }/bin/pass $out/bin/browser-pass --set PASSWORD_STORE_DIR ${ builtins.getEnv "PWD" }/.structures/password-stores/browser
				'' ;
			}
		)
	] ;
}
