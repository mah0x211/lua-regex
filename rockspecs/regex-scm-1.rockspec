package = "regex"
version = "scm-1"
source = {
    url = "git+https://github.com/mah0x211/lua-regex.git"
}
description = {
    summary = "simple regular expression module for lua",
    homepage = "https://github.com/mah0x211/lua-regex",
    license = "MIT/X11",
    maintainer = "Masatoshi Fukunaga"
}
dependencies = {
    "lua >= 5.1",
    "pcre2",
}
build = {
    type = "builtin",
    modules = {
        regex = "regex.lua",
    }
}
