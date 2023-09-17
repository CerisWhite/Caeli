# Caeli
A work-in-progress "anime game™" server emulator, written in Lua using Luvit.

### Setup
To run, install:
- [Luvit](https://luvit.io/install.html)
- Build tools for your platform
- The "all-in-one.proto" from a certain repository.

1) `lit install mooncake`
2) Compile [Lua 5.1.5](https://www.lua.org/ftp/lua-5.1.5.tar.gz) and install it. If on Windows, you will need the `lua51.lib` file to compile lua-protobuf.
3) Compile [lua-protobuf](https://github.com/starwing/lua-protobuf) and place the resulting .dll or .so in the `deps` folder.
4) Add your proto file(s) to `Library/Proto`.
5) Copy the remaining libraries from `Library/External` into `deps` and then `luvit ./Caeli.lua`. If all goes well, your server should start.
6) Modify the conf.json file as you see fit, then restart for the changes to take effect.

--- More features to come soon ---