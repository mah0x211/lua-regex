# lua-regex

[![test](https://github.com/mah0x211/lua-regex/actions/workflows/test.yml/badge.svg)](https://github.com/mah0x211/lua-regex/actions/workflows/test.yml)
[![codecov](https://codecov.io/gh/mah0x211/lua-regex/branch/master/graph/badge.svg)](https://codecov.io/gh/mah0x211/lua-regex)


simple regular expression module for lua.


## Installation

```sh
luarocks install regex
```

***


## Regular expression flags

- `i`: Do caseless matching.
- `s`: `.` matches anything including NL.
- `m`: `^` and `$` match newlines within data.
- `u`: Treat pattern and subjects as UTF strings.
- `U`: Do not check the pattern for `UTF` valid.
- `x`: Ignore white space and `#` comments.
- `o`: compile-once mode that caching a compiled regex.
- `g`: global match.
- `j`: enable JIT compilation.


## Creating a Regex object

### re, err = regex.new( pattern [, flgs] )

creates a new regex object.

**Parameters**

- `pattern:string`: string containing expression to be compiled.
- `flgs:string`: [regular expression flags](#regular-expression-flags).

**Returns**

- `re:table`: regex object.
- `err:string`: error message.

**Example**

```lua
local regex = require('regex')
local re, err = regex.new('a(b+)(c+)', 'i')
if re then
    local arr, err = re:match('ABBBCCC')
    if arr then
        print(arr[1]) -- 'ABBBCCC'
        print(arr[2]) -- 'BBB'
        print(arr[3]) -- 'CCC'
    else
        print(err)
    end
else
    print(err)
end
```


## Instance Methods


## arr, err = regex:match( sbj [, offset] )

matches a compiled regular expression against a given subject string. It returns matched substrings.

**Parameters**

- `sbj:string`: the subject string.
- `offset:number`: offset in the subject at which to start matching.

**Returns**

- `arr:table`: array of matched substrings.
- `err:string`: error message.


## arr, err = regex:matches( sbj [, offset] )

almost same as `match` method but it returns all matched substrings except capture strings.

**Parameters**

- `sbj:string`: the subject string.
- `offset:number`: offset in the subject at which to start matching.

**Returns**

- `arr:table`: array of matched substrings.
- `err:string`: error message.


## arr, err = regex:indexof( sbj [, offset] )

almost same as `match` method but it returns offsets of matched substrings.

**Parameters**

- `sbj:string`: the subject string.
- `offset:number`: offset in the subject at which to start matching.

**Returns**

- `arr:table`: array of offsets of matched substrings. 1st index is the start offset of matched substring, and 2nd index is the end offset of matched substring, and 3rd index is the start offset of 1st capture string, and 4th index is the end offset of 1st capture string, and so on.
- `err:string`: error message.


## arr, err = regex:indexesof( sbj [, offset] )

almost same as `match` method but it returns all offsets of matched substrings **except capture strings**.

**Parameters**

- `sbj:string`: the subject string.
- `offset:number`: offset in the subject at which to start matching.

**Returns**

- `arr:table`: array of offsets of matched substrings. 1st index is the start offset of matched substring, and 2nd index is the end offset of matched substring, and so on.
- `err:string`: error message.


## ok, err = regex:test( sbj [, offset] )

returns true if there is a matched.

**Parameters**

- `sbj:string`: the subject string.
- `offset:number`: offset in the subject at which to start matching.

**Returns**

- `ok:boolean`: true on matched.
- `err:string`: error message.



## Static Methods


## arr, err = regex.match( sbj, pattern [, flgs [, offset]] )

same as the following code:

```lua
local re, err = regex.new( pattern, flgs )
if re then
    return re:match( sbj, offset )
end
return nil, err
```


## arr, err = regex.matches( sbj, pattern [, flgs [, offset]] )

same as the following code:

```lua
local re, err = regex.new( pattern, flgs )
if re then
    return re:matches( sbj, offset )
end
return nil, err
```


## arr, err = regex.indexof( sbj, pattern [, flgs [, offset]] )

same as the following code:

```lua
local re, err = regex.new( pattern, flgs )
if re then
    return re:indexof( sbj, offset )
end
return nil, err
```


## arr, err = regex.indexesof( sbj, pattern [, flgs [, offset]] )

same as the following code:

```lua
local re, err = regex.new( pattern, flgs )
if re then
    return re:indexesof( sbj, offset )
end
return nil, err
```


## ok, err = regex.test( sbj, pattern [, flgs [, offset]] )

same as the following code:

```lua
local re, err = regex.new( pattern, flgs )
if re then
    return re:test( sbj, offset )
end
return nil, err
```

