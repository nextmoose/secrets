{ pkgs ? import <nixpkgs> { } } : let
	ssh-config = builtins.toFile "config" ''
		Host upstream
		HostName github.com
		User git
		IdentityFile ${ builtins.getEnv "PWD" }/.ssh/upstream.id-rsa
		UserKnownHostsFile  ${ builtins.getEnv "PWD" }/.ssh/known-hosts

		Host personal
		HostName github.com
		User git
		IdentityFile ${ builtins.getEnv "PWD" }/.ssh/personal.id-rsa
		UserKnownHostsFile  ${ builtins.getEnv "PWD" }/.ssh/known-hosts

		Host report
		HostName github.com
		User git
		IdentityFile ${ builtins.getEnv "PWD" }/.ssh/report.id-rsa
		UserKnownHostsFile  ${ builtins.getEnv "PWD" }/.ssh/known-hosts
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
				${ pkgs.coreutils }/mkdir ${ builtins.getEnv "PWD" }/.ssh &&
				${ pkgs.coreutils }/bin/chmod 0700 ${ builtins.getEnv "PWD" }/.ssh &&
				${ pkgs.coreutils }/bin/cat ${ ./.private/upstream.id-rsa.asc } > ${ builtins.getEnv "PWD" }/.ssh/upstream.id-rsa &&
				${ pkgs.coreutils }/bin/cat ${ ./.private/personal.id-rsa.asc } > ${ builtins.getEnv "PWD" }/.ssh/personal.id-rsa &&
				${ pkgs.coreutils }/bin/cat ${ ./.private/report.id-rsa.asc } > ${ builtins.getEnv "PWD" }/.ssh/report.id-rsa &&
				${ pkgs.coreutils }/bin/cat ${ ./.private/known-hosts.asc } > ${ builtins.getEnv "PWD" }/.ssh/known-hosts &&
				${ pkgs.coreutils }/bin/cat ${ ssh-config } > ${ builtins.getEnv "PWD" }/.ssh/config &&
				${ pkgs.coreutils }/bin/chmod 0400 ${ builtins.getEnv "PWD" }/.ssh/config ${ builtins.getEnv "PWD" }/.ssh/upstream.id-rsa ${ builtins.getEnv "PWD" }/.ssh/personal.id-rsa ${ builtins.getEnv "PWD" }/.ssh/report.id-rsa  ${ builtins.getEnv "PWD" }/.ssh/known-hosts &&
				${ pkgs.coreutils }/bin/mkdir ${ builtins.getEnv "HOME" }/.password-store &&
				${ pkgs.git }/bin/git -C ${ builtins.getEnv "HOME" }/.password-store
			''
		)
	] ;
}
