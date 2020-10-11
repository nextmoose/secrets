pkgs : structure : private : temporary-directory : dot-gnupg : secret-file : pass : pass-kludge : let
boot-gnupg = dot-gnupg ( private "gpg-private-keys.asc" ) ( private "gpg-ownertrust.asc" ) ( private "gpg2-private-keys.asc" ) ( private "gpg2-ownertrust.asc" ) ;
boot-secret-file = pass-name : secret-file boot-gnupg ( builtins.fetchGit { url = "https://github.com/nextmoose/secrets.git" ; } ) pass-name "0400" ;
in {
    derivations = {
        gpg = "exec ${ pkgs.gnupg }/bin/gpg --homedir /home/t8k3hcc7xdo3ww/.gnupg $@" ; 
	pass-kludge = pass-kludge ( dot-gnupg ( private "gpg-private-keys.asc" ) ( private "gpg-ownertrust.asc" ) ( private "gpg2-private-keys.asc" ) ( private "gpg2-ownertrust.asc" ) ) ( builtins.fetchGit { url = "https://github.com/nextmoose/secrets.git" ; } ) ;
	pass-test = pass ( dot-gnupg ( private "gpg-private-keys.asc" ) ( private "gpg-ownertrust.asc" ) ( private "gpg2-private-keys.asc" ) ( private "gpg2-ownertrust.asc" ) ) ( builtins.fetchGit { url = "https://github.com/nextmoose/secrets.git" ; } ) ;
    } ;
}