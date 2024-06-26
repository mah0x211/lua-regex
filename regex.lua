--
-- Copyright (C) Masatoshi Fukunaga
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
--
-- regex.lua
-- lua-regex
-- Created by Masatoshi Teruya on 17/06/01.
--
--- file scope variables
local unpack = unpack or table.unpack
local sub = string.sub
local type = type
local pcre2 = require('pcre2')
--- constants
local CFLG2OPT_LUT = {
    i = pcre2.CASELESS, -- : Do caseless matching.
    s = pcre2.DOTALL, -- : `.` matches anything including NL.
    m = pcre2.MULTILINE, -- : `^` and `$` match newlines within data.
    u = pcre2.UTF, -- : Treat pattern and subjects as UTF strings.
    x = pcre2.EXTENDED, -- : Ignore white space and `#` comments
}
--- static variables
local RECACHE = setmetatable({}, {
    __mode = 'v',
})

--- flags2opts
--- @param flags string
--- @return table opts
--- @return boolean global
--- @return boolean cache
--- @return boolean jit
local function flags2opts(flags)
    local opts = {}
    local global = false
    local cache = false
    local jit = false
    local nopt = 0

    for i = 1, #flags do
        local flg = sub(flags, i, i)

        if flg == 'j' then
            -- jit compile flag
            jit = true
        elseif flg == 'g' then
            -- global flag
            global = true
        elseif flg == 'o' then
            -- compile-once mode flag
            cache = true
        elseif flg == 'U' then
            -- do not check the pattern for UTF valid.
            -- only relevant if UTF option is set.
            opts[nopt + 1] = pcre2.UTF
            opts[nopt + 2] = pcre2.NO_UTF_CHECK
            nopt = nopt + 2
        else
            local opt = CFLG2OPT_LUT[flg]
            if not opt then
                -- invalid flag
                error(('unknown flag %q'):format(flg))
            end

            -- add option
            nopt = nopt + 1
            opts[nopt] = opt
        end
    end

    return opts, global, cache, jit
end

--- @class regex
--- @field p pcre2
--- @field global boolean
--- @field lastidx integer
local Regex = {}

--- init
--- @param pattern string
--- @param flags string?
--- @return regex? regex
--- @return any err
function Regex:init(pattern, flags)
    assert(type(pattern) == 'string', 'pattern must be string')
    assert(flags == nil or type(flags) == 'string',
           'flags must be string or nil')
    if not flags then
        flags = ''
    end

    -- parse flags
    local cache_key = pattern .. '@' .. flags
    local opts, global, cache, jit = flags2opts(flags)
    -- check the cache table
    if cache then
        -- return the cached object if exists
        local re = RECACHE[cache_key]
        if re then
            return re
        end
    end

    -- compile pattern
    local p, err = pcre2.new(pattern, unpack(opts))
    if not p then
        return nil, err
    elseif jit then
        -- jit compile
        local ok
        ok, err = p:jit_compile()
        if not ok then
            return nil, err
        end
    end
    self.p = p
    self.global = global
    self.lastidx = 0

    -- save into cache table
    if cache then
        RECACHE[cache_key] = self
    end

    return self
end

--- matches
--- @param sbj string
--- @param offset integer
--- @return string[]? arr
--- @return any err
function Regex:matches(sbj, offset)
    local head, tail, err = self.p:match_nocap(sbj, offset)

    if head then
        local arr = {}
        local idx = 1

        while head do
            arr[idx] = sub(sbj, head, tail)
            idx = idx + 1
            head, tail, err = self.p:match_nocap(sbj, tail)
        end
        if err then
            return nil, err
        end

        return arr
    end

    return nil, err
end

--- match
--- @param sbj string
--- @param offset integer?
--- @return string[]? arr
--- @return any err
function Regex:match(sbj, offset)
    local heads, tails, err = self.p:match(sbj, offset or self.lastidx)

    if heads then
        -- found
        local arr = {}
        for i = 1, #heads do
            arr[i] = sub(sbj, heads[i], tails[i])
        end

        -- updaet a last-index if global option is enabled
        if self.global == true then
            self.lastidx = tails[1]
        end
        return arr
    elseif err then
        return nil, err
    elseif self.global then
        -- reset a last-index to 0 if global option is enabled
        self.lastidx = 0
    end
end

--- indexesof
--- @param sbj string
--- @param offset? integer
--- @return integer[]? arr
--- @return any err
function Regex:indexesof(sbj, offset)
    local head, tail, err = self.p:match_nocap(sbj, offset)

    if head then
        local arr = {}
        local idx = 1

        while head do
            arr[idx], arr[idx + 1] = head, tail
            idx = idx + 2
            head, tail, err = self.p:match_nocap(sbj, tail)
        end

        if err then
            return nil, err
        end

        return arr
    elseif err then
        return nil, err
    end
end

--- indexof
--- @param sbj string
--- @param offset? integer
--- @return integer[]? arr
--- @return any err
function Regex:indexof(sbj, offset)
    local heads, tails, err = self.p:match(sbj, offset or self.lastidx)

    if heads then
        local arr = {}
        local idx = 1

        for i = 1, #heads do
            arr[idx], arr[idx + 1] = heads[i], tails[i]
            idx = idx + 2
        end

        -- updaet a last-index if global option is enabled
        if self.global == true then
            self.lastidx = tails[1]
        end

        return arr
    elseif err then
        return nil, err
    elseif self.global then
        -- reset a last-index to 0 if global option is enabled
        self.lastidx = 0
    end
end

--- test
--- @param sbj string
--- @param offset integer?
--- @return boolean ok
--- @return any err
function Regex:test(sbj, offset)
    local head, tail, err = self.p:match_nocap(sbj, offset or self.lastidx)

    -- found
    if head then
        -- updaet a last-index if global option is enabled
        if self.global == true then
            self.lastidx = tail
        end
        return true
    elseif self.global then
        -- reset a last-index to 0 if global option is enabled
        self.lastidx = 0
    end

    return false, err
end

Regex = require('metamodule').new(Regex)

--- matches
--- @param sbj string
--- @param pattern string
--- @param flags? string
--- @param offset? integer
--- @return string[]? arr
--- @return any err
local function matches(sbj, pattern, flags, offset)
    local re, err = Regex(pattern, flags)
    if re then
        return re:matches(sbj, offset)
    end
    return nil, err
end

--- match
--- @param sbj string
--- @param pattern string
--- @param flags? string
--- @param offset? integer
--- @return string[]? arr
--- @return any err
local function match(sbj, pattern, flags, offset)
    local re, err = Regex(pattern, flags)
    if re then
        return re:match(sbj, offset)
    end
    return nil, err
end

--- indexesof
--- @param sbj string
--- @param pattern string
--- @param flags? string
--- @param offset? integer
--- @return integer[]? arr
--- @return any err
local function indexesof(sbj, pattern, flags, offset)
    local re, err = Regex(pattern, flags)
    if re then
        return re:indexesof(sbj, offset)
    end
    return nil, err
end

--- indexof
--- @param sbj string
--- @param pattern string
--- @param flags? string
--- @param offset? integer
--- @return integer[]? arr
--- @return any err
local function indexof(sbj, pattern, flags, offset)
    local re, err = Regex(pattern, flags)
    if re then
        return re:indexof(sbj, offset)
    end
    return nil, err
end

--- test
--- @param sbj string
--- @param pattern string
--- @param flags? string
--- @param offset? integer
--- @return boolean ok
--- @return any err
local function test(sbj, pattern, flags, offset)
    local re, err = Regex(pattern, flags)
    if re then
        return re:test(sbj, offset)
    end
    return false, err
end

return {
    new = Regex,
    matches = matches,
    match = match,
    indexesof = indexesof,
    indexof = indexof,
    test = test,
}
