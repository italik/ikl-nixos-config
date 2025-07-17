{ channels, ... }:

final: prev:

{
  inherit (channels.unstable) netbox;
  inherit (channels.unstable) netbox_4_3;
}
