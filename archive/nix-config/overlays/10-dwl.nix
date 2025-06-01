self: super: {
  dwl = super.dwl.overrideAttrs (oldAttrs: rec {
    enable-xwayland = true;
    configFile = self.writeText "config.def.h" (builtins.readFile
      (super.fetchurl {
        url = "https://raw.githubusercontent.com/0xd61/.dotfiles/master/suckless.conf.d/dwl-0.2.2.config.def.h";
        hash = "sha256-WopZLgeXpBjdyrMcUlwe/GzcVZP+k8jssHAC7cpaypM=";
      })
    );
    postPatch = oldAttrs.postPatch or "" + "\necho 'Using own config file...'\n cp ${configFile} config.def.h";
  });
}
