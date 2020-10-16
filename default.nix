{ pkgs ? import <nixpkgs> { } , structures-dir ? builtins.concatStringsSep "/" [ ( builtins.getEnv "HOME" ) ".nix-shell" "structures" ] , private-dir ? /. + ( builtins. concatStringsSep "/" [ ( builtins.getEnv "HOME" ) ".nix-shell" "private" ] ) , config } : let
structure = constructor-script : "$( ${ pkgs.writeShellScriptBin "structure" ''
if [ ! -d ${ structures-dir } ]
then
    ${ pkgs.coreutils }/bin/mkdir ${ structures-dir } &&
        ${ pkgs.coreutils }/bin/true
fi &&
    (
        ( ${ pkgs.flock }/bin/flock 200 || exit 64 ) &&
            if [ -d ${ structures-dir }/${ builtins.hashString "sha512" ( builtins.toString ( pkgs.writeShellScriptBin "constructor" constructor-script ) ) } ]
            then
	        STRUCTURE_DIR=$( ${ pkgs.coreutils }/bin/readlink --canonicalize ${ structures-dir }/${ builtins.hashString "sha512" ( builtins.toString ( pkgs.writeShellScriptBin "constructor" constructor-script ) ) } ) &&
	            if [ $( ${ pkgs.coreutils }/bin/readlink --canonicalize $STRUCTURE_DIR/constructor ) != "${ pkgs.writeShellScriptBin "constructor" constructor-script }/bin/constructor" ]
	            then
		        ${ pkgs.coreutils }/bin/echo Constructor Script Mismatch:  $STRUCTURE_DIR/constructor does not match ${ pkgs.writeShellScriptBin "constructor" constructor-script } > $STRUCTURE_DIR/failure.asc &&
		            exit 64 &&
		 	    ${ pkgs.coreutils }/bin/true
		    elif [ ! -f $STRUCTURE_DIR/before.asc ]
		    then
		        ${ pkgs.coreutils }/bin/echo The construction before time was not recorded. > $STRUCTURE_DIR/failure.asc &&
		            exit 64 &&
			    ${ pkgs.coreutils }/bin/true
		    elif [ ! -f $STRUCTURE_DIR/after.asc ]
		    then
		        ${ pkgs.coreutils }/bin/echo The construction after time was not recorded. > $STRUCTURE_DIR/failure.asc &&
		            exit 64 &&
			    ${ pkgs.coreutils }/bin/true
		    elif [ ! -f $STRUCTURE_DIR/exit-code.asc ]
		    then
		        ${ pkgs.coreutils }/bin/echo The construction exit code was not recorded. > $STRUCTURE_DIR/failure.asc &&
		            exit 64 &&
			    ${ pkgs.coreutils }/bin/true
		    elif [ $( ${ pkgs.coreutils }/bin/cat $STRUCTURE_DIR/exit-code.asc ) != 0 ]
		    then
		        ${ pkgs.coreutils }/bin/echo The construction errored with exit code $( ${ pkgs.coreutils }/bin/cat $STRUCTURE_DIR/exit-code.asc ) > $STRUCTURE_DIR/failure.asc &&
		            exit 64 &&
			    ${ pkgs.coreutils }/bin/true
		    elif [ ! -f $STRUCTURE_DIR/out.asc ]
		    then
		        ${ pkgs.coreutils }/bin/echo The construction did not record standard out. > $STRUCTURE_DIR/failure.asc &&
		            exit 64 &&
			    ${ pkgs.coreutils }/bin/true
		    elif [ -f $STRUCTURE_DIR/failure.asc ]
		    then
		        ${ pkgs.coreutils }/bin/echo The construction recorded failure. >> $STRUCTURE_DIR/failure.asc &&
		            exit 64 &&
			    ${ pkgs.coreutils }/bin/true
		    elif [ ! -f $STRUCTURE_DIR/err.asc ]
		    then
		        ${ pkgs.coreutils }/bin/echo The construction did not record standard error. > $STRUCTURE_DIR/failure.asc &&
		            exit 64 &&
			    ${ pkgs.coreutils }/bin/true
		    elif [ ! -z "$( ${ pkgs.coreutils }/bin/cat $STRUCTURE_DIR/err.asc )" ]
		    then
		        ${ pkgs.coreutils }/bin/echo The construction recorded some standard error. > $STRUCTURE_DIR/failure.asc &&
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
	                ${ pkgs.coreutils }/bin/ln --symbolic $STRUCTURE_DIR ${ structures-dir }/${ builtins.hashString "sha512" ( builtins.toString ( pkgs.writeShellScriptBin "constructor" constructor-script ) ) } &&
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
cfg = import config pkgs {
    dot-gnupg = gpg-private-keys : gpg-ownertrust : gpg2-private-keys : gpg2-ownertrust : structure ''
${ pkgs.gnupg }/bin/gpg --homedir $( ${ pkgs.coreutils }/bin/pwd ) --batch --import ${ gpg-private-keys } 2> err.asc &&
    ${ pkgs.gnupg }/bin/gpg --homedir $( ${ pkgs.coreutils }/bin/pwd ) --import-ownertrust ${ gpg-ownertrust } 2> err.asc &&
    ${ pkgs.gnupg }/bin/gpg2 --homedir $( ${ pkgs.coreutils }/bin/pwd ) --import ${ gpg2-private-keys } 2> err.asc &&
    ${ pkgs.gnupg }/bin/gpg2 --homedir $( ${ pkgs.coreutils }/bin/pwd ) --import-ownertrust ${ gpg2-ownertrust } 2> err.asc &&
    ${ pkgs.coreutils }/bin/chmod 0700 $( ${ pkgs.coreutils }/bin/pwd ) &&
    ${ pkgs.coreutils }/bin/true
    '' ;

    dot-ssh = hosts : includes : structure ''
( ${ pkgs.coreutils }/bin/cat > config <<EOF
${ builtins.concatStringsSep "\n\n" ( builtins.map ( include : builtins.concatStringsSep " " [ "Include" include ] ) includes ) }
EOF
    ) &&
    ${ pkgs.coreutils }/bin/chmod 0400 config &&
    ${ pkgs.coreutils }/bin/true
    '' ;

    github-ssh-key = passphrase : personal-access-token : structure ''
${ pkgs.openssh }/bin/ssh-keygen -f id-rsa -P "${ passphrase }" -C "generated key" &&
    ( ${ pkgs.coreutils }/bin/cat <<EOF
{
    "title": "Generated Key",
    "key": "$( ${ pkgs.coreutils }/bin/cat id_rsa.pub )"
}
EOF
    ) &&
#    ) | ${ pkgs.curl }/bin/curl --header "Authorization: token ${ personal-access-token }" --header "Content-Type: application/json" --request POST --data @- https://api.github.com/user/keys > response.json &&
    ${ pkgs.coreutils }/bin/true
'' ;

    initialize-boot-secrets = gpg-private-keys : gpg-ownertrust : gpg2-private-keys : gpg2-ownertrust : ''
export HOME=$HOME/initialize &&
    ${ pkgs.coreutils }/bin/mkdir $HOME &&
    cd $HOME &&
    BRANCH=$( ${ pkgs.utillinux }/bin/uuidgen ) &&
    ${ pkgs.gnupg }/bin/gpg --batch --import ${ gpg-private-keys } &&
    ${ pkgs.gnupg }/bin/gpg --import-ownertrust ${ gpg-ownertrust } &&
    ${ pkgs.gnupg }/bin/gpg2 --import ${ gpg2-private-keys } &&
    ${ pkgs.gnupg }/bin/gpg2 --import-ownertrust ${ gpg2-ownertrust } &&
    ${ pkgs.pass }/bin/pass init $( ${ pkgs.gnupg }/bin/gpg --keyid-format LONG -k "$1" | ${ pkgs.coreutils }/bin/head --lines 1 | ${ pkgs.coreutils }/bin/cut --fields 2 --delimiter "/" | ${ pkgs.coreutils }/bin/cut --fields 1 --delimiter " " ) &&
    ${ pkgs.pass }/bin/pass git init &&
    ${ pkgs.pass }/bin/pass git config user.name "$1" &&
    ${ pkgs.pass }/bin/pass git config user.email "$2" &&
    ${ pkgs.pass }/bin/pass git remote add origin "$3" &&
    ${ pkgs.pass }/bin/pass git checkout --orphan $BRANCH &&
    ${ pkgs.coreutils }/bin/cat ${ gpg-private-keys } | ${ pkgs.pass }/bin/pass insert --multiline gpg-private-keys &&
    ${ pkgs.coreutils }/bin/cat ${ gpg-ownertrust } | ${ pkgs.pass }/bin/pass insert --multiline gpg-ownertrust &&
    ${ pkgs.coreutils }/bin/cat ${ gpg2-private-keys } | ${ pkgs.pass }/bin/pass insert --multiline gpg2-private-keys &&
    ${ pkgs.coreutils }/bin/cat ${ gpg2-ownertrust } | ${ pkgs.pass }/bin/pass insert --multiline gpg2-ownertrust &&
    ${ pkgs.coreutils }/bin/echo "$4" | ${ pkgs.pass }/bin/pass insert --multiline personal-access-token &&
    UUID=$( ${ pkgs.utillinux }/bin/uuidgen ) &&
    ${ pkgs.coreutils }/bin/echo $UUID | ${ pkgs.pass }/bin/pass insert --multiline uuid &&
    echo BRANCH=$BRANCH &&
    ${ pkgs.pass }/bin/pass git push origin HEAD &&
    ( ${ pkgs.coreutils }/bin/cat <<EOF
builtins.fetchGit {
    url = $3 ;
    rev = "$( ${ pkgs.pass }/bin/pass git rev-parse HEAD )" ;
    ref = "$BRANCH" ;
}
uuid = $UUID
EOF
    ) &&
    ${ pkgs.coreutils }/bin/true
    '' ;

    pass = dot-gnupg : password-store-dir : ''
export PASSWORD_STORE_GPG_OPTS="--homedir ${ dot-gnupg } --pinentry-mode loopback --batch --passphrase-file $HOME/.gnupg-passphrase.asc" &&
    export PASSWORD_STORE_DIR=${ password-store-dir } &&
    export PATH=$PATH &&
    exec ${ pkgs.pass }/bin/pass $@ &&
    ${ pkgs.coreutils }/bin/true
    '' ;

    personal-identification-number = digits : uuid : structure ''
${ pkgs.coreutils }/bin/cat /dev/urandom | ${ pkgs.coreutils }/bin/tr --delete --complement "0-9" | ${ pkgs.coreutils }/bin/fold --width ${ builtins.toString digits } | ${ pkgs.coreutils }/bin/head --lines 1 > personal-identification-number.asc &&
    ${ pkgs.coreutils }/bin/true
    '' ;

    private = path : private-dir + ( "/" + path ) ;
    secret-file = dot-gnupg : password-store-dir : pass-name : structure ''
export PASSWORD_STORE_GPG_OPTS="--homedir ${ dot-gnupg }" &&
    export PASSWORD_STORE_DIR=${ password-store-dir } &&
    ${ pkgs.pass }/bin/pass show ${ pass-name } > secret.asc &&
    ${ pkgs.coreutils }/bin/chmod 0400 secret.asc &&
    ${ pkgs.coreutils }/bin/true
    '' ;

    secret-value = dot-gnupg : password-store-dir : pass-name : "$( ${ pkgs.writeShellScriptBin "secret-value" ''
export PASSWORD_STORE_GPG_OPTS="--homedir ${ dot-gnupg } --pinentry-mode loopback --batch --passphrase-file $HOME/.gnupg-passphrase.asc" &&
    export PASSWORD_STORE_DIR=${ password-store-dir } &&
    ${ pkgs.pass }/bin/pass show ${ pass-name } &&
    ${ pkgs.coreutils }/bin/true
'' }/bin/secret-value )" ;

    temporary-directory = uuid : structure ''
${ pkgs.coreutils }/bin/echo ${ uuid } &&
    ${ pkgs.coreutils }/bin/true
'' ;
} ;
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
	    while ! boot-secrets show uuid
	    do
	        read -s -p "GNUPG PASSPHRASE? " GNUPG_PASSPHRASE &&
	        echo $GNUPG_PASSPHRASE > $HOME/.gnupg-passphrase.asc &&
		${ pkgs.coreutils }/bin/true
	    done &&
            export STRUCTURES_DIR=${ structures-dir } &&
	    export PRIVATE_DIR=${ private-dir } &&
	    ${ builtins.concatStringsSep "\n" ( builtins.map ( name : "export ${ builtins.replaceStrings [ "q" "w" "e" "r" "t" "y" "u" "i" "o" "p" "a" "s" "d" "f" "g" "h" "j" "k" "l" "z" "x" "c" "v" "b" "n" "m" "-" ] [ "Q" "W" "E" "R" "T" "Y" "U" "I" "O" "P" "A" "S" "D" "F" "G" "H" "J" "K" "L" "Z" "X" "C" "V" "B" "N" "M" "_" ] name }=\"${ builtins.getAttr name cfg.variables }\" &&" ) ( builtins.attrNames cfg.variables ) ) }
	    ${ pkgs.coreutils }/bin/true
    '' ;
    buildInputs = builtins.concatLists [ [ pkgs.gnupg ] ( builtins.map ( name : pkgs.writeShellScriptBin name ( builtins.getAttr name cfg.derivations ) ) ( builtins.attrNames cfg.derivations ) ) ] ;
}