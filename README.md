# lua-regex

regular expression for lua.

**NOTE:** this module is under heavy development.


## Dependencies

- lua-pcre2: <https://github.com/mah0x211/lua-pcre2>

---

## regex module

```lua
local regex = require('regex')
```


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

**Params**

- `pattern:string`: string containing expression to be compiled.
- `flgs:string`: [regular expression flags](#regular-expression-flags).

**Returns**

- `re:table`: regex object.
- `err:string`: error message.


## Instance Methods


### arr, err = re:match( sbj [, offset] )

matches a compiled regular expression against a given subject string. It returns matched substrings.

**Params**

- `sbj:string`: the subject string.
- `offset:number`: offset in the subject at which to start matching.

**Returns**

- `arr:table`: array of matched substrings.
- `err:string`: error message.


### arr, err = re:matches( sbj [, offset] )

almost same as `match` method but it returns all matched substrings except capture strings.

**Params**

- `sbj:string`: the subject string.
- `offset:number`: offset in the subject at which to start matching.

**Returns**

- `arr:table`: array of matched substrings.
- `err:string`: error message.


### heads, tails, err = re:indexof( sbj [, offset] )

almost same as `match` method but it returns offsets of matched substrings.

**Params**

- `sbj:string`: the subject string.
- `offset:number`: offset in the subject at which to start matching.

**Returns**

- `heads:table`: array of head offset of matched substrings.
- `tails:table`: array of tail offset of matched substrings.
- `err:string`: error message.


### heads, tails, err = re:indexesof( sbj [, offset] )

almost same as `match` method but it returns all offsets of matched substrings except capture strings.

**Params**

- `sbj:string`: the subject string.
- `offset:number`: offset in the subject at which to start matching.

**Returns**

- `heads:table`: array of head offset of matched substrings.
- `tails:table`: array of tail offset of matched substrings.
- `err:string`: error message.


### ok, err = re:test( sbj [, offset] )

returns true if there is a matched.

**Params**

- `sbj:string`: the subject string.
- `offset:number`: offset in the subject at which to start matching.

**Returns**

- `ok:boolean`: true on matched.
- `err:string`: error message.



## Static Methods


### arr, err = regex.match( sbj, pattern [, flgs [, offset]] )

same as `match` instance method.

**Params**

- `sbj:string`: the subject string.
- `pattern:string`: string containing expression to be compiled.
- `flgs:string`: [regular expression flags](#regular-expression-flags).
- `offset:number`: offset in the subject at which to start matching.

**Returns**

- `arr:table`: array of matched substrings.
- `err:string`: error message.


### arr, err = regex.matches( sbj, pattern [, flgs [, offset]] )

same as `matches` instance method.

**Params**

- `sbj:string`: the subject string.
- `pattern:string`: string containing expression to be compiled.
- `flgs:string`: [regular expression flags](#regular-expression-flags).
- `offset:number`: offset in the subject at which to start matching.

**Returns**

- `arr:table`: array of matched substrings.
- `err:string`: error message.


### heads, tails, err = regex.indexof( sbj, pattern [, flgs [, offset]] )

same as `indexof` instance method.

**Params**

- `sbj:string`: the subject string.
- `pattern:string`: string containing expression to be compiled.
- `flgs:string`: [regular expression flags](#regular-expression-flags).
- `offset:number`: offset in the subject at which to start matching.

**Returns**

- `heads:table`: array of head offset of matched substrings.
- `tails:table`: array of tail offset of matched substrings.
- `err:string`: error message.


### heads, tails, err = regex.indexesof( sbj, pattern [, flgs [, offset]] )

same as `indexesof` instance method.

**Params**

- `sbj:string`: the subject string.
- `pattern:string`: string containing expression to be compiled.
- `flgs:string`: [regular expression flags](#regular-expression-flags).
- `offset:number`: offset in the subject at which to start matching.

**Returns**

- `heads:table`: array of head offset of matched substrings.
- `tails:table`: array of tail offset of matched substrings.
- `err:string`: error message.


### ok, err = regex.test( sbj, pattern [, flgs [, offset]] )

same as `test` instance method.

**Params**

- `sbj:string`: the subject string.
- `pattern:string`: string containing expression to be compiled.
- `flgs:string`: [regular expression flags](#regular-expression-flags).
- `offset:number`: offset in the subject at which to start matching.

**Returns**

- `ok:boolean`: true on matched.
- `err:string`: error message.

