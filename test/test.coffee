ss = require '../sortset.coffee'

SortSet = ss.SortSet
SortMap = ss.SortMap
Iterator = ss.Iterator

#SortSet test
set = new SortSet([10,9,8,7,2,3,4,6,1])

console.log set,"set contains 5:",set.contains(5)

set = set.union(new SortSet([5,0]))

console.log set,"set contains 5:",set.contains(5),"set instanceof SortSet:",set instanceof SortSet

set = set.intersect(new SortSet([11,4,6,8,9]))

console.log set,"set contains 5:",set.contains(5),"set instanceof SortSet:",set instanceof SortSet

set = set.difference(new SortSet([11,7,5,3,2,1,0,10]))

console.log set,"set contains 5:",set.contains(5),"set instanceof SortSet:",set instanceof SortSet

ret = set.add(4,3,9,12)
console.log ret

# SortMap

map = new SortMap([{key:'2',value:'bona shen'}])
map.add('8','kerry')
map.add('3','lala')
map.add('1','petter')
map.add('2','bona')
console.log map
console.log "key:2 's value:",map.get('2')
console.log "map.contains key 1:",map.containsKey('1'),"map.contains 'kerry' value:",map.containsValue('kerry')

#iterator

iterator = map.iterator
console.log "key-value iterator instanceof ss.Iterator:",iterator instanceof ss.Iterator
console.log "key-value interator operator:"
while iterator.hasNext()
  obj = iterator.next()
  console.log "key:#{obj.key}","  value:#{obj.value}"

iterator = map.keySet
console.log "keySet iterator instanceof ss.Iterator:",iterator instanceof ss.Iterator
console.log "keySet interator operator:"
while iterator.hasNext()
  obj = iterator.next()
  console.log "key:#{obj}"

iterator = map.values
console.log "values iterator instanceof ss.Iterator:",iterator instanceof ss.Iterator
console.log "values interator operator:"
while iterator.hasNext()
  obj = iterator.next()
  console.log "value:#{obj}"

##Iterator.forEach
Iterator.forEach([1..5],(item)->console.log item)

Iterator.forEach({name:'bona',id:'2'},(item)->console.log item)

Iterator.forEach map.iterator,(item)->console.log item

# forEach

map.forEach (key,value)->
  console.log key,value

#DichotomySearcher

searcher = new ss.DichotomySearcher([5..1])
console.log "at 4 value:",searcher.at(4)
console.log "first >=0 value's postion:",searcher.geFirst(0)

searcher = new ss.DichotomySearcher([1..5])
console.log "at 3 value:",searcher.at(3)