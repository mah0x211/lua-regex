package = "regex"
version = "0.1.0-1"
source = {
    url = "git+https://github.com/mah0x211/lua-regex.git",
    tag = "v0.1.0"
}
description = {
    summary = "simple regular expression module for lua",
    homepage = "https://github.com/mah0x211/lua-regex",
    license = "MIT/X11",
    maintainer = "Masatoshi Fukunaga"
}
dependencies = {
    "lua >= 5.1",
    "pcre2 >= 0.1.0",
}
build = {
    type = "builtin",
    modules = {
        regex = "regex.lua"
    }
}
