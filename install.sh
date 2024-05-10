#!/bin/sh
# Lua module installation path
LUA_DIR="$PWD"
# Script installation path
INSTALL_DIR=~/.local/bin

[ "$LUA_DIR" != "$PWD" ] && cp -r pantograph "$LUA_DIR"
echo "#!/bin/sh" > pantograph.sh
echo "LUA_PATH=\";;$LUA_DIR/?.lua\"; lua $LUA_DIR/pantograph/main.lua \$@" >> pantograph.sh
chmod +x pantograph.sh
mv pantograph.sh "$INSTALL_DIR/pantograph"
