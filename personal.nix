pkgs : tools : let
boot-gnupg = tools.dot-gnupg ( tools.private "gpg-private-keys.asc" ) ( tools.private "gpg-ownertrust.asc" ) ( tools.private "gpg2-private-keys.asc" ) ( tools.private "gpg2-ownertrust.asc" ) ;
boot-secret-file = pass-name : tools.secret-file boot-gnupg bootit pass-name ;
boot-secret-value = pass-name : tools.secret-value boot-gnupg bootit pass-name ;
report-personal-identification-number = tools.personal-identification-number 6 "35b2449c-b89a-4994-97f6-621436d161fc" ;
bootit = builtins.fetchGit {
    url = https://github.com/nextmoose/secrets ;
    rev = "ab4a448c5b473387e328b45aa6ecd93c12eed04a" ;
    ref = "df8400df-08c0-4998-ac86-6ee210076eab" ;
} ;
uuidit = "9e530b62-813b-4731-85b6-d2c15dd426fb" ;
dot-ssh = tools.dot-ssh { upstream = { hostname = "github.com" ; user = "git" ; identityfile = tools.github-ssh-key "$( ${ pkgs.coreutils }/bin/cat ${ ( tools.personal-identification-number 0 "919ca63f-7f31-4f78-9dc4-3d65870dfe42" ) }/personal-identification-number.asc )" ( boot-secret-value "personal-access-token" ) ; userknownhostsfile = boot-secret-file "user-known-hosts" ; } ; personal = { hostname = "github.com" ; user = "git" ; identityfile = tools.github-ssh-key "$( ${ pkgs.coreutils }/bin/cat ${ ( tools.personal-identification-number 0 "03af63b1-e9a2-4927-8086-d46770ec9cf6" ) }/personal-identification-number.asc )" ( boot-secret-value "personal-access-token" ) ; userknownhostsfile = boot-secret-file "user-known-hosts" ; } ; report = { hostname = "github.com" ; user = "git" ; identityfile = tools.github-ssh-key "$( ${ pkgs.coreutils }/bin/cat ${ ( tools.personal-identification-number 6 "35b2449c-b89a-4994-97f6-621436d161fc" ) }/personal-identification-number.asc )" ( boot-secret-value "personal-access-token" ) ; userknownhostsfile = boot-secret-file "user-known-hosts" ; } ; } [ "/home/t8k3hcc7xdo3ww/.nix-shell/structures/R2ZAoLJ8/structure/config" ] ;
in {
    derivations = {
	boot-secrets = tools.pass ( tools.dot-gnupg ( tools.private "gpg-private-keys.asc" ) ( tools.private "gpg-ownertrust.asc" ) ( tools.private "gpg2-private-keys.asc" ) ( tools.private "gpg2-ownertrust.asc" ) ) bootit ;
	initialize-boot-secrets = tools.initialize-boot-secrets ( tools.private "gpg-private-keys.asc" ) ( tools.private "gpg-ownertrust.asc" ) ( tools.private "gpg2-private-keys.asc" ) ( tools.private "gpg2-ownertrust.asc" );
	boot-secrets-2 = tools.pass ( tools.dot-gnupg ( boot-secret-file "gpg-private-keys" ) ( boot-secret-file "gpg-ownertrust" ) ( boot-secret-file "gpg2-private-keys" ) ( boot-secret-file "gpg2-ownertrust" ) ) ( tools.fetch-git "${ dot-ssh }/config" "Emory Merryman" "emory.merryman@gmail.com" "upstream:nextmoose/secrets.git" "df8400df-08c0-4998-ac86-6ee210076eab" "personal:nextmoose/secrets.git" "report:nextmoose/secrets.git" ) ;
    } ;
    variables = {
        report-personal-identification-number = "$( ${ pkgs.coreutils }/bin/cat ${ report-personal-identification-number }/personal-identification-number.asc )" ;
	personal-access-token = tools.secret-value boot-gnupg bootit "personal-access-token" ;
	dot-ssh = dot-ssh ;
	uuid = "41a38a57-ab6c-4533-944e-5a134b89c075" ;
    } ;
}