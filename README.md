# sortset

sortset has Set,SortSet,SortMap,Iterator for javascript,is collection toolkit part.

## SortSet
```coffeescript

  ss = require '../sortset'

  SortSet = ss.SortSet
  SortMap = ss.SortMap

  set = new SortSet([10,9,8,7,2,3,4,6,1])
  
  console.log set,"set contains 5:",set.contains(5) 

    #==>{ entry: [ 1, 2, 3, 4, 6, 7, 8, 9, 10 ] } 'set contains 5:' false
  
  set = set.union(new SortSet([5,0]))
  
  console.log set,"set contains 5:",set.contains(5),"set instanceof SortSet:",set instanceof SortSet

    #==>{ entry: [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ] } 'set contains 5:' true 'set instanceof SortSet:' true
  
  set = set.intersect(new SortSet([11,4,6,8,9]))
  
  console.log set,"set contains 5:",set.contains(5),"set instanceof SortSet:",set instanceof SortSet

    #==>{ entry: [ 4, 6, 8, 9 ] } 'set contains 5:' false 'set instanceof SortSet:' true
  set = set.difference(new SortSet([11,7,5,3,2,1,0,10]))
  
  console.log set,"set contains 5:",set.contains(5),"set instanceof SortSet:",set instanceof SortSet

    #==>{ entry: [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 ] } 'set contains 5:' true 'set instanceof SortSet:' true
  ret = set.add(4,3,9,12)
  console.log ret

    #==>[ 4, 3, 9, result: false ]
    
```

## SortMap

```coffeescript

map = new SortMap([{key:'2',value:'bona shen'}])
map.add('8','kerry')
map.add('3','lala')
map.add('1','petter')
console.log map

    #==>{ entry: 
    #==>      [ { key: '1', value: 'petter' },
    #==>         { key: '2', value: 'bona shen' },
    #==>         { key: '3', value: 'lala' },
    #==>         { key: '8', value: 'kerry' } ] }
    
console.log "key:2 's value:",map.get('2')

    #==>key:2 's value: bona shen

console.log "map.contains key 1:",map.containsKey('1'),"map.contains 'kerry' value:",map.containsValue('kerry')

    #==>map.contains key 1: true map.contains 'kerry' value: true
```


# iterator

```coffeescript

iterator = map.iterator()
console.log "key-value iterator instanceof ss.Iterator:",iterator instanceof ss.Iterator

    #==>key-value iterator instanceof ss.Iterator: true
console.log "key-value interator operator:"
while iterator.hasNext()
  obj = iterator.next()
  console.log "key:#{obj.key}","  value:#{obj.value}"

    #==>key-value interator operator:
    #==>key:1   value:petter
    #==>key:2   value:bona shen
    #==>key:3   value:lala
    #==>key:8   value:kerry
iterator = map.keySet()
console.log "keySet iterator instanceof ss.Iterator:",iterator instanceof ss.Iterator

    #==>keySet iterator instanceof ss.Iterator: true
console.log "keySet interator operator:"
while iterator.hasNext()
  obj = iterator.next()
  console.log "key:#{obj}"

    #==>keySet interator operator:
    #==>key:1   key:2   key:3 key:8
iterator = map.values()
console.log "values iterator instanceof ss.Iterator:",iterator instanceof ss.Iterator
console.log "values interator operator:"
while iterator.hasNext()
  obj = iterator.next()
  console.log "value:#{obj}"

    #==>values iterator instanceof ss.Iterator: true
    #==>values interator operator:
    #==>value:petter
    #==>value:bona shen
    #==>value:lala
    #==>value:kerry
```