class Iterator
  constructor: ()->
    @data = []
    if arguments.length == 2
      [@hasNext,@next]=[arguments[0], arguments[1]]
    if arguments.length == 1
      ref = arguments[0]
      if ref && 'object' == typeof ref
        if(ref instanceof Array)
          @data = ref[..]
        else
          [@hasNext,@next,@toArray] = [ref.hasNext, ref.next, ref.toArray]

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

class Set
  constructor: (set)->
    @entry = []
    if arguments.length
      @putAll.apply(@, arguments)

  isEmpty: ->
    @entry.length == 0

  size: ->
    @entry.length

  iterator: ->
    Iterator.factory(@entry)

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
      ret = []
      (
        pos = @indexOf value
        if pos >= 0
          @entry = (if pos == 0 then [] else @entry[0..pos - 1]).concat @entry[pos + 1...]
        else
          ret.push value
      ) for value in arguments
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
    ret.entry=[]
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
    if key and 'object' == typeof key and arguments.length == 1
      (super key).result
    else
      if arguments.length==2
        (super {key: key, value: val}).result
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
      if !@add.call(@, item.key, item.value)
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

  keySet: ()->
    Iterator.factory(item.key for item in @entry)

  containsKey: (key)->
    @contains key: key

  containsValue: (value)->
    (
      ret = true
      break
    )for item in @entry when item.value == value
    ret

  values: ()->
    Iterator.factory(item.value for item in @entry)

SortMap.prototype.put = SortMap.prototype.add

class DichotomySearcher
  constructor: (@data)->
    if arguments > 1 and 'function' == typeof arguments[1]
      @compare = arguments[1]

  compare: (a, b)->
    compare = (if a and b then a["compare"] || b["compare"] else null) || (obj)->
      if @ > obj then 1 else if @ < obj then -1 else 0
    compare.call(a, b)

  find: (obj, compare)->
    data = @data
    compare = if 'function' == typeof compare then compare else @compare
    len = data.length
    pos = 0
    if len > 0 and compare(data[0], obj) == 0 then return 0
    while (pos = Math.ceil((pos + len ) / 2)) < len && len > 1
#      console.log pos," len:",len
      switch compare(data[pos], obj)
        when 0
          return @result = pos
        when 1
          len = pos
          pos = 0
        else
          pos = pos
    #    console.log pos," len:",len
    if len == 1 && compare(data[0], obj) == 0 then return @result = 0
    return @result = -1

  almostFind: (obj, compare)->
    data = @data
    compare = if 'function' == typeof compare then compare else @compare
    for value,index in data
      if compare(value, obj) >= 0
        return index
    data.length


module.exports =
  SortSet: SortSet
  SortMap: SortMap
  Set: Set
  Iterator: Iterator
  DichotomySearcher: DichotomySearcher