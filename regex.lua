--[[

  Copyright (C) 2017 Masatoshi Teruya

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.

  regex.lua
  lua-regex
  Created by Masatoshi Teruya on 17/06/01.

--]]

--- file scope variables
local pcre2 = require('pcre2');
local unpack = unpack or table.unpack;
--- constants
local CFLG2OPT_LUT = {
    i = pcre2.CASELESS,     --: Do caseless matching.
    s = pcre2.DOTALL,       --: `.` matches anything including NL.
    m = pcre2.MULTILINE,    --: `^` and `$` match newlines within data.
    u = pcre2.UTF,          --: Treat pattern and subjects as UTF strings.
    x = pcre2.EXTENDED,     --: Ignore white space and `#` comments
};
--- static variables
local RECACHE = setmetatable({},{
    __mode = 'v'
});


--- flgs2opts
-- @param flgs
-- @param lut
-- @return opts
-- @return global
-- @return cache
-- @return jit
local function flgs2opts( flgs, lut )
    local opts = {};
    local global, cache, jit;

    if flgs then
        local nopt = 0;

        assert( type( flgs ) == 'string', 'flgs must be string' );
        for i = 1, #flgs do
            local flg = flgs:sub( i, i );

            -- jit compile flag
            if flg == 'j' then
                jit = true;
            -- global flag
            elseif flg == 'g' then
                global = true;
            -- compile-once mode flag
            elseif flg == 'o' then
                cache = true;
            -- do not check the pattern for UTF valid.
            -- only relevant if UTF option is set.
            elseif flg == 'U' then
                opts[nopt + 1] = pcre2.UTF;
                opts[nopt + 2] = pcre2.NO_UTF_CHECK;
                nopt = nopt + 2;
            else
                local opt = lut[flg];

                -- invalid flag
                if not opt then
                    error( ('unknown flag %q'):format( opt ) );
                end

                -- add option
                nopt = nopt + 1;
                opts[nopt] = opt;
            end
        end
    end

    return opts, global, cache, jit;
end


--- class Regex
local Regex = {};


--- matches
-- @param sbj
-- @param offset
-- @return arr
-- @return err
function Regex:matches( sbj, offset )
    local head, tail, err = self.p:match_nocap( sbj, offset );

    if err then
        return nil, err;
    -- found
    else
        local arr = {};
        local idx = 1;

        repeat
            arr[idx] = sbj:sub( head, tail );
            idx = idx + 1;

            head, tail, err = self.p:match_nocap( sbj, tail );
            if err then
                return nil, err;
            end
        until head == nil;

        return arr;
    end
end


--- match
-- @param sbj
-- @param offset
-- @return arr
-- @return err
function Regex:match( sbj, offset )
    local head, tail, err = self.p:match( sbj, offset or self.lastidx );

    -- found
    if head then
        local arr = {};

        for i = 1, #head do
            arr[i] = sbj:sub( head[i], tail[i] );
        end

        -- updaet a last-index if global option is enabled
        if self.global == true then
            self.lastidx = tail[1];
        end

        return arr;
    -- reset a last-index to 0 if global option is enabled
    elseif self.global then
        self.lastidx = 0;
    end

    return nil, err;
end


--- indexof
-- @param sbj
-- @param offset
-- @return heads
-- @return tails
-- @return err
function Regex:indexof( sbj, offset )
    local heads, tails, err = self.p:match( sbj, offset or self.lastidx );

    -- found
    if heads then
        -- updaet a last-index if global option is enabled
        if self.global == true then
            self.lastidx = tails[1];
        end

        return heads, tails;
    -- reset a last-index to 0 if global option is enabled
    elseif self.global then
        self.lastidx = 0;
    end

    return nil, nil, err;
end


--- test
-- @param sbj
-- @param offset
-- @return ok
-- @return err
function Regex:test( sbj, offset )
    local head, tail, err = self.p:match_nocap( sbj, offset or self.lastidx );

    -- found
    if head then
        -- updaet a last-index if global option is enabled
        if self.global == true then
            self.lastidx = tail;
        end

        return true;
    -- reset a last-index to 0 if global option is enabled
    elseif self.global then
        self.lastidx = 0;
    end

    return false, err;
end


--- new
-- @param pattern
-- @param flgs
-- @return regex
-- @return err
local function new( pattern, flgs )
    local opts, global, cache, jit, re;

    assert( type( pattern ) == 'string', 'pattern must be string' );
    -- parse flags
    opts, global, cache, jit = flgs2opts( flgs, CFLG2OPT_LUT );

    -- check the cache table
    if cache then
        cache = pattern .. '@' .. flgs;
        re = RECACHE[cache];
    end

    if not re then
        -- compile
        local p, err = pcre2.new( pattern, unpack( opts ) );

        if not p then
            return nil, err;
        -- jit compile
        elseif jit then
            local ok;

            ok, err = p:jit_compile();
            if not ok then
                return nil, err;
            end
        end

        -- create instance
        re = setmetatable({
            p = p,
            global = global,
            lastidx = 0
        }, {
            __index = Regex
        });

        -- save into cache table
        if cache then
            RECACHE[cache] = re;
        end
    end

    return re;
end


--- matches
-- @param sbj
-- @param pattern
-- @param flgs
-- @param offset
-- @return arr
-- @return err
local function matches( sbj, pattern, flgs, offset )
    local re, err = new( pattern, flgs );

    if err then
        return nil, err;
    end

    return re:matches( sbj, offset );
end


--- match
-- @param sbj
-- @param pattern
-- @param flgs
-- @param offset
-- @return arr
-- @return err
local function match( sbj, pattern, flgs, offset )
    local re, err = new( pattern, flgs );

    if err then
        return nil, err;
    end

    return re:match( sbj, offset );
end


--- test
-- @param sbj
-- @param pattern
-- @param flgs
-- @param offset
-- @return ok
-- @return err
local function test( sbj, pattern, flgs, offset )
    local re, err = new( pattern, flgs, offset );

    if err then
        return nil, err;
    end

    return re:test( sbj, offset );
end


return {
    new = new,
    matches = matches,
    match = match,
    test = test
};
