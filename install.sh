# Lua modules installation path, should be in your $LUA_PATH
LUA_DIR="$PWD"
# Script installation path
INSTALL_DIR=~/.local/bin

cp -r pantograph "$LUA_DIR"
echo "#!/bin/sh" > pantograph.sh
echo "lua $LUA_DIR/pantograph/main.lua \$@" >> pantograph.sh
chmod +x pantograph.sh
mv pantograph.sh "$INSTALL_DIR/pantograph"
