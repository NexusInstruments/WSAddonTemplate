#SimpleUtils
A Wildstar LUA Utility library for simple common script tasks

This library extends a few common data types and adds utility functions. Please see the reference below.

#Usage
```lua
  local Utils = Apollo.GetPackage("SimpleUtils").tPackage
```

#Reference

##String

###string:split(pattern, [result])
Splits a string into an table ot strings based on a patter. The pattern can be a valid LUA String matching pattern

Returns: table

```lua
  local str = "This is a face."
  local tbl = str:split(" ")
  print tbl[0]
  print tbl[1]
  print tbl[2]
  print tbl[3]
```

Results:
```
  This
  is
  a
  face.
```

###string:tohexstring([spacer])
Converts the contents of a string to it's hexadecimal byte representation with an optional spacer

Returns: string

```lua
  local str = "ABCDEFG"
  local hexStr = str:tohexstring(" ")
  print hexStr
```

Results:
```
  61 62 63 64 65 66
```

## Utility

### shallowcopy(orig)
Creates a non-recursive shallow copy of a table.

Returns: table

```lua
  local tbl = {}
  local tbl_copy = shallowcopy(tbl)
  -- This function never evaluates
  if tbl === tbl_copy return true
```

### deepcopy(orig)
Creates a recursive deep copy of a table and it's metatables. This is suitable for copying "objects"

Returns: table

```lua
  local tbl = {}
  local tbl_copy = deepcopy(tbl)
  -- This function never evaluates
  if tbl === tbl_copy return true
```

### vardump(tbl, [indent])
Dumps the contents of a table to the debug chat channel. The indent value is the number of spaces to use to indent to lower levels of the object. If this is not included, then 0 is used.

```lua
  local tbl = { a = "123", b = "456" }
  vardump(tbl, 1)
```

Results:
```
[Debug]: tbl
[Debug]: a: 123
[Debug]: b: 456
```

### svardump(tbl, [indent])
Like vardump, but dumps the table dump into a string that is returned.

Returns: string

```lua
  local tbl = { a = "123", b = "456" }
  local dump = svardump(tbl, 1)
  print dump
```

Results:
```
tbl
a: 123
b: 456
```

## Chat Printing

### SimpleUtils:debug(string)
Prints the string to the debug channel

### SimpleUtils:cprint(string)
Prints the string to the Command channel

### SimpleUtils:pprint(string)
Prints the string to the Party Chat channel

**Licensed under MIT License**
Copyright (c) 2015 NexusInstruments
