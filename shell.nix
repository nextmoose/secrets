{ pkgs ? import <nixpkgs> { } } : pkgs.mkShell {
	buildInputs = [
		pkgs.vscode
		(
			pkgs.writeShellScriptBin "configure" ''
				${ pkgs.gnupg }/bin/gpg --batch --import ./.private/gpg-private-keys.asc &&
				${ pkgs.gnupg }/bin/gpg --import-ownertrust ./.private/gpg-ownertrust.asc &&
				${ pkgs.gnupg }/bin/gpg2 --import ./.private/gpg2-private-keys.asc &&
				${ pkgs.gnupg }/bin/gpg2 --import-ownertrust ./.private/gpg2-ownertrust.asc
			''
		)
	] ;
}
