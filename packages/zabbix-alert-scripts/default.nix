{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "send-sms-via-clickatell";

  runtimeInputs = [
    pkgs.coreutils
    pkgs.curl
  ];

  text = ''
    to=$1
    text=$2
    userfile=$3
    passwordfile=$4
    api_idfile=$5

    user=$(cat "$userfile")
    password=$(cat "$passwordfile")
    api_id=$(cat "$api_idfile")

    url=https://api.clickatell.com/http/sendmsg

    curl -G "$url" \
      --data-urlencode user="$user" \
      --data-urlencode password="$password" \
      --data-urlencode api_id="$api_id" \
      --data-urlencode to="$to" \
      --data-urlencode text="$text"
  '';
}
