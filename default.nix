{ pkgs ? import <nixpkgs> { } , structures-dir ? builtins.concatStringsSep "/" [ ( builtins.getEnv "HOME" ) ".nix-shell" "structures" ] , private-dir ? /. + ( builtins. concatStringsSep "/" [ ( builtins.getEnv "HOME" ) ".nix-shell" "private" ] ) , config } : let
environment-case = string : builtins.replaceStrings [ "q" "w" "e" "r" "t" "y" "u" "i" "o" "p" "a" "s" "d" "f" "g" "h" "j" "k" "l" "z" "x" "c" "v" "b" "n" "m" "-" ] [ "Q" "W" "E" "R" "T" "Y" "U" "I" "O" "P" "A" "S" "D" "F" "G" "H" "J" "K" "L" "Z" "X" "C" "V" "B" "N" "M" "_" ] string ;
dollar = "$" ;
open-curly-bracket = "{" ;
close-curly-bracket = "}" ;
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
		    if [ ! -f $STRUCTURE_DIR/hash.asc ]
		    then
		        ${ pkgs.coreutils }/bin/echo Missing Hash File >> $STRUCTURE_DIR/failure.asc &&
	                    ${ pkgs.coreutils }/bin/echo $STRUCTURE_DIR &&
			    exit 64 &&
			    ${ pkgs.coreutils }/bin/true
	            elif [ $( ${ pkgs.coreutils }/bin/cat $STRUCTURE_DIR/hash.asc ) != ${ builtins.hashString "sha512" ( builtins.toString ( pkgs.writeShellScriptBin "constructor" constructor-script ) ) } ]
		    then
		        ${ pkgs.coreutils }/bin/echo MISMATCHED_HASH_ERROR.  The hash should match ${ builtins.hashString "sha512" ( builtins.toString ( pkgs.writeShellScriptBin "constructor" constructor-script ) ) } >> $STRUCTURE_DIR/failure.asc &&
	                    ${ pkgs.coreutils }/bin/echo $STRUCTURE_DIR &&
			    exit 64 &&
			    ${ pkgs.coreutils }/bin/true
	            elif [ $( ${ pkgs.coreutils }/bin/readlink --canonicalize $STRUCTURE_DIR/constructor ) != "${ pkgs.writeShellScriptBin "constructor" constructor-script }/bin/constructor" ]
	            then
		        ${ pkgs.coreutils }/bin/echo Constructor Script Mismatch:  $STRUCTURE_DIR/constructor does not match ${ pkgs.writeShellScriptBin "constructor" constructor-script }/bin/constructor >> $STRUCTURE_DIR/failure.asc &&
	                    ${ pkgs.coreutils }/bin/echo $STRUCTURE_DIR &&
		            exit 64 &&
		 	    ${ pkgs.coreutils }/bin/true
		    elif [ ! -f $STRUCTURE_DIR/before.asc ]
		    then
		        ${ pkgs.coreutils }/bin/echo The construction before time was not recorded. >> $STRUCTURE_DIR/failure.asc &&
	                    ${ pkgs.coreutils }/bin/echo $STRUCTURE_DIR &&
		            exit 64 &&
			    ${ pkgs.coreutils }/bin/true
		    elif [ ! -f $STRUCTURE_DIR/after.asc ]
		    then
		        ${ pkgs.coreutils }/bin/echo The construction after time was not recorded. >> $STRUCTURE_DIR/failure.asc &&
	                    ${ pkgs.coreutils }/bin/echo $STRUCTURE_DIR &&
		            exit 64 &&
			    ${ pkgs.coreutils }/bin/true
		    elif [ ! -f $STRUCTURE_DIR/exit-code.asc ]
		    then
		        ${ pkgs.coreutils }/bin/echo The construction exit code was not recorded. >> $STRUCTURE_DIR/failure.asc &&
	                    ${ pkgs.coreutils }/bin/echo $STRUCTURE_DIR &&
		            exit 64 &&
			    ${ pkgs.coreutils }/bin/true
		    elif [ $( ${ pkgs.coreutils }/bin/cat $STRUCTURE_DIR/exit-code.asc ) != 0 ]
		    then
		        ${ pkgs.coreutils }/bin/echo The construction errored with exit code $( ${ pkgs.coreutils }/bin/cat $STRUCTURE_DIR/exit-code.asc ) >> $STRUCTURE_DIR/failure.asc &&
	                    ${ pkgs.coreutils }/bin/echo $STRUCTURE_DIR &&
		            exit 64 &&
			    ${ pkgs.coreutils }/bin/true
		    elif [ ! -f $STRUCTURE_DIR/out.asc ]
		    then
		        ${ pkgs.coreutils }/bin/echo The construction did not record standard out. >> $STRUCTURE_DIR/failure.asc &&
	                    ${ pkgs.coreutils }/bin/echo $STRUCTURE_DIR &&
		            exit 64 &&
			    ${ pkgs.coreutils }/bin/true
		    elif [ ! -f $STRUCTURE_DIR/err.asc ]
		    then
		        ${ pkgs.coreutils }/bin/echo The construction did not record standard error. >> $STRUCTURE_DIR/failure.asc &&
	                    ${ pkgs.coreutils }/bin/echo $STRUCTURE_DIR &&
		            exit 64 &&
			    ${ pkgs.coreutils }/bin/true
		    elif [ ! -z "$( ${ pkgs.coreutils }/bin/cat $STRUCTURE_DIR/err.asc )" ]
		    then
		        ${ pkgs.coreutils }/bin/echo The construction recorded some standard error. >> $STRUCTURE_DIR/failure.asc &&
	                    ${ pkgs.coreutils }/bin/echo $STRUCTURE_DIR &&
		            exit 64 &&
			    ${ pkgs.coreutils }/bin/true
		    elif [ -f $STRUCTURE_DIR/failure.asc ]
		    then
		        ${ pkgs.coreutils }/bin/echo The construction recorded failure. >> $STRUCTURE_DIR/failure.asc &&
	                    ${ pkgs.coreutils }/bin/echo $STRUCTURE_DIR &&
		            exit 64 &&
			    ${ pkgs.coreutils }/bin/true
		    else
		        ${ pkgs.coreutils }/bin/date +%s >> $STRUCTURE_DIR/log.asc &&
                            ${ pkgs.coreutils }/bin/readlink --canonicalize ${ structures-dir }/${ builtins.hashString "sha512" ( builtins.toString ( pkgs.writeShellScriptBin "constructor" constructor-script ) ) }/structure &&
		            exit 0 &&
   	                    ${ pkgs.coreutils }/bin/true
		    fi &&
		    ${ pkgs.coreutils }/bin/true
            else
                STRUCTURE_DIR=$( ${ pkgs.mktemp }/bin/mktemp -d ${ structures-dir }/XXXXXXXX ) &&
	            ${ pkgs.coreutils }/bin/echo ${ builtins.hashString "sha512" ( builtins.toString ( pkgs.writeShellScriptBin "constructor" constructor-script ) ) } > $STRUCTURE_DIR/hash.asc &&
		    ${ pkgs.coreutils }/bin/ln --symbolic ${ pkgs.writeShellScriptBin "constructor" constructor-script }/bin/constructor $STRUCTURE_DIR &&
	            ${ pkgs.coreutils }/bin/mkdir $STRUCTURE_DIR/structure &&
	            cd $STRUCTURE_DIR/structure &&
	            ${ pkgs.coreutils }/bin/date +%s > $STRUCTURE_DIR/before.asc &&
	            ( ${ pkgs.writeShellScriptBin "constructor" constructor-script }/bin/constructor > $STRUCTURE_DIR/out.asc 2> $STRUCTURE_DIR/err.asc || true ) &&
	            EXIT_CODE=$? &&
	            ${ pkgs.coreutils }/bin/date +%s > $STRUCTURE_DIR/after.asc &&
	            ${ pkgs.coreutils }/bin/echo $EXIT_CODE > $STRUCTURE_DIR/exit-code.asc &&
	            if [ $EXIT_CODE != 0 ]
	            then
	                ${ pkgs.coreutils }/bin/echo $STRUCTURE_DIR &&
		            exit 64 &&
		            ${ pkgs.coreutils }/bin/true
		    elif [ ! -z "$( ${ pkgs.coreutils }/bin/cat $STRUCTURE_DIR/err.asc )" ]
		    then
	                ${ pkgs.coreutils }/bin/echo $STRUCTURE_DIR &&
		            exit 64 &&
		            ${ pkgs.coreutils }/bin/true
                    else
	                ${ pkgs.coreutils }/bin/ln --symbolic $STRUCTURE_DIR ${ structures-dir }/${ builtins.hashString "sha512" ( builtins.toString ( pkgs.writeShellScriptBin "constructor" constructor-script ) ) } &&
		            ${ pkgs.coreutils }/bin/echo $STRUCTURE_DIR/structure &&
		            exit 0 &&
		            ${ pkgs.coreutils }/bin/true
	            fi &&
                    ${ pkgs.coreutils }/bin/chmod 0400 $STRUCTURE_DIR/before $STRUCTURE_DIR/out.asc $STRUCTURE_DIR/err.asc $STRUCTURE_DIR/after.asc $STRUCTURE_DIR/exit-code.asc &&
	            ${ pkgs.coreutils }/bin/true
            fi &&
            ${ pkgs.coreutils }/bin/true
    ) 200>${ structures-dir }/${ builtins.hashString "sha512" ( builtins.toString ( pkgs.writeShellScriptBin "constructor" constructor-script ) ) }.lock &&
    ${ pkgs.coreutils }/bin/rm ${ structures-dir }/${ builtins.hashString "sha512" ( builtins.toString ( pkgs.writeShellScriptBin "constructor" constructor-script ) ) }.lock &&
    ${ pkgs.coreutils }/bin/true
'' }/bin/structure )" ;
cfg = import config pkgs {
    atom-project = home : atom-home : project : ''
export HOME=${ home } &&
    export ATOM_HOME=${ atom-home } &&
    ${ pkgs.nix }/bin/nix-shell --run "${ pkgs.atom }/bin/atom $@ ${ project }" ${ ./alternate.nix } &&
    ${ pkgs.coreutils }/bin/true
    '' ;

    brackets-project = home : project : ''
export HOME=${ home } &&
    exec ${ pkgs.brackets }/bin/brackets $@ ${ project } &&
    ${ pkgs.coreutils }/bin/true
    '' ;

    dot-gnupg = gpg-private-keys : gpg-ownertrust : gpg2-private-keys : gpg2-ownertrust : structure ''
${ pkgs.coreutils }/bin/chmod 0700 $( ${ pkgs.coreutils }/bin/pwd ) &&
    ${ pkgs.gnupg }/bin/gpg --homedir $( ${ pkgs.coreutils }/bin/pwd ) --batch --import ${ gpg-private-keys } 2> err.asc &&
    ${ pkgs.gnupg }/bin/gpg --homedir $( ${ pkgs.coreutils }/bin/pwd ) --import-ownertrust ${ gpg-ownertrust } 2> err.asc &&
    ${ pkgs.gnupg }/bin/gpg --homedir $( ${ pkgs.coreutils }/bin/pwd ) --update-trustdb 2> err.asc &&
    ${ pkgs.gnupg }/bin/gpg2 --homedir $( ${ pkgs.coreutils }/bin/pwd ) --import ${ gpg2-private-keys } 2> err.asc &&
    ${ pkgs.gnupg }/bin/gpg2 --homedir $( ${ pkgs.coreutils }/bin/pwd ) --import-ownertrust ${ gpg2-ownertrust } 2> err.asc &&
    ${ pkgs.gnupg }/bin/gpg2 --homedir $( ${ pkgs.coreutils }/bin/pwd ) --update-trustdb 2> err.asc &&
    ${ pkgs.coreutils }/bin/true
    '' ;

    dot-ssh = hosts : includes : structure ''
( ${ pkgs.coreutils }/bin/cat > config <<EOF
${ builtins.concatStringsSep "\n\n" ( builtins.concatLists [ ( builtins.map ( include : builtins.concatStringsSep " " [ "Include" include ] ) includes ) ( builtins.map ( host-name : builtins.concatStringsSep "\n" ( builtins.concatLists [ [ ( builtins.concatStringsSep " " [ "Host" host-name ] ) ] ( builtins.map ( attribute-name : builtins.concatStringsSep " " [ ( environment-case attribute-name ) ( builtins.getAttr attribute-name ( builtins.getAttr host-name hosts ) ) ] ) ( builtins.attrNames ( builtins.getAttr host-name hosts ) ) ) ] ) ) ( builtins.attrNames hosts ) ) ] ) }
EOF
    ) &&
    ${ pkgs.coreutils }/bin/chmod 0400 config &&
    ${ pkgs.coreutils }/bin/true
    '' ;

    emacs-project = home : project : ''
export HOME=${ home } &&
    export GIT=${ pkgs.git }/bin/git &&
    exec ${ pkgs.emacs }/bin/emacs $@ ${ project } &&
    ${ pkgs.coreutils }/bin/true
    '' ;

    fetch-git = ssh-config : committer-name : committer-email : upstream-remote : upstream-branch : personal-remote : report-remote : structure ''
${ pkgs.git }/bin/git init &&
    ${ pkgs.coreutils }/bin/ln --symbolic ${ pkgs.writeShellScriptBin "post-commit" ''
while ! ${ pkgs.git }/bin/git push personal HEAD
do
    ${ pkgs.coreutils }/bin/sleep 1s &&
        ${ pkgs.coreutils }/bin/true
done &&
    ${pkgs.coreutils }/bin/true
    '' }/bin/post-commit .git/hooks &&
    ${ pkgs.git }/bin/git config core.sshCommand ${ pkgs.writeShellScriptBin "ssh" "exec ${ pkgs.openssh }/bin/ssh -F ${ ssh-config } $@" }/bin/ssh &&
    ${ pkgs.git }/bin/git config user.name "${ committer-name }" &&
    ${ pkgs.git }/bin/git config user.email "${ committer-email }" &&
    ${ pkgs.git }/bin/git remote add upstream ${ upstream-remote } &&
    ${ pkgs.git }/bin/git remote set-url --push upstream no_push &&
    ${ pkgs.git }/bin/git remote add personal ${ personal-remote } &&
    ${ pkgs.git }/bin/git remote add report ${ report-remote } &&
    ${ pkgs.git }/bin/git fetch upstream ${ upstream-branch } 2> err.asc &&
    ${ pkgs.git }/bin/git checkout ${ upstream-branch } 2>> err.asc &&
    ${ pkgs.coreutils }/bin/true
    '' ;

    github-ssh-key = passphrase : personal-access-token : "${ structure ''
${ pkgs.openssh }/bin/ssh-keygen -f id-rsa -P "${ passphrase }" -C "generated key" &&
    ( ${ pkgs.coreutils }/bin/cat <<EOF
{
    "title": "Generated Key",
    "key": "$( ${ pkgs.coreutils }/bin/cat id-rsa.pub )"
}
EOF
    ) | ${ pkgs.curl }/bin/curl --silent --header "Authorization: token ${ personal-access-token }" --header "Content-Type: application/json" --request POST --data @- https://api.github.com/user/keys > response.json &&
    ${ pkgs.coreutils }/bin/chmod 0700 $( ${ pkgs.coreutils }/bin/pwd ) &&
    ${ pkgs.coreutils }/bin/true
'' }/id-rsa" ;

    initialize-boot-secrets = gpg-private-keys : gpg-ownertrust : gpg2-private-keys : gpg2-ownertrust : ''
export HOME=$HOME/initialize &&
    ${ pkgs.coreutils }/bin/mkdir $HOME &&
    cd $HOME &&
    BRANCH=$( ${ pkgs.utillinux }/bin/uuidgen ) &&
    ${ pkgs.gnupg }/bin/gpg --batch --import ${ gpg-private-keys } &&
    ${ pkgs.gnupg }/bin/gpg --import-ownertrust ${ gpg-ownertrust } &&
    ${ pkgs.gnupg }/bin/gpg2 --import ${ gpg2-private-keys } &&
    ${ pkgs.gnupg }/bin/gpg2 --import-ownertrust ${ gpg2-ownertrust } &&
    ${ pkgs.pass }/bin/pass init $( ${ pkgs.gnupg }/bin/gpg --keyid-format LONG -k "$1" | ${ pkgs.coreutils }/bin/head --lines 4 | ${ pkgs.coreutils }/bin/tail --lines 1 | ${ pkgs.coreutils }/bin/cut --fields 2 --delimiter "/" | ${ pkgs.coreutils }/bin/cut --fields 1 --delimiter " " ) &&
    ${ pkgs.pass }/bin/pass git init &&
    ${ pkgs.pass }/bin/pass git config user.name "$1" &&
    ${ pkgs.pass }/bin/pass git config user.email "$2" &&
    ${ pkgs.pass }/bin/pass git remote add origin "$3" &&
    ${ pkgs.pass }/bin/pass git checkout --orphan $BRANCH &&
    ${ pkgs.coreutils }/bin/cat ${ gpg-private-keys } | ${ pkgs.pass }/bin/pass insert --multiline gpg-private-keys &&
    ${ pkgs.coreutils }/bin/cat ${ gpg-ownertrust } | ${ pkgs.pass }/bin/pass insert --multiline gpg-ownertrust &&
    ${ pkgs.coreutils }/bin/cat ${ gpg2-private-keys } | ${ pkgs.pass }/bin/pass insert --multiline gpg2-private-keys &&
    ${ pkgs.coreutils }/bin/cat ${ gpg2-ownertrust } | ${ pkgs.pass }/bin/pass insert --multiline gpg2-ownertrust &&
    ${ pkgs.coreutils }/bin/echo "$4" | ${ pkgs.pass }/bin/pass insert --multiline github-personal-access-token &&
    ${ pkgs.coreutils }/bin/tee | ${ pkgs.pass }/bin/pass insert --multiline user-known-hosts &&
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

    local-directory = uuid : structure ''
${ pkgs.coreutils }/bin/echo ${ uuid } &&
    ${ pkgs.coreutils }/bin/true
'' ;

    pass = dot-gnupg : password-store-dir : extensions : ''
export PASSWORD_STORE_GPG_OPTS="--homedir ${ dot-gnupg } --pinentry-mode loopback --batch --passphrase-file $HOME/.gnupg-passphrase.asc" &&
    export PASSWORD_STORE_DIR=${ password-store-dir } &&
    export PASSWORD_STORE_ENABLE_EXTENSIONS=${ if builtins.length ( builtins.attrNames extensions ) != 0 then "true" else "false" } &&
    export PASSWORD_STORE_EXTENSIONS_DIR=${ if builtins.length ( builtins.attrNames extensions ) == 0 then "" else pkgs.stdenv.mkDerivation { name = "password-store-extensions-dir" ; src = ./empty ; buildInputs = [ pkgs.coreutils pkgs.makeWrapper ] ; installPhase = "mkdir $out && ${ builtins.concatStringsSep " && \n" ( builtins.map ( name : "makeWrapper ${ pkgs.writeShellScriptBin name ( builtins.getAttr name extensions ) }/bin/${ name } $out/${ name }.bash" ) ( builtins.attrNames extensions ) ) } && true" ; } } &&
    export PATH=$PATH &&
    exec ${ pkgs.pass }/bin/pass $@ &&
    ${ pkgs.coreutils }/bin/true
    '' ;

    pass-completion = name : dot-gnupg : password-store-dir : pkgs.writeText "pass" ( builtins.replaceStrings [ "${ dollar }${ open-curly-bracket }PASSWORD_STORE_DIR:-$HOME/.password-store/${ close-curly-bracket }" "_pass" " pass" ] [ password-store-dir "_pass_${ builtins.hashString "sha512" name }" " ${ name }" ] ( builtins.readFile "${ pkgs.pass }/share/bash-completion/completions/pass" ) ) ;

    personal-identification-number = digits : uuid : structure ''
if [ ${ builtins.toString digits } -eq 0 ]
then
    ${ pkgs.coreutils }/bin/touch personal-identification-number.asc &&
        ${ pkgs.coreutils }/bin/true
else
    ${ pkgs.coreutils }/bin/cat /dev/urandom | ${ pkgs.coreutils }/bin/tr --delete --complement "0-9" | ${ pkgs.coreutils }/bin/fold --width ${ builtins.toString digits } | ${ pkgs.coreutils }/bin/head --lines 1 > personal-identification-number.asc &&
    ${ pkgs.coreutils }/bin/true
fi &&
    ${ pkgs.coreutils }/bin/true
    '' ;

    private = path : private-dir + ( "/" + path ) ;
    secret-file = dot-gnupg : password-store-dir : pass-name : "${ structure ''
export PASSWORD_STORE_GPG_OPTS="--homedir ${ dot-gnupg }" &&
    export PASSWORD_STORE_DIR=${ password-store-dir } &&
    ${ pkgs.pass }/bin/pass show ${ pass-name } > secret.asc &&
    ${ pkgs.coreutils }/bin/chmod 0400 secret.asc &&
    ${ pkgs.coreutils }/bin/true
    '' }/secret.asc" ;

    secret-value = dot-gnupg : password-store-dir : pass-name : "$( ${ pkgs.writeShellScriptBin "secret-value" ''
export PASSWORD_STORE_GPG_OPTS="--homedir ${ dot-gnupg } --pinentry-mode loopback --batch --passphrase-file $HOME/.gnupg-passphrase.asc" &&
    export PASSWORD_STORE_DIR=${ password-store-dir } &&
    ${ pkgs.pass }/bin/pass show ${ pass-name } &&
    ${ pkgs.coreutils }/bin/true
'' }/bin/secret-value )" ;

    sublime-project = home : project : ''
export HOME=${ home } &&
    exec ${ pkgs.sublime }/bin/sublime $@ ${ project } &&
    ${ pkgs.coreutils }/bin/true
    '' ;
} ;
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
 	    while ! ${ cfg.boot-secrets }/bin/boot-secrets show uuid
 	    do
 	        read -s -p "GNUPG PASSPHRASE? " GNUPG_PASSPHRASE &&
 	        echo $GNUPG_PASSPHRASE > $HOME/.gnupg-passphrase.asc &&
 		${ pkgs.coreutils }/bin/true
	    done &&
            export STRUCTURES_DIR=${ structures-dir } &&
	    export PRIVATE_DIR=${ private-dir } &&
	    ${ builtins.concatStringsSep "\n" ( builtins.map ( name : "export ${ environment-case name }=\"${ builtins.getAttr name cfg.variables }\" &&" ) ( builtins.attrNames cfg.variables ) ) }
	    ${ builtins.concatStringsSep "\n" ( builtins.map ( source : "source ${ source } &&" ) cfg.sources ) }
	    ${ pkgs.coreutils }/bin/true
    '' ;
    buildInputs = builtins.concatLists [ [ pkgs.pass ] ( builtins.map ( name : pkgs.writeShellScriptBin name ( builtins.getAttr name cfg.derivations ) ) ( builtins.attrNames cfg.derivations ) ) ] ;
}