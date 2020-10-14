pkgs : tools : let
boot-gnupg = tools.dot-gnupg ( tools.private "gpg-private-keys.asc" ) ( tools.private "gpg-ownertrust.asc" ) ( tools.private "gpg2-private-keys.asc" ) ( tools.private "gpg2-ownertrust.asc" ) ;
boot-secret-file = pass-name : tools.secret-file boot-gnupg ( builtins.fetchGit { url = "https://github.com/nextmoose/secrets.git" ; } ) pass-name ;

in {
    derivations = {
	boot-secrets = tools.pass ( tools.dot-gnupg ( tools.private "gpg-private-keys.asc" ) ( tools.private "gpg-ownertrust.asc" ) ( tools.private "gpg2-private-keys.asc" ) ( tools.private "gpg2-ownertrust.asc" ) ) ( builtins.fetchGit { url = "https://github.com/nextmoose/secrets.git" ; } ) ;
	initialize = tools.initialize ;
    } ;
    variables = {
        report-personal-identification-number = "$( ${ pkgs.coreutils }/bin/cat ${ tools.personal-identification-number 6 }/personal-identification-number.asc )" ;
    } ;
}