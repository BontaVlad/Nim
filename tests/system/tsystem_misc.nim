discard """
  output:'''1
1
2
3
11
12
13
14
15
2
3
4
2
1
2
3
2
48
49
50
51
52
53
54
55
56
57
2
'''
"""


block:
  const a2 = $(int)
  const a3 = $int
  doAssert a2 == "int"
  doAssert a3 == "int"

  proc fun[T: typedesc](t: T) =
    const a2 = $(t)
    const a3 = $t
    doAssert a2 == "int"
    doAssert a3 == "int"
  fun(int)

# check high/low implementations
doAssert high(int) > low(int)
doAssert high(int8) > low(int8)
doAssert high(int16) > low(int16)
doAssert high(int32) > low(int32)
doAssert high(int64) > low(int64)
# doAssert high(uint) > low(uint) # reconsider depending on issue #6620
doAssert high(uint8) > low(uint8)
doAssert high(uint16) > low(uint16)
doAssert high(uint32) > low(uint32)
# doAssert high(uint64) > low(uint64) # reconsider depending on issue #6620
doAssert high(float) > low(float)
doAssert high(float32) > low(float32)
doAssert high(float64) > low(float64)

# bug #6710
var s = @[1]
s.delete(0)


proc foo(a: openArray[int]) =
  for x in a: echo x

foo(toOpenArray([1, 2, 3], 0, 0))

foo(toOpenArray([1, 2, 3], 0, 2))

var arr: array[8..12, int] = [11, 12, 13, 14, 15]

foo(toOpenArray(arr, 8, 12))

var seqq = @[1, 2, 3, 4, 5]
foo(toOpenArray(seqq, 1, 3))

# empty openArray issue #7904
foo(toOpenArray(seqq, 0, -1))
foo(toOpenArray(seqq, 1, 0))
doAssertRaises(IndexError):
  foo(toOpenArray(seqq, 0, -2))

foo(toOpenArray(arr, 9, 8))
foo(toOpenArray(arr, 0, -1))
foo(toOpenArray(arr, 1, 0))
doAssertRaises(IndexError):
  foo(toOpenArray(arr, 10, 8))

# test openArray of openArray
proc oaEmpty(a: openArray[int]) =
  foo(toOpenArray(a, 0, -1))

proc oaFirstElm(a: openArray[int]) =
  foo(toOpenArray(a, 0, 0))

oaEmpty(toOpenArray(seqq, 0, -1))
oaEmpty(toOpenArray(seqq, 1, 0))
oaEmpty(toOpenArray(seqq, 1, 2))
oaFirstElm(toOpenArray(seqq, 1, seqq.len-1))

var arrNeg: array[-3 .. -1, int] = [1, 2, 3]
foo(toOpenArray(arrNeg, -3, -1))
foo(toOpenArray(arrNeg, 0, -1))
foo(toOpenArray(arrNeg, -3, -4))
doAssertRaises(IndexError):
  foo(toOpenArray(arrNeg, -4, -1))
doAssertRaises(IndexError):
  foo(toOpenArray(arrNeg, -1, 0))
doAssertRaises(IndexError):
  foo(toOpenArray(arrNeg, -1, -3))
doAssertRaises(Exception):
  raise newException(Exception, "foo")

block:
  var didThrow = false
  try:
    doAssertRaises(IndexError): # should fail since it's wrong exception
      raise newException(FieldError, "foo")
  except AssertionError:
    # ok, throwing was correct behavior
    didThrow = true
  doAssert didThrow

type seqqType = ptr UncheckedArray[int]
let qData = cast[seqqType](addr seqq[0])
oaFirstElm(toOpenArray(qData, 1, 3))

proc foo(a: openArray[byte]) =
  for x in a: echo x

let str = "0123456789"
foo(toOpenArrayByte(str, 0, str.high))


template boundedOpenArray[T](x: seq[T], first, last: int): openarray[T] =
  toOpenarray(x, max(0, first), min(x.high, last))

# bug #9281

proc foo[T](x: openarray[T]) =
  echo x.len

let a = @[1, 2, 3]

# a.boundedOpenArray(1, 2).foo()  # Works
echo a.boundedOpenArray(1, 2).len # Internal compiler error
