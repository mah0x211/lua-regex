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


--- flgs2opts
-- @param flgs
-- @param lut
-- @return opts
-- @return jit
-- @return sticky
local function flgs2opts( flgs, lut )
    if flgs then
        local opts = {};
        local nopt = 0;
        local jit, sticky;

        assert( type( flgs ) == 'string', 'flgs must be string' );
        for i = 1, #flgs do
            local flg = flgs:sub( i, i );

            -- jit compile flag
            if flg == 'j' then
                jit = true;
            -- sticky flag
            elseif flg == 'y' then
                sticky = true;
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

        return nopt > 0 and opts, jit, sticky;
    end
end


--- class Regex
local Regex = {};


--- gmatch
-- @param sbj
-- @return arr
-- @return err
function Regex:gmatch( sbj )
    local head, tail, err = self.p:match_nocap( sbj );

    if err then
        return nil, err;
    -- matched
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
-- @return arr
-- @return err
function Regex:match( sbj )
    local head, tail, err = self.p:match( sbj );

    -- matched
    if head then
        local arr = {};

        for i = 1, #head do
            arr[i] = sbj:sub( head[i], tail[i] );
        end

        return arr;
    end

    return nil, err;
end


--- new
-- @param pattern
-- @param flgs
-- @return regex
-- @return err
local function new( pattern, flgs )
    local opts, jit, sticky = flgs2opts( flgs, CFLG2OPT_LUT );
    local p, err;

    -- compile
    p, err = pcre2.new( pattern, unpack( opts ) );
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
    return setmetatable({
        p = p,
        sticky = sticky
    }, {
        __index = Regex
    });
end


return {
    new = new
};
