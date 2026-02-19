{ channels, ... }:

final: prev:

{
  inherit (channels.unstable) netbox;
  netbox_4_5 = prev.netbox.overrideAttrs (old: {
    src = prev.fetchFromGitHub {
      owner = "netbox-community";
      repo = "netbox";
      tag = "v4.5.3";
      hash = "sha256-mBEALlYmp3QCow+dmb0EsfaK6Sx2gd48cxa3QunYmMA=";
    };
  });
}
