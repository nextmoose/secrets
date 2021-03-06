{ pkgs ? import <nixpkgs> { } } : let
	configuration = import ./configuration.nix ( structures : [

	] ) ;
in pkgs.mkShell {
	buildInputs = [
		pkgs.vscode

		pkgs.moreutils
	] ;
}
