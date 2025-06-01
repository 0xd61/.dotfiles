self: super: {
  dwl = super.spice-gtk.overrideAttrs (oldAttrs: rec {
    withPolkit = true;
  });
}
