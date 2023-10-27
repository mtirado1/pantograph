# Lua modules installation path, should be in your $LUA_PATH
LUA_DIR="/usr/local/share/lua/5.3"
# Script installation path
INSTALL_DIR="/usr/local/bin"

cp -r pantograph "$LUA_DIR"
echo "#!/bin/sh\nlua $LUA_DIR/pantograph/main.lua \$@" > pantograph.sh
chmod +x pantograph.sh
mv pantograph.sh "$INSTALL_DIR/pantograph"
