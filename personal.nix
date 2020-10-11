pkgs : structure : private : temporary-directory : dot-gnupg : secret-file : pass : let
boot-gnupg = dot-gnupg ( private "gpg-private-keys.asc" ) ( private "gpg-ownertrust.asc" ) ( private "gpg2-private-keys.asc" ) ( private "gpg2-ownertrust.asc" ) ;
boot-secret-file = pass-name : secret-file boot-gnupg ( builtins.fetchGit { url = "https://github.com/nextmoose/secrets.git" ; } ) pass-name "0400" ;
in {
    derivations = {
        gpg = "exec ${ pkgs.gnupg }/bin/gpg --homedir ${ dot-gnupg ( private "gpg-private-keys.asc" ) ( private "gpg-ownertrust.asc" ) ( private "gpg2-private-keys.asc" ) ( private "gpg2-ownertrust.asc" ) }" ;
	browser-secrets = ''
export PATH=$PATH:${ pkgs.pinentry }:${ pkgs.gpgme } &&
export PASSWORD_STORE_GPG_OPTS="--homedir ${ dot-gnupg ( private "gpg-private-keys.asc" ) ( private "gpg-ownertrust.asc" ) ( private "gpg2-private-keys.asc" ) ( private "gpg2-ownertrust.asc" ) }" &&
    export PASSWORD_STORE_DIR=${ builtins.fetchGit { url = "https://github.com/nextmoose/browser-secrets.git" ; } } &&
    exec ${ pkgs.pass }/bin/pass $@ &&
    ${ pkgs.coreutils }/bin/true
	'' ;
        bs = pass ( dot-gnupg ( boot-secret-file "gpg-private-keys" ) ( boot-secret-file "gpg-ownertrust" ) ( boot-secret-file "gpg2-private-keys" ) ( boot-secret-file "gpg2-ownertrust" ) ) ( builtins.fetchGit { url = "https://github.com/nextmoose/secrets.git" ; } ) ;
    } ;
}