{ pkgs ? import <nixpkgs> { } , structures-dir ? builtins.concatStringsSep "/" [ ( builtins.getEnv "HOME" ) ".nix-shell" "structures" ] , private-dir ? /. + ( builtins. concatStringsSep "/" [ ( builtins.getEnv "HOME" ) ".nix-shell" "private" ] ) } : pkgs.mkShell {
    shellHook = ''
        if [ ! -d ${ structures-dir } ]
	then
	    ${ pkgs.coreutils }/bin/mkdir ${ structures-dir } &&
	        true
        fi &&
            export HOME=$( ${ pkgs.mktemp }/bin/mktemp -d ${ structures-dir }/XXXXXXXX ) &&
	    cleanup ( ) {
	        ${ pkgs.coreutils }/bin/rm --recursive --force $HOME &&
	            true
	    } &&
	    trap cleanup EXIT &&
	    cd $HOME &&
            export STRUCTURES_DIR=${ structures-dir } &&
	    export PRIVATE_DIR=${ private-dir } &&
	    true
    '' ;
}