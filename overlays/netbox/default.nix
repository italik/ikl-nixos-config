{ channels, ... }:

final: prev:

{
  inherit (channels.unstable) netbox;
  netbox_4_5 = prev.netbox.overrideAttrs (old: {
    src = prev.fetchFromGitHub {
      owner = "netbox-community";
      repo = "netbox";
      tag = "v4.5.1";
      hash = "sha256-d/Ne6twYrjmDdEcLwxol+vU+aqvTNnxka6je5nWxDas=";
    };
  });
}
