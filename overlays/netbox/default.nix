{ lib, channels, ... }:

final: prev:

{
  netbox = lib.makeOverridable (
    args:
    (channels.unstable.netbox.override args).overrideAttrs (old: {
      postPatch = (old.postPatch or "") + ''
        for f in netbox/templates/inc/table.html \
                 netbox/templates/inc/table_htmx.html; do
          [ -f "$f" ] && substituteInPlace "$f" \
            --replace "querystring table.prefixed_order_by_field=" \
                      "querystring_replace table.prefixed_order_by_field="
        done
      '';
    })
  ) { };
}
