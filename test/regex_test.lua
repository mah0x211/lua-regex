require('luacov')
local testcase = require('testcase')
local assert = require('assert')
local regex = require('regex')

function testcase.new()
    -- test that create a new regex object
    local re, err = regex.new('abc', 'ismxgojU')
    assert.is_nil(err)
    assert.match(re, '^regex: ', false)

    -- test that return error if failed to compile pattern
    re, err = regex.new('abc(')
    assert.is_nil(re)
    assert.match(err, 'compilation failed')

    -- test that throws error if pattern is not string
    err = assert.throws(regex.new, 123)
    assert.match(err, 'pattern must be string')

    -- test that throws error if flags is not string
    err = assert.throws(regex.new, 'abc', 123)
    assert.match(err, 'flags must be string or nil')

    -- test that throws error if unknown flag is provided
    err = assert.throws(regex.new, 'abc', 'v')
    assert.match(err, 'unknown flag "v"')
end

function testcase.matches_method()
    local re = assert(regex.new('[a-z]+([08]\\d*)'))
    local sbj = 'abcd0123efg4567hijk890'

    -- test that return matches in string array
    local arr, err = re:matches(sbj)
    assert.is_nil(err)
    assert.equal(arr, {
        'abcd0123',
        'hijk890',
    })

    -- test that exec matches with offset
    arr, err = re:matches(sbj, 6)
    assert.is_nil(err)
    assert.equal(arr, {
        'hijk890',
    })

    -- test that return nil and error if invalid offset
    arr, err = re:matches(sbj, -1)
    assert.match(err, 'offset')
    assert.is_nil(arr)

    -- test that throws error if subject is not string
    err = assert.throws(re.matches, re, 123)
    assert.match(err, 'string expected')

    -- test that throws error if offset is not integer
    err = assert.throws(re.matches, re, sbj, 1.23)
    assert.match(err, 'integer expected')
end

function testcase.matches()
    local sbj = 'abcd0123efg4567hijk890'
    local pattern = '[a-z]+([08]\\d*)'

    -- test that return matches in string array
    local arr, err = regex.matches(sbj, pattern, nil, 6)
    assert.is_nil(err)
    assert.equal(arr, {
        'hijk890',
    })

    -- test that return nil and error if invalid pattern
    arr, err = regex.matches(sbj, 'abc(', nil, 1)
    assert.match(err, 'compilation failed')
    assert.is_nil(arr)

    -- test that return nil and error if invalid offset
    arr, err = regex.matches(sbj, pattern, nil, -1)
    assert.match(err, 'offset')
    assert.is_nil(arr)

    -- test that throws error if subject is not string
    err = assert.throws(regex.matches, 123, pattern)
    assert.match(err, 'string expected')

    -- test that throws error if offset is not integer
    err = assert.throws(regex.matches, sbj, pattern, nil, 1.23)
    assert.match(err, 'integer expected')
end

function testcase.match_method()
    local re = assert(regex.new('[a-z]+([08]\\d*)'))
    local sbj = 'abcd0123efg4567hijk890'

    -- test that return first match in string array
    local arr, err = re:match(sbj)
    assert.is_nil(err)
    assert.equal(arr, {
        'abcd0123',
        '0123',
    })

    -- test that always return first matches if global flag is not set
    arr, err = re:match(sbj)
    assert.is_nil(err)
    assert.equal(arr, {
        'abcd0123',
        '0123',
    })

    -- test that exec matches with offset
    arr, err = re:match(sbj, 6)
    assert.is_nil(err)
    assert.equal(arr, {
        'hijk890',
        '890',
    })

    -- test that return next matches if global flag is set
    re = assert(regex.new('[a-z]+([08]\\d*)', 'g'))
    for i, exp in ipairs({
        {
            'abcd0123',
            '0123',
        },
        {
            'hijk890',
            '890',
        },
        {},
    }) do
        arr, err = re:match(sbj)
        if i == 3 then
            assert.is_nil(arr)
            assert.is_nil(err)
        else
            assert.is_nil(err)
            assert.equal(arr, exp)
        end
    end

    -- test that return nil and error if invalid offset
    arr, err = re:match(sbj, -1)
    assert.match(err, 'offset')
    assert.is_nil(arr)

    -- test that throws error if subject is not string
    err = assert.throws(re.match, re, 123)
    assert.match(err, 'string expected')

    -- test that throws error if offset is not integer
    err = assert.throws(re.match, re, sbj, 1.23)
    assert.match(err, 'integer expected')
end

function testcase.match()
    local sbj = 'abcd0123efg4567hijk890'
    local pattern = '[a-z]+([08]\\d*)'

    -- test that return first match in string array
    local arr, err = regex.match(sbj, pattern, nil, 6)
    assert.is_nil(err)
    assert.equal(arr, {
        'hijk890',
        '890',
    })

    -- test that return nil and error if invalid pattern
    arr, err = regex.match(sbj, 'abc(', nil, 1)
    assert.match(err, 'compilation failed')
    assert.is_nil(arr)

    -- test that return nil and error if invalid offset
    arr, err = regex.match(sbj, pattern, nil, -1)
    assert.match(err, 'offset')
    assert.is_nil(arr)

    -- test that throws error if subject is not string
    err = assert.throws(regex.match, 123, pattern)
    assert.match(err, 'string expected')

    -- test that throws error if offset is not integer
    err = assert.throws(regex.match, sbj, pattern, nil, 1.23)
    assert.match(err, 'integer expected')
end

function testcase.indexesof_method()
    local re = assert(regex.new('[a-z]+([08]\\d*)'))
    local sbj = 'abcd0123efg4567hijk890'

    -- test that return indexes of matches in integer array
    local arr, err = re:indexesof(sbj)
    assert.is_nil(err)
    assert.equal(arr, {
        -- 1st match 'abcd0123'
        1,
        8,
        -- 2nd match 'hijk890' and capture '890'
        16,
        22,
    })

    -- test that return nil and error if invalid offset
    arr, err = re:indexesof(sbj, -1)
    assert.match(err, 'offset')
    assert.is_nil(arr)

    -- test that throws error if subject is not string
    err = assert.throws(re.indexesof, re, 123)
    assert.match(err, 'string expected')

    -- test that throws error if offset is not integer
    err = assert.throws(re.indexesof, re, sbj, 1.23)
    assert.match(err, 'integer expected')
end

function testcase.indexesof()
    local sbj = 'abcd0123efg4567hijk890'
    local pattern = '[a-z]+([08]\\d*)'

    -- test that return indexes of matches in integer array
    local arr, err = regex.indexesof(sbj, pattern)
    assert.is_nil(err)
    assert.equal(arr, {
        -- 1st match 'abcd0123'
        1,
        8,
        -- 2nd match 'hijk890' and capture '890'
        16,
        22,
    })

    -- test that return nil and error if invalid pattern
    arr, err = regex.indexesof(sbj, 'abc(', nil, 1)
    assert.match(err, 'compilation failed')
    assert.is_nil(arr)

    -- test that return nil and error if invalid offset
    arr, err = regex.indexesof(sbj, pattern, nil, -1)
    assert.match(err, 'offset')
    assert.is_nil(arr)

    -- test that throws error if subject is not string
    err = assert.throws(regex.indexesof, 123, pattern)
    assert.match(err, 'string expected')

    -- test that throws error if offset is not integer
    err = assert.throws(regex.indexesof, sbj, pattern, nil, 1.23)
    assert.match(err, 'integer expected')
end

function testcase.indexof_method()
    local re = assert(regex.new('[a-z]+([08]\\d*)'))
    local sbj = 'abcd0123efg4567hijk890'

    -- test that return first match in integer array
    local arr, err = re:indexof(sbj)
    assert.is_nil(err)
    assert.equal(arr, {
        -- 1st match 'abcd0123'
        1,
        8,
        5,
        -- capture '0123'
        8,
    })

    -- test that always return first matches if global flag is not set
    arr, err = re:indexof(sbj)
    assert.is_nil(err)
    assert.equal(arr, {
        1,
        8,
        5,
        8,
    })

    -- test that exec matches with offset
    arr, err = re:indexof(sbj, 6)
    assert.is_nil(err)
    assert.equal(arr, {
        -- 1st match 'hijk890',
        16,
        22,
        -- capture '890'
        20,
        22,
    })

    -- test that return next matches if global flag is set
    re = assert(regex.new('[a-z]+([08]\\d*)', 'g'))
    for i, exp in ipairs({
        {
            -- 1st match 'abcd0123'
            1,
            8,
            -- capture '0123'
            5,
            8,
        },
        {
            -- 2nd match 'hijk890'
            16,
            22,
            -- capture '890'
            20,
            22,
        },
        {},
    }) do
        arr, err = re:indexof(sbj)
        if i == 3 then
            assert.is_nil(arr)
            assert.is_nil(err)
        else
            assert.is_nil(err)
            assert.equal(arr, exp)
        end
    end

    -- test that return nil and error if invalid offset
    arr, err = re:indexof(sbj, -1)
    assert.match(err, 'offset')
    assert.is_nil(arr)

    -- test that throws error if subject is not string
    err = assert.throws(re.indexof, re, 123)
    assert.match(err, 'string expected')

    -- test that throws error if offset is not integer
    err = assert.throws(re.indexof, re, sbj, 1.23)
    assert.match(err, 'integer expected')
end

function testcase.indexof()
    local sbj = 'abcd0123efg4567hijk890'
    local pattern = '[a-z]+([08]\\d*)'

    -- test that return first match in integer array
    local arr, err = regex.indexof(sbj, pattern, nil, 6)
    assert.is_nil(err)
    assert.equal(arr, {
        -- 1st match 'hijk890',
        16,
        22,
        -- capture '890'
        20,
        22,
    })

    -- test that return nil and error if invalid pattern
    arr, err = regex.indexof(sbj, 'abc(', nil, 1)
    assert.match(err, 'compilation failed')
    assert.is_nil(arr)

    -- test that return nil and error if invalid offset
    arr, err = regex.indexof(sbj, pattern, nil, -1)
    assert.match(err, 'offset')
    assert.is_nil(arr)

    -- test that throws error if subject is not string
    err = assert.throws(regex.indexof, 123, pattern)
    assert.match(err, 'string expected')

    -- test that throws error if offset is not integer
    err = assert.throws(regex.indexof, sbj, pattern, nil, 1.23)
    assert.match(err, 'integer expected')
end

function testcase.test_method()
    local re = assert(regex.new('[a-z]+([08]\\d*)'))
    local sbj = 'abcd0123efg4567hijk890'

    -- test that return true if matches found
    local ok, err = re:test(sbj)
    assert.is_nil(err)
    assert.is_true(ok)

    -- test that return false if matches not found
    ok, err = re:test('abc')
    assert.is_nil(err)
    assert.is_false(ok)

    -- test that return false and error if invalid offset
    ok, err = re:test(sbj, -1)
    assert.match(err, 'offset')
    assert.is_false(ok)

    -- test that throws error if subject is not string
    err = assert.throws(re.test, re, 123)
    assert.match(err, 'string expected')

    -- test that throws error if offset is not integer
    err = assert.throws(re.test, re, sbj, 1.23)
    assert.match(err, 'integer expected')
end

function testcase.test()
    local sbj = 'abcd0123efg4567hijk890'
    local pattern = '[a-z]+([08]\\d*)'

    -- test that return true if matches found
    local ok, err = regex.test(sbj, pattern)
    assert.is_true(ok)
    assert.is_nil(err)

    -- test that return false if matches not found
    ok, err = regex.test(sbj, 'abc(')
    assert.is_false(ok)
    assert.match(err, 'compilation failed')

    -- test that throws error if subject is not string
    err = assert.throws(regex.test, 123, pattern)
    assert.match(err, 'string expected')

    -- test that throws error if offset is not integer
    err = assert.throws(regex.test, sbj, pattern, nil, 1.23)
    assert.match(err, 'integer expected')
end

