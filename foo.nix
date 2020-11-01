pkgs : structure : let
foo = ''
${ pkgs.coreutils }/bin/echo FOO > file.txt &&
    ${ pkgs.coreutils }/bin/true
'' ;
in {
    derivations = {
        foo = ''
${ pkgs.coreutils }/bin/echo ${ structure foo } &&
    ${ pkgs.coreutils }/bin/true
	'' ;
    } ;
}