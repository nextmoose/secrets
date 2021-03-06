{ pkgs ? import <nixpkgs> { } } : pkgs.mkShell {
	buildIncludes = [
		pkgs.vscode
	] ;
}
