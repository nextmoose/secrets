pkgs : tools : let
boot-gnupg = tools.dot-gnupg ( tools.private "gpg-private-keys.asc" ) ( tools.private "gpg-ownertrust.asc" ) ( tools.private "gpg2-private-keys.asc" ) ( tools.private "gpg2-ownertrust.asc" ) ;
boot-secret-file = pass-name : tools.secret-file boot-gnupg ( builtins.fetchGit { url = https://github.com/nextmoose/secrets ; rev = "107cb5feff48dd958ed4770401362425f1de61b7" ; ref = "4904adbf-b29b-41a1-ae4c-f6c10aa692d0" ; } ) pass-name ;
boot-secret-value = pass-name : tools.secret-value boot-gnupg ( builtins.fetchGit { url = https://github.com/nextmoose/secrets ; rev = "107cb5feff48dd958ed4770401362425f1de61b7" ; ref = "4904adbf-b29b-41a1-ae4c-f6c10aa692d0" ; } ) pass-name ;
report-personal-identification-number = tools.personal-identification-number 6 "35b2449c-b89a-4994-97f6-621436d161fc" ;
in {
    derivations = {
	boot-secrets = tools.pass ( tools.dot-gnupg ( tools.private "gpg-private-keys.asc" ) ( tools.private "gpg-ownertrust.asc" ) ( tools.private "gpg2-private-keys.asc" ) ( tools.private "gpg2-ownertrust.asc" ) ) ( builtins.fetchGit { url = https://github.com/nextmoose/secrets ; rev = "107cb5feff48dd958ed4770401362425f1de61b7" ; ref = "4904adbf-b29b-41a1-ae4c-f6c10aa692d0" ; } )
 ;
	initialize-boot-secrets = tools.initialize-boot-secrets ( tools.private "gpg-private-keys.asc" ) ( tools.private "gpg-ownertrust.asc" ) ( tools.private "gpg2-private-keys.asc" ) ( tools.private "gpg2-ownertrust.asc" );
    } ;
    variables = {
        report-personal-identification-number = "$( ${ pkgs.coreutils }/bin/cat ${ tools.personal-identification-number 6 "35b2449c-b89a-4994-97f6-621436d161fc" }/personal-identification-number.asc )" ;
	personal-access-token = tools.secret-value boot-gnupg ( builtins.fetchGit { url = https://github.com/nextmoose/secrets ; rev = "107cb5feff48dd958ed4770401362425f1de61b7" ; ref = "4904adbf-b29b-41a1-ae4c-f6c10aa692d0" ; } ) "personal-access-token" ;
	dot-ssh = tools.dot-ssh { upstream = { hostname = "github.com" ; user = "git" ; identityfile = tools.github-ssh-key ( tools.personal-identification-number 0 "919ca63f-7f31-4f78-9dc4-3d65870dfe42" ) ( boot-secret-value "personal-access-key" )  ; userknownhostsfile = boot-secret-file "user-known-hosts" ; } ; personal = { hostname = "github.com" ; user = "git" ; identityfile = "personal-placeholder" ; userknownhostsfile = boot-secret-file "user-known-hosts" ; } ; report = { hostname = "github.com" ; user = "git" ; identityfile = "report-placeholder" ; userknownhostsfile = boot-secret-file "user-known-hosts" ; } ; } [ "/home/t8k3hcc7xdo3ww/.nix-shell/structures/R2ZAoLJ8/structure/config" ] ;
	uuid = "41a38a57-ab6c-4533-944e-5a134b89c075" ;
    } ;
}