pkgs : {
  allowUnfree = true;
  packageOverrides = pkgs : with pkgs; rec {

    dglAll = pkgs.buildEnv {
      name = "dgl-all";
      paths = [
        st
        dwm
        SDL2
        google-chrome
        thunderbird
        discord
      ];
    };
  };
}
