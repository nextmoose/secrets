pkgs : tools : let
boot-gnupg = tools.dot-gnupg ( tools.private "gpg-private-keys.asc" ) ( tools.private "gpg-ownertrust.asc" ) ( tools.private "gpg2-private-keys.asc" ) ( tools.private "gpg2-ownertrust.asc" ) ;
boot-secret-file = pass-name : tools.secret-file boot-gnupg ( builtins.fetchGit { url = "https://github.com/nextmoose/secrets.git" ; } ) pass-name ;
report-personal-identification-number = tools.personal-identification-number 6 "35b2449c-b89a-4994-97f6-621436d161fc" ;
in {
    derivations = {
	boot-secrets = tools.pass ( tools.dot-gnupg ( tools.private "gpg-private-keys.asc" ) ( tools.private "gpg-ownertrust.asc" ) ( tools.private "gpg2-private-keys.asc" ) ( tools.private "gpg2-ownertrust.asc" ) ) ( builtins.fetchGit { url = https://github.com/nextmoose/secrets ; rev = "6e457eef3ac2004bed87130f968b1bdf6985df8c" ; ref = "c1780887-2bab-4bbe-bd2e-428dd192aa20" ; } )
 ;
	initialize-boot-secrets = tools.initialize-boot-secrets ( tools.private "gpg-private-keys.asc" ) ( tools.private "gpg-ownertrust.asc" ) ( tools.private "gpg2-private-keys.asc" ) ( tools.private "gpg2-ownertrust.asc" );
    } ;
    variables = {
        report-personal-identification-number = "$( ${ pkgs.coreutils }/bin/cat ${ tools.personal-identification-number 6 "35b2449c-b89a-4994-97f6-621436d161fc" }/personal-identification-number.asc )" ;
	personal-access-token = tools.secret-value boot-gnupg ( builtins.fetchGit { url = https://github.com/nextmoose/secrets ; rev = "6e457eef3ac2004bed87130f968b1bdf6985df8c" ; ref = "c1780887-2bab-4bbe-bd2e-428dd192aa20" ; } ) "personal-access-token" ;
	uuid = "41a38a57-ab6c-4533-944e-5a134b89c075" ;
    } ;
}