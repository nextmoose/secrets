{ pkgs ? import <nixpkgs> { } , structures-dir ? builtins.concatStringsSep "/" [ ( builtins.getEnv "HOME" ) ".nix-shell" "structures" ] , private-dir ? /. + ( builtins. concatStringsSep "/" [ ( builtins.getEnv "HOME" ) ".nix-shell" "private" ] ) , config } : let
structure = constructor-script : "$( ${ pkgs.writeShellScriptBin "structure" ''
if [ ! -d ${ structures-dir } ]
then
    ${ pkgs.coreutils }/bin/mkdir ${ structures-dir } &&
        ${ pkgs.coreutils }/bin/true
fi &&
    (
        ( ${ pkgs.flock }/bin/flock 200 || exit 64 ) &&
            if [ -f ${ structures-dir }/${ builtins.hashString "sha512" ( builtins.toString ( pkgs.writeShellScriptBin "constructor" constructor-script ) ) } ]
            then
	        STRUCTURE_DIR=$( ${ pkgs.coreutils }/bin/readlink --canonicalize ${ structures-dir }/${ builtins.hashString "sha512" ( builtins.toString ( pkgs.writeShellScriptBin "constructor" constructor-script ) ) } ) &&
	            if [ $( ${ pkgs.coreutils }/bin/readlink --canonicalize $STRUCTURE_DIR/constructor ) != "${ pkgs.writeShellScriptBin "constructor" constructor-script }" ]
	            then
		        ${ pkgs.coreutils }/bin/echo Constructor Script Mismatch:  $STRUCTURE_DIR/constructor does not match ${ pkgs.writeShellScriptBin "constructor" constructor-script } &&
		            exit 64 &&
		 	    ${ pkgs.coreutils }/bin/true
		    elif [ ! -f $STRUCTURE_DIR/before.asc ]
		    then
		        ${ pkgs.coreutils }/bin/echo The construction before time was not recorded. &&
		            exit 64 &&
			    ${ pkgs.coreutils }/bin/true
		    elif [ ! -f $STRUCTURE_DIR/after.asc ]
		    then
		        ${ pkgs.coreutils }/bin/echo The construction after time was not recorded. &&
		            exit 64 &&
			    ${ pkgs.coreutils }/bin/true
		    elif [ ! -f $STRUCTURE_DIR/exit-code.asc ]
		    then
		        ${ pkgs.coreutils }/bin/echo The construction exit code was not recorded. &&
		            exit 64 &&
			    ${ pkgs.coreutils }/bin/true
		    elif [ $( ${ pkgs.coreutils }/bin/cat $STRUCTURE_DIR/exit-code.asc ) != 0 ]
		    then
		        ${ pkgs.coreutils }/bin/echo The construction errored with exit code $( ${ pkgs.coreutils }/bin/cat $STRUCTURE_DIR/exit-code.asc ) &&
		            exit 64 &&
			    ${ pkgs.coreutils }/bin/true
		    elif [ ! -f $STRUCTURE_DIR/out.asc ]
		    then
		        ${ pkgs.coreutils }/bin/echo The construction did not record standard out. &&
		            exit 64 &&
			    ${ pkgs.coreutils }/bin/true
		    elif [ ! -f $STRUCTURE_DIR/err.asc ]
		    then
		        ${ pkgs.coreutils }/bin/echo The construction did not record standard error. &&
		            exit 64 &&
			    ${ pkgs.coreutils }/bin/true
		    elif [ ! -z "${ pkgs.coreutils }/bin/cat $STRUCTURE_DIR/err.asc" ]
		    then
		        ${ pkgs.coreutils }/bin/echo The construction recorded some standard error. &&
		            exit 64 &&
			    ${ pkgs.coreutils }/bin/true
		    else
                        ${ pkgs.coreutils }/bin/readlink --canonicalize ${ structures-dir }/${ builtins.hashString "sha512" ( builtins.toString ( pkgs.writeShellScriptBin "constructor" constructor-script ) ) }/structure &&
		        exit 0 &&
   	                ${ pkgs.coreutils }/bin/true
		    fi &&
		    ${ pkgs.coreutils }/bin/true
            else
                STRUCTURE_DIR=$( ${ pkgs.mktemp }/bin/mktemp -d ${ structures-dir }/XXXXXXXX ) &&
	            ${ pkgs.coreutils }/bin/mkdir $STRUCTURE_DIR/structure &&
	            cd $STRUCTURE_DIR/structure &&
		    ${ pkgs.coreutils }/bin/ln --symbolic ${ pkgs.writeShellScriptBin "constructor" constructor-script }/bin/constructor $STRUCTURE_DIR &&
	            ${ pkgs.coreutils }/bin/date +%s > $STRUCTURE_DIR/before.asc &&
	            ${ pkgs.writeShellScriptBin "constructor" constructor-script }/bin/constructor > $STRUCTURE_DIR/out.asc 2> $STRUCTURE_DIR/err.asc &&
	            EXIT_CODE=$? &&
	            ${ pkgs.coreutils }/bin/date +%s > $STRUCTURE_DIR/after.asc &&
	            ${ pkgs.coreutils }/bin/echo $EXIT_CODE > $STRUCTURE_DIR/exit-code.asc &&
	            if [ $EXIT_CODE == 0 ]
	            then
	                ${ pkgs.coreutils }/bin/ln --symbolic $STRUCTURE_DIR ${ structures-dir }/${ builtins.hashString "sha512" ( builtins.toString ( pkgs.writeShellScriptBin "structure" constructor-script ) ) } &&
		            ${ pkgs.coreutils }/bin/echo $STRUCTURE_DIR/structure &&
		            exit 0 &&
		            ${ pkgs.coreutils }/bin/true
                    else
	                ${ pkgs.coreutils }/bin/echo $STRUCTURE_DIR &&
		            exit 64 &&
		            ${ pkgs.coreutils }/bin/true
	            fi &&
	            ${ pkgs.coreutils }/bin/true
            fi &&
            ${ pkgs.coreutils }/bin/true
    ) 200>${ structures-dir }/${ builtins.hashString "sha512" ( builtins.toString ( pkgs.writeShellScriptBin "constructor" constructor-script ) ) }.lock &&
    ${ pkgs.coreutils }/bin/rm ${ structures-dir }/${ builtins.hashString "sha512" ( builtins.toString ( pkgs.writeShellScriptBin "constructor" constructor-script ) ) }.lock &&
    ${ pkgs.coreutils }/bin/true
'' }/bin/structure )" ;
cfg = import config pkgs structure ;
derivations = cfg.derivations ;
in pkgs.mkShell {
    shellHook = ''
        if [ ! -d ${ structures-dir } ]
	then
	    ${ pkgs.coreutils }/bin/mkdir ${ structures-dir } &&
	        true
        fi &&
            export HOME=$( ${ pkgs.mktemp }/bin/mktemp -d ${ structures-dir }/XXXXXXXX ) &&
	    cleanup ( ) {
	        ${ pkgs.coreutils }/bin/rm --recursive --force $HOME &&
	            ${ pkgs.coreutils }/bin/true
	    } &&
	    trap cleanup EXIT &&
	    cd $HOME &&
            export STRUCTURES_DIR=${ structures-dir } &&
	    export PRIVATE_DIR=${ private-dir } &&
	    ${ pkgs.coreutils }/bin/true
    '' ;
    buildInputs = builtins.map ( name : pkgs.writeShellScriptBin name ( builtins.getAttr name cfg.derivations ) ) ( builtins.attrNames cfg.derivations ) ;
}