pkgs : structure : temporary-directory : let
in {
    derivations = {
        brave = ''
exec ${ pkgs.brave }/bin/brave --user-data-dir ${ temporary-directory "59306cfc-4664-486d-9bd6-e70b9a0f8de1" } &&
    ${ pkgs.coreutils }/bin/true
	'' ;
    } ;
}