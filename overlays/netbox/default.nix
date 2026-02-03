{ channels, ... }:

final: prev:

{
  inherit (channels.unstable) netbox;
  netbox_4_5 = prev.netbox.overrideAttrs (old: {
    src = prev.fetchFromGitHub {
      owner = "netbox-community";
      repo = "netbox";
      tag = "v4.5.2";
      hash = "sha256-JGW7lw10mbYfU5C6+2GWalzIOTzo7nEs+MV3jM1vgIA=";
    };
  });
}
