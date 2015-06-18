class Iterator
  constructor: ()->
    @data = []
    if arguments.length == 3
      [@hasNext,@next,@toArray]=[arguments[0], arguments[1], arguments[2]]
    if arguments.length == 1
      ref = arguments[0]
      if ref && 'object' == typeof ref
        if(ref instanceof Array)
          @data = ref[..]
        else
          if ref instanceof Iterator
            @data = ref.toArray()[..]
          else
            {@hasNext,@next,@toArray} = ref

  hasNext: ->
    @data.length > 0
  next: ->
    @data.shift()
  toArray: ->
    @data

Iterator.factory = (data)->
  data = if data instanceof Array then data else [data]
  data = data[..]
  new Iterator
    hasNext: ->
      data.length > 0
    next: ->
      data.shift()
    toArray: ->
      data

#support:array,Iterator,object
Iterator.forEach = (iterator, callback)->
  if 'function'is typeof callback and typeof iterator is 'object' and iterator isnt null
    if iterator instanceof Array
      iterator = Iterator.factory(iterator)
    else
      if  iterator instanceof Iterator or (('function' is typeof iterator.hasNext and 'function' is typeof iterator.next))
      else
          hasOwnProp = {}.hasOwnProperty
          iterator = new Iterator ((
            {key: key, value: value}
          )for key,value of iterator when hasOwnProp.call(iterator, key))
    while iterator.hasNext()
      if callback(iterator.next())
        break
  return

class Set
  constructor: (set)->
    @entry = []
    if arguments.length
      @putAll.apply(@, arguments)

#  isEmpty: ->
#    @entry.length == 0
#
#  size: ->
#    @entry.length
#
#  iterator: ->
#    Iterator.factory(@entry)

  add: (object)->
    if arguments.length == 0
      false
    else
      ret = []
      (
        if @contains(value)
          ret.push(value)
          continue
        @entry.push(value)
      ) for value in arguments

      ret.result = (ret.length == 0)
      ret

  remove: (object)->
    if arguments.length == 0
      false
    else
      if arguments.length == 1 and object instanceof Array
        objects = object
      else
        objects = arguments
      ret = []
      (
        pos = @indexOf value
        if pos >= 0
          @entry = (if pos == 0 then [] else @entry[0..pos - 1]).concat @entry[pos + 1...]
        else
          ret.push value
      ) for value in objects
      ret.result = ret.length == 0
      ret

  contains: (object)->
    @indexOf(object) != -1

  toArray: ->
    @entry[..]

  clear: ->
    @entry = []

  toString: ->
    if typeof JSON == "undefined"
      throw new Error "JSON object is not supported."
      return JSON.stringify @entry

  valueOf: ->
    return @toString()

  indexOf: (data)->
    ret = -1
    (
      ret = index
      break
    )for value,index in @entry when @compare(value, data) == 0
    ret

  compare: (a, b)->
    compare = (if a and b then a["compare"] || b["compare"] else null) || (obj)->
      if @ > obj then 1 else if @ < obj then -1 else 0
    compare.call(a, b)

  sort: (compare)->
    compare = if 'function' == typeof compare then compare else @compare
    @entry = @entry.sort(compare)

  putAll: (set)->
    array = []
    if set instanceof Set
      array = set.entry[..]
    else
      if set instanceof Array
        array = set
      else
        array.push set
    @add.apply(@, array)


  removeAll: (set)->
    array = []
    if set instanceof Set
      array = set.entry
    else
      if set instanceof Array
        array = set
      else
        array.push set
    @remove.apply(@, array)

  union: (set)->
    ret = Object.create(@)
    ret.entry = @entry[..]
    ret.putAll set
    ret

  intersect: (set)->
    ret = Object.create(@)
    ret.entry = []
    if set instanceof Set
      (
        if @contains(item)
          ret.add(item)
      ) for item in set.entry
    ret

  difference: (set)->
    ret = @union set
    remove_data = []
    for item in ret.entry
      if set.contains(item) and @contains(item)
        remove_data.push(item)
    ret.removeAll(remove_data)
    ret

  forEach: (callback)->
    Iterator.forEach(@iterator,callback)


Object.defineProperty Set.prototype, "size",
  get: -> @entry.length

Object.defineProperty Set.prototype, "empty",
  get: -> @entry.length == 0

Object.defineProperty Set.prototype, "iterator",
  get: -> Iterator.factory(@entry)


#Sort set
class SortSet extends Set
  add: (object)->
    if arguments.length == 0
      false
    else
      ret = []
      (
        if @contains(value)
          ret.push(value)
          continue
        index = new DichotomySearcher(@entry).almostFind(value, @compare)
        @entry = (if index == 0 then [] else @entry[0..index - 1]).concat(value).concat(@entry[index..])
      ) for value in arguments

      ret.result = (ret.length == 0)
      ret

  indexOf: (data)->
    new DichotomySearcher(@entry).find(data, @compare)

class SortMap extends SortSet
  compare: (a, b)->
    super a.key, b.key

  add: (key, val)->
    if key and ('object' == typeof key) and (arguments.length == 1)
      obj = key
    else
      if arguments.length == 2
        obj = key: key, value: val
    if obj
      pos = @indexOf(obj)
      if pos > -1
        @entry[pos].value = obj.value
        true
      else
        (super obj).result
    else
      false
  putAll: (map)->
    array = []
    if map instanceof SortMap
      array = map.entry[..]
    else
      if map instanceof Array
        array = map
      else
        array.push map
    ret = []
    iterator = new Iterator(array)
    while iterator.hasNext()
      item = iterator.next()
      if !@add item.key, item.value
        ret.push(item)

    ret.result = ret.length == 0
    ret

  remove: (key)->
    (super {key: key}).result

  removeAll: (map)->
    array = []
    if map instanceof Map
      array = map.entry
    else
      if map instanceof Array
        array = map
      else
        array.push map
    ret = []
    (
      if !@remove.call(@, item.key)
        ret.push(item)
    )for item in array
    ret.result = ret.length == 0
    ret

  get: (key)->
    pos = @indexOf({key: key})
    if(pos >= 0) then @entry[pos].value else null

#  keySet: ()->
#    Iterator.factory(item.key for item in @entry)

  containsKey: (key)->
    @contains key: key

  containsValue: (value)->
    (
      ret = true
      break
    )for item in @entry when item.value == value
    ret

#  values: ()->
#    Iterator.factory(item.value for item in @entry)

  forEach: (callback)->
    super (item)-> callback(item.key, item.value)

SortMap.prototype.put = SortMap.prototype.add

Object.defineProperty SortMap.prototype, "values",
  get: -> Iterator.factory(item.value for item in @entry)

Object.defineProperty SortMap.prototype, "keySet",
  get: -> Iterator.factory(item.key for item in @entry)

class DichotomySearcher
  constructor: (@data)->
    if arguments > 1 and 'function' == typeof arguments[1]
      @compare = arguments[1]

  compare: (a, b)->
    compare = (if a and b then a["compare"] || b["compare"] else null) || (obj)->
      if @ > obj then 1 else if @ < obj then -1 else 0
    compare.call(a, b)

  isReverse: (compare)->
    compare = if 'function' == typeof compare then compare else @compare
    data = @data
    if data and data.length then  compare(data[0], data[data.length - 1]) == 1 else false


  find: (obj, compare)->
    data = @data
    compare = if 'function' == typeof compare then compare else @compare
    len = data.length
    pos = 0
    flag = if @isReverse(compare) then -1 else 1
    if len
      if compare(data[0], obj) == 0 then return 0
      while (pos = Math.ceil((pos + len ) / 2)) < len && len > 1
        switch compare(data[pos], obj) * flag
          when 0
            return @result = pos
          when 1
            len = pos
            pos = 0
          else
            pos = pos
    return @result = -1

  almostFind: (obj, compare)->
    data = @data
    compare = if 'function' == typeof compare then compare else @compare
    flag = if @isReverse(compare) then -1 else 1
    for value,index in data
      if compare(value, obj) * flag >= 0
        return index
    data.length

_exports =
  SortSet: SortSet
  SortMap: SortMap
  Set: Set
  Iterator: Iterator
  DichotomySearcher: DichotomySearcher

#exports

if module? and module.exports?
  module.exports = _exports

#for AMD
if 'function' == typeof define and define.amd
  define null, [], ->
    _exports

