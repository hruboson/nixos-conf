{ pkgs, lib, inputs, ... }:

{
	home.packages = lib.mkAfter (with pkgs; [
		firefox
	]);

	home.pointerCursor = let 
		getFrom = url: hash: name: {
			gtk.enable = true;
			x11.enable = true;
			name = name;
			size = 48;
			package = 
				pkgs.runCommand "moveUp" {} ''
				mkdir -p $out/share/icons
				ln -s ${pkgs.fetchzip {
					url = url;
					hash = hash;
				}} $out/share/icons/${name}
			'';
		};
	in
		getFrom 
		"https://github.com/polirritmico/Breeze-Dark-Cursor/releases/download/v1.0/Breeze_Dark_v1.0.tar.gz"
		"sha256-FgqS3rHJ4o5x4ONSaDZlQu1sFhefhWPk8vaBvURKZzY=" # get this hash by running nix store prefetch-file https://github/cursortheme/theme.tar.gz ... if this hash is wrong you wont be able to rebuild the system
		"Breeze-Dark";
	 
	#programs.zsh.promptInit = ''
	#	PROMPT="%F{blue}[ws]%f %~ %# "
	#'';
}
