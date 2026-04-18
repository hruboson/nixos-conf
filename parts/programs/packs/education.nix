{ self, inputs, ... }: {
	flake.nixosModules.appPackEducation = { config, lib, pkgs, username, ... }: { 
		environment.systemPackages = with pkgs; [
			anki
		];

		environment.etc."mime.types".source = lib.mkForce (pkgs.writeText "mime.types" ''
			application/x-apkg  apkg
		'');

		xdg.mime.addedAssociations = {
			"application/x-apkg" = "anki.desktop";
		};

		home-manager.users.${username} = {
			# File types -> app associations
			# mimetype.io/all-types
			xdg.mimeApps = {
				enable = true;
				defaultApplications = {
					"application/x-apkg" = "anki.desktop";
				};
			};

			xdg.dataFile."mime/packages/anki.xml".text = ''
				<mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
				  <mime-type type="application/x-apkg">
					<comment>Anki Deck Package</comment>
					<glob pattern="*.apkg"/>
					<magic priority="60">
					  <match type="string" offset="0" value="PK"/>
					</magic>
				  </mime-type>
				</mime-info>
			'';
			xdg.dataFile."icons/hicolor/scalable/mimetypes/anki-apkg.svg".source =
				"${pkgs.anki}/share/pixmaps/anki.png";

			xdg.dataFile."icons/hicolor/48x48/mimetypes/anki-apkg.png".source =
				"${pkgs.anki}/share/pixmaps/anki.png";
		};
	};
}
