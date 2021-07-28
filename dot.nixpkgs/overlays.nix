self: super:

{
  st = super.st.overrideAttrs (oldAttrs: rec {
      patches = [
        (fetchpatch {
          url = "https://st.suckless.org/patches/scrollback/st-scrollback-0.8.4.diff";
          sha256 = "418e1c5df11105482f13a008218c89eadb974630c25b4a6ff3da763dc2560e44";
        })
      ];
      configFile = super.writeText "config.h" (builtins.readFile
        (fetchFromGitHub {
          owner = "0xd61";
          repo = ".dotfiles";
          rev = "a17a696579d7b738afc774039b631c8671483aff";
          sha256 = "46936e146b21bd8024a69074258e79d31c8e196a470726984c437d5a4367a8c1";
        } + "/suckless.conf.d/stterm-0.8.4.config.def.h")
      );
      postPatch = oldAttrs.postPatch or "" + "\necho 'Using own config file...'\n cp ${configFile} config.def.h";
      });
  })

  dwm = super.dwm.overrideAttrs (oldAttrs: rec {
      patches = [
        (fetchpatch {
          url = "https://dwm.suckless.org/patches/fancybar/dwm-fancybar-6.1.diff";
          sha256 = "3a9e3b7c4e7fec9ac6a04be8518c8f25e93224d5afcc4427a47455999b42ecf4";
        })
      ];
      configFile = super.writeText "config.h" (builtins.readFile
        (fetchFromGitHub {
          owner = "0xd61";
          repo = ".dotfiles";
          rev = "a17a696579d7b738afc774039b631c8671483aff";
          sha256 = "46936e146b21bd8024a69074258e79d31c8e196a470726984c437d5a4367a8c1";
        } + "/suckless.conf.d/dwm-6.2.config.def.h")
      );
      postPatch = oldAttrs.postPatch or "" + "\necho 'Using own config file...'\n cp ${configFile} config.def.h";
      });
    })
}
