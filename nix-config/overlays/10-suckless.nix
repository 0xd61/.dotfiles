self: super: {
  dmenu = super.dmenu.overrideAttrs (oldAttrs: rec {
    patches = [
      (super.fetchpatch {
        url = "https://raw.githubusercontent.com/0xd61/.dotfiles/master/suckless.conf.d/dmenu-5.0-backspace-delete-word.diff";
        sha256 = "0abqi59zp1ynmzmf0k524n4s589cnli07kxi2y9ngkyzhvbjav7k";
      })
    ];
    });

  dwm = super.dwm.overrideAttrs (oldAttrs: rec {
    patches = [
      (super.fetchpatch {
        url = "https://dwm.suckless.org/patches/fancybar/dwm-fancybar-20220527-d3f93c7.diff";
        sha256 = "twTkfKjOMGZCQdxHK0vXEcgnEU3CWg/7lrA3EftEAXc=";
      })
    ];
    configFile = self.writeText "config.def.h" (builtins.readFile
      (super.fetchurl {
        url = "https://raw.githubusercontent.com/0xd61/.dotfiles/master/suckless.conf.d/dwm-6.3.config.def.h";
        hash = "sha256-Umi0wlGqUxfHPEQffjiQu2yk0IWMiePXXupmcKds2XU=";
      })
    );
    postPatch = oldAttrs.postPatch or "" + "\necho 'Using own config file...'\n cp ${configFile} config.def.h";
  });

  st = super.st.overrideAttrs (oldAttrs: rec {
    patches = [
      (super.fetchpatch {
        url = "https://st.suckless.org/patches/scrollback/st-scrollback-0.8.5.diff";
        sha256 = "ZZAbrWyIaYRtw+nqvXKw8eXRWf0beGNJgoupRKsr2lc=";
      })
    ];
    configFile = self.writeText "config.def.h" (builtins.readFile
      (super.fetchurl {
        url = "https://raw.githubusercontent.com/0xd61/.dotfiles/master/suckless.conf.d/stterm-0.8.5.config.def.h";
        sha256 = "DLQUqfa8FDsff0m4ioZCKO4hVJ0vFKSLhvXmxOxvDf8=";
      })
    );
    postPatch = oldAttrs.postPatch or "" + "\necho 'Using own config file...'\n cp ${configFile} config.def.h";
  });

  surf = super.surf.overrideAttrs (oldAttrs: rec {
    patches = [
      (super.fetchpatch {
        url = "https://surf.suckless.org/patches/popup-on-gesture/surf-popup-2.0.diff";
        sha256 = "0zqf4cfzz5l0gqayj8xba6xqzzyc2ifqjclw0k7v4b4him9y3l3m";
      })
      (super.fetchpatch {
        url = "https://surf.suckless.org/patches/clipboard-instead-of-primary/surf-clipboard-20200112-a6a8878.diff";
        sha256 = "1rnqis9s9fqa4nj2c6mjzjxqcnlvcjmhmd39qf45z6lv77byb7rh";
      })
      (super.fetchpatch {
        url = "https://surf.suckless.org/patches/playexternal/surf-playexternal-20190724-b814567.diff";
        sha256 = "19r6mgsi47w0gy9hl4knkl8z65ghl42p9rb4pps0681wzn3hk2cz";
      })
      (super.fetchpatch {
        url = "https://raw.githubusercontent.com/0xd61/.dotfiles/master/suckless.conf.d/surf-2.1-history.diff";
        sha256 = "07fgh6msd3za79p5yf1g52kchvg4cfdxbrnzymr1ljq0wkcni8h5";
      })
      (super.fetchpatch {
        url = "https://raw.githubusercontent.com/0xd61/.dotfiles/master/suckless.conf.d/surf-2.1-spacesearch.diff";
        sha256 = "0mwwkqyqchq6n9r3x1qdpm4mvzcba257waf61h7hpjcqi41ql94i";
      })
      (super.fetchpatch {
        url = "https://raw.githubusercontent.com/0xd61/.dotfiles/master/suckless.conf.d/surf-2.1-hardware-acceleration.diff";
        sha256 = "1vgs7qii2yccvfghjd6phf3j12vslxwzr5sw2k8sfll2fvqxilq0";
      })
    ];
    configFile = self.writeText "config.def.h" (builtins.readFile
      (super.fetchurl {
        url = "https://raw.githubusercontent.com/0xd61/.dotfiles/master/suckless.conf.d/surf-2.1.config.def.h";
        sha256 = "0dk5kzdyg4lk64yg3d6311lmywzcf4z62h0blssyq3ymrg173sll";
      })
    );
    postPatch = oldAttrs.postPatch or "" + "\necho 'Using own config file...'\n cp ${configFile} config.def.h";
  });
}
