After installing, create a file `sec.conf`

#
# weechat -- sec.conf
#
# WARNING: It is NOT recommended to edit this file by hand,
# especially if WeeChat is running.
#
# Use /set or similar command to change settings in WeeChat.
#
# For more info, see: https://weechat.org/doc/quickstart
#

[crypt]
cipher = aes256
hash_algo = sha256
passphrase_file = ""
salt = on

[data]
__passphrase__ = off
nick = "<nick>"
handmade_password = "<password>"
oftc_password = "<password>"
freenode_password = "<password>"
hackint_password = "<password>"

