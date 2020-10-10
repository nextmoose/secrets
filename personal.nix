pkgs : structure : private : temporary-directory : dot-gnupg : let
in {
    derivations = {
        gpg = "exec ${ pkgs.gnupg }/bin/gpg --homedir ${ dot-gnupg ( private "gpg-private-keys.asc" ) ( private "gpg-ownertrust.asc" ) ( private "gpg2-private-keys.asc" ) ( private "gpg2-ownertrust.asc" ) }" ;
    } ;
}