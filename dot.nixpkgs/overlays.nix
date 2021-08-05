{ config, pkgs, lib, ... }:
{
  nixpkgs.overlays = [
    (self: super: {
      st = super.st.overrideAttrs (oldAttrs: rec {
        patches = [
          (super.fetchpatch {
            url = "https://st.suckless.org/patches/scrollback/st-scrollback-0.8.4.diff";
            sha256 = "0i0fav13sxnsydpllny26139gnzai66222502cplh18iy5fir3j1";
          })
        ];
        configFile = super.writeText "config.h" (builtins.readFile
          (super.fetchpatch {
            url = "https://raw.githubusercontent.com/0xd61/.dotfiles/master/suckless.conf.d/stterm-0.8.4.config.def.h";
            sha256 = "0r67y0nkdajiqsb3fr05x6dcpfzzyvn2i53g5rg7y0hx8b3d2mjd";
          })
        );
        postPatch = oldAttrs.postPatch or "" + "\necho 'Using own config file...'\n cp ${configFile} config.def.h";
        });

      dwm = super.dwm.overrideAttrs (oldAttrs: rec {
        patches = [
          (super.fetchpatch {
            url = "https://dwm.suckless.org/patches/fancybar/dwm-fancybar-6.2.diff";
            sha256 = "0bf55553p848g82jrmdahnavm9al6fzmd2xi1dgacxlwbw8j1xpz";
          })
        ];
        configFile = super.writeText "config.h" (builtins.readFile
          (super.fetchpatch {
            url = "https://raw.githubusercontent.com/0xd61/.dotfiles/master/suckless.conf.d/dwm-6.2.config.def.h";
            sha256 = "1wc5wqdj9g9pz4yywgw0k5aa6nkc07n15zmqb1i92s75phbyca52";
          })
        );
        postPatch = oldAttrs.postPatch or "" + "\necho 'Using own config file...'\n cp ${configFile} config.def.h";
      });
    })
  ];
}
