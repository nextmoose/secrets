pkgs : tools : let
boot-gnupg = tools.dot-gnupg ( tools.private "gpg-private-keys.asc" ) ( tools.private "gpg-ownertrust.asc" ) ( tools.private "gpg2-private-keys.asc" ) ( tools.private "gpg2-ownertrust.asc" ) ;
boot-secret-file = pass-name : tools.secret-file boot-gnupg ( builtins.fetchGit { url = "https://github.com/nextmoose/secrets.git" ; } ) pass-name "0400" ;
in {
    derivations = {
	pass-test = tools.pass ( tools.dot-gnupg ( tools.private "gpg-private-keys.asc" ) ( tools.private "gpg-ownertrust.asc" ) ( tools.private "gpg2-private-keys.asc" ) ( tools.private "gpg2-ownertrust.asc" ) ) ( builtins.fetchGit { url = "https://github.com/nextmoose/secrets.git" ; } ) ;
    } ;
}