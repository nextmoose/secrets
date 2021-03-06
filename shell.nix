{ pkgs ? import <nixpkgs> { } } : let
	structure = {
		constructor-script ? "" ,
		make-directory ? false
	} : let
		dollar = expression : builtins.concatStringsSep "" [ "$" "{" ( builtins.toString expression ) "}" ] ;
		hash = builtins.hashString "sha512" ( builtins.concatStringsSep "" [ constructor-script ( builtins.toString make-directory ) ] ) ;
		logger = pkgs.writeShellScriptBin "logger" ''
			${ pkgs.coreutils }/bin/tee > $( ${ pkgs.coreutils }/bin/dirname ${ dollar 0 } )/log
		'' ;
	in {
		construct = pkgs.writeShellScriptBin "construct" ''
			${ pkgs.coreutils }/bin/mkdir --parents ${ builtins.getEnv "PWD" }/.structures &&
			(
				(
					${ pkgs.flock }/bin/flock 200 || exit 41
				) &&
				PERMANENT=$( ${ pkgs.mktemp }/bin/mktemp -d ${ builtins.getEnv "PWD" }/.structures/XXXXXXXX ) &&
				TEMPORARY=$( ${ pkgs.mktemp }/bin/mktemp -d ) &&
				OUTPUT=$( ${ pkgs.mktemp }/bin/mktemp -d ) &&
				NOISE=$( ${ pkgs.mktemp }/bin/mktemp -d ) &&
				ERROR=$( ${ pkgs.mktemp }/bin/mktemp -d ) &&
				${ pkgs.coreutils }/bin/ln --symbolic ${ logger }/bin/logger ${ dollar "OUTPUT" } &&
				${ pkgs.coreutils }/bin/ln --symbolic ${ logger }/bin/logger ${ dollar "NOISE" } &&
				${ pkgs.coreutils }/bin/ln --symbolic ${ logger }/bin/logger ${ dollar "ERROR" } &&
				${ if make-directory then "cd ${ dollar "PERMANENT" }" else "${ pkgs.coreutils }/bin/rm --recursive --force ${ dollar "PERMANENT" }" }
				if ${ pkgs.writeShellScriptBin "constructor" constructor-script }/bin/constructor ${ dollar "PERMANENT" } ${ dollar "TEMPORARY" } ${ dollar "NOISE" }/logger ${ hash } > >( ${ dollar "OUTPUT" }/logger ) 2> >( ${ dollar "ERROR" }/logger ) && [ -z "$( ${ pkgs.coreutils }/bin/cat ${ dollar "ERROR" }/log )" ]
				then
					${ pkgs.findutils }/bin/find ${ dollar "TEMPORARY" }/temp -type f -exec ${ pkgs.coreutils }/bin/shred --force --remove {} \; &&
					${ pkgs.coreutils }/bin/shred --force --remove ${ dollar "OUTPUT" }/log &&
					${ pkgs.coreutils }/bin/shred --force --remove ${ dollar "NOISE" }/log &&
					${ pkgs.coreutils }/bin/shred --force --remove ${ dollar "ERROR" }/log &&
					${ pkgs.coreutils }/bin/rm --recursive --force ${ dollar "TEMPORARY" } ${ dollar "OUTPUT" } ${ dollar "NOISE" } ${ dollar "ERROR" } &&
					${ pkgs.coreutils }/bin/ln --symbolic ${ dollar "PERMANENT" } ${ builtins.getEnv "PWD" }/${ hash }
				else
					(
						${ pkgs.coreutils }/bin/cat <<EOF
						PERMANENT=${ dollar "PERMANENT" }
						TEMPORARY=${ dollar "TEMPORARY" }
						OUTPUT=${ dollar "OUTPUT" }
						NOISE=${ dollar "NOISE" }
						ERROR=${ dollar "ERROR" }
						EXIT_CODE=${ dollar "EXIT_CODE" }
					)
				fi
				${ pkgs.coreutils }/bin/rm ${ builtins.getEnv "PWD" }/.structures/lock
			) 200> ${ builtins.getEnv "PWD" }/.structures/lock
		'' ;
		link = pkgs.writeShellScriptBin "link" ''
			${ pkgs.coreutils }/bin/readlink --canonicalize ${ builtins.getEnv "PWD" }/.structures/${ hash }
		'' ;
	} ;
in pkgs.mkShell {
	buildInputs = [
		pkgs.vscode

		pkgs.moreutils
	] ;
}
