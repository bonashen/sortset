// Generated by CoffeeScript 1.9.3
var DichotomySearcher, Iterator, Set, SortMap, SortSet, _exports,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

Iterator = (function() {
  function Iterator() {
    var ref, ref1;
    this.data = [];
    if (arguments.length === 3) {
      ref1 = [arguments[0], arguments[1], arguments[2]], this.hasNext = ref1[0], this.next = ref1[1], this.toArray = ref1[2];
    }
    if (arguments.length === 1) {
      ref = arguments[0];
      if (ref && 'object' === typeof ref) {
        if (ref instanceof Array) {
          this.data = ref.slice(0);
        } else {
          if (ref instanceof Iterator) {
            this.data = ref.toArray().slice(0);
          } else {
            this.hasNext = ref.hasNext, this.next = ref.next, this.toArray = ref.toArray;
          }
        }
      }
    }
  }

  Iterator.prototype.hasNext = function() {
    return this.data.length > 0;
  };

  Iterator.prototype.next = function() {
    return this.data.shift();
  };

  Iterator.prototype.toArray = function() {
    return this.data;
  };

  return Iterator;

})();

Iterator.factory = function(data) {
  data = data instanceof Array ? data : [data];
  data = data.slice(0);
  return new Iterator({
    hasNext: function() {
      return data.length > 0;
    },
    next: function() {
      return data.shift();
    },
    toArray: function() {
      return data;
    }
  });
};

Iterator.forEach = function(iterator, callback) {
  var hasOwnProp, key, value;
  if ('function' === typeof callback && typeof iterator === 'object' && iterator !== null) {
    if (iterator instanceof Array) {
      iterator = Iterator.factory(iterator);
    } else {
      if (iterator instanceof Iterator || ('function' === typeof iterator.hasNext && 'function' === typeof iterator.next)) {

      } else {
        hasOwnProp = {}.hasOwnProperty;
        iterator = new Iterator((function() {
          var results;
          results = [];
          for (key in iterator) {
            value = iterator[key];
            if (hasOwnProp.call(iterator, key)) {
              results.push({
                key: key,
                value: value
              });
            }
          }
          return results;
        })());
      }
    }
    while (iterator.hasNext()) {
      if (callback(iterator.next())) {
        break;
      }
    }
  }
};

Set = (function() {
  function Set(set) {
    this.entry = [];
    if (arguments.length) {
      this.putAll.apply(this, arguments);
    }
  }

  Set.prototype.add = function(object) {
    var i, len1, ret, value;
    if (arguments.length === 0) {
      return false;
    } else {
      ret = [];
      for (i = 0, len1 = arguments.length; i < len1; i++) {
        value = arguments[i];
        if (this.contains(value)) {
          ret.push(value);
          continue;
        }
        this.entry.push(value);
      }
      ret.result = ret.length === 0;
      return ret;
    }
  };

  Set.prototype.remove = function(object) {
    var i, len1, objects, pos, ret, value;
    if (arguments.length === 0) {
      return false;
    } else {
      if (arguments.length === 1 && object instanceof Array) {
        objects = object;
      } else {
        objects = arguments;
      }
      ret = [];
      for (i = 0, len1 = objects.length; i < len1; i++) {
        value = objects[i];
        pos = this.indexOf(value);
        if (pos >= 0) {
          this.entry = (pos === 0 ? [] : this.entry.slice(0, +(pos - 1) + 1 || 9e9)).concat(this.entry.slice(pos + 1));
        } else {
          ret.push(value);
        }
      }
      ret.result = ret.length === 0;
      return ret;
    }
  };

  Set.prototype.contains = function(object) {
    return this.indexOf(object) !== -1;
  };

  Set.prototype.toArray = function() {
    return this.entry.slice(0);
  };

  Set.prototype.clear = function() {
    return this.entry = [];
  };

  Set.prototype.toString = function() {
    if (typeof JSON === "undefined") {
      throw new Error("JSON object is not supported.");
      return JSON.stringify(this.entry);
    }
  };

  Set.prototype.valueOf = function() {
    return this.toString();
  };

  Set.prototype.indexOf = function(data) {
    var i, index, len1, ref1, ret, value;
    ret = -1;
    ref1 = this.entry;
    for (index = i = 0, len1 = ref1.length; i < len1; index = ++i) {
      value = ref1[index];
      if (this.compare(value, data) === 0) {
        ret = index;
        break;
      }
    }
    return ret;
  };

  Set.prototype.compare = function(a, b) {
    var compare;
    compare = (a && b ? a["compare"] || b["compare"] : null) || function(obj) {
      if (this > obj) {
        return 1;
      } else if (this < obj) {
        return -1;
      } else {
        return 0;
      }
    };
    return compare.call(a, b);
  };

  Set.prototype.sort = function(compare) {
    compare = 'function' === typeof compare ? compare : this.compare;
    return this.entry = this.entry.sort(compare);
  };

  Set.prototype.putAll = function(set) {
    var array;
    array = [];
    if (set instanceof Set) {
      array = set.entry.slice(0);
    } else {
      if (set instanceof Array) {
        array = set;
      } else {
        array.push(set);
      }
    }
    return this.add.apply(this, array);
  };

  Set.prototype.removeAll = function(set) {
    var array;
    array = [];
    if (set instanceof Set) {
      array = set.entry;
    } else {
      if (set instanceof Array) {
        array = set;
      } else {
        array.push(set);
      }
    }
    return this.remove.apply(this, array);
  };

  Set.prototype.union = function(set) {
    var ret;
    ret = Object.create(this);
    ret.entry = this.entry.slice(0);
    ret.putAll(set);
    return ret;
  };

  Set.prototype.intersect = function(set) {
    var i, item, len1, ref1, ret;
    ret = Object.create(this);
    ret.entry = [];
    if (set instanceof Set) {
      ref1 = set.entry;
      for (i = 0, len1 = ref1.length; i < len1; i++) {
        item = ref1[i];
        if (this.contains(item)) {
          ret.add(item);
        }
      }
    }
    return ret;
  };

  Set.prototype.difference = function(set) {
    var i, item, len1, ref1, remove_data, ret;
    ret = this.union(set);
    remove_data = [];
    ref1 = ret.entry;
    for (i = 0, len1 = ref1.length; i < len1; i++) {
      item = ref1[i];
      if (set.contains(item) && this.contains(item)) {
        remove_data.push(item);
      }
    }
    ret.removeAll(remove_data);
    return ret;
  };

  Set.prototype.forEach = function(callback) {
    return Iterator.forEach(this.iterator, callback);
  };

  return Set;

})();

Object.defineProperty(Set.prototype, "size", {
  get: function() {
    return this.entry.length;
  }
});

Object.defineProperty(Set.prototype, "empty", {
  get: function() {
    return this.entry.length === 0;
  }
});

Object.defineProperty(Set.prototype, "iterator", {
  get: function() {
    return Iterator.factory(this.entry);
  }
});

SortSet = (function(superClass) {
  extend(SortSet, superClass);

  function SortSet() {
    return SortSet.__super__.constructor.apply(this, arguments);
  }

  SortSet.prototype.add = function(object) {
    var i, index, len1, ret, value;
    if (arguments.length === 0) {
      return false;
    } else {
      ret = [];
      for (i = 0, len1 = arguments.length; i < len1; i++) {
        value = arguments[i];
        if (this.contains(value)) {
          ret.push(value);
          continue;
        }
        index = new DichotomySearcher(this.entry).geFirst(value, this.compare);
        this.entry = (index === 0 ? [] : this.entry.slice(0, +(index - 1) + 1 || 9e9)).concat(value).concat(this.entry.slice(index));
      }
      ret.result = ret.length === 0;
      return ret;
    }
  };

  SortSet.prototype.indexOf = function(data) {
    return new DichotomySearcher(this.entry).at(data, this.compare);
  };

  return SortSet;

})(Set);

SortMap = (function(superClass) {
  extend(SortMap, superClass);

  function SortMap() {
    return SortMap.__super__.constructor.apply(this, arguments);
  }

  SortMap.prototype.compare = function(a, b) {
    return SortMap.__super__.compare.call(this, a.key, b.key);
  };

  SortMap.prototype.add = function(key, val) {
    var obj, pos;
    if (key && ('object' === typeof key) && (arguments.length === 1)) {
      obj = key;
    } else {
      if (arguments.length === 2) {
        obj = {
          key: key,
          value: val
        };
      }
    }
    if (obj) {
      pos = this.indexOf(obj);
      if (pos > -1) {
        this.entry[pos].value = obj.value;
        return true;
      } else {
        return (SortMap.__super__.add.call(this, obj)).result;
      }
    } else {
      return false;
    }
  };

  SortMap.prototype.putAll = function(map) {
    var array, item, iterator, ret;
    array = [];
    if (map instanceof SortMap) {
      array = map.entry.slice(0);
    } else {
      if (map instanceof Array) {
        array = map;
      } else {
        array.push(map);
      }
    }
    ret = [];
    iterator = new Iterator(array);
    while (iterator.hasNext()) {
      item = iterator.next();
      if (!this.add(item.key, item.value)) {
        ret.push(item);
      }
    }
    ret.result = ret.length === 0;
    return ret;
  };

  SortMap.prototype.remove = function(key) {
    return (SortMap.__super__.remove.call(this, {
      key: key
    })).result;
  };

  SortMap.prototype.removeAll = function(map) {
    var array, i, item, len1, ret;
    array = [];
    if (map instanceof Map) {
      array = map.entry;
    } else {
      if (map instanceof Array) {
        array = map;
      } else {
        array.push(map);
      }
    }
    ret = [];
    for (i = 0, len1 = array.length; i < len1; i++) {
      item = array[i];
      if (!this.remove.call(this, item.key)) {
        ret.push(item);
      }
    }
    ret.result = ret.length === 0;
    return ret;
  };

  SortMap.prototype.get = function(key) {
    var pos;
    pos = this.indexOf({
      key: key
    });
    if (pos >= 0) {
      return this.entry[pos].value;
    } else {
      return null;
    }
  };

  SortMap.prototype.containsKey = function(key) {
    return this.contains({
      key: key
    });
  };

  SortMap.prototype.containsValue = function(value) {
    var i, item, len1, ref1, ret;
    ref1 = this.entry;
    for (i = 0, len1 = ref1.length; i < len1; i++) {
      item = ref1[i];
      if (item.value === value) {
        ret = true;
        break;
      }
    }
    return ret;
  };

  SortMap.prototype.forEach = function(callback) {
    return SortMap.__super__.forEach.call(this, function(item) {
      return callback(item.key, item.value);
    });
  };

  return SortMap;

})(SortSet);

SortMap.prototype.put = SortMap.prototype.add;

Object.defineProperty(SortMap.prototype, "values", {
  get: function() {
    var item;
    return Iterator.factory((function() {
      var i, len1, ref1, results;
      ref1 = this.entry;
      results = [];
      for (i = 0, len1 = ref1.length; i < len1; i++) {
        item = ref1[i];
        results.push(item.value);
      }
      return results;
    }).call(this));
  }
});

Object.defineProperty(SortMap.prototype, "keySet", {
  get: function() {
    var item;
    return Iterator.factory((function() {
      var i, len1, ref1, results;
      ref1 = this.entry;
      results = [];
      for (i = 0, len1 = ref1.length; i < len1; i++) {
        item = ref1[i];
        results.push(item.key);
      }
      return results;
    }).call(this));
  }
});

DichotomySearcher = (function() {
  function DichotomySearcher(data1) {
    this.data = data1;
    if (arguments > 1 && 'function' === typeof arguments[1]) {
      this.compare = arguments[1];
    }
  }

  DichotomySearcher.prototype.compare = function(a, b) {
    var compare;
    compare = (a && b ? a["compare"] || b["compare"] : null) || function(obj) {
      if (this > obj) {
        return 1;
      } else if (this < obj) {
        return -1;
      } else {
        return 0;
      }
    };
    return compare.call(a, b);
  };

  DichotomySearcher.prototype.isReverse = function(compare) {
    var data;
    compare = 'function' === typeof compare ? compare : this.compare;
    data = this.data;
    if (data && data.length) {
      return compare(data[0], data[data.length - 1]) === 1;
    } else {
      return false;
    }
  };

  DichotomySearcher.prototype.at = function(obj, compare) {
    var data, flag, len, pos;
    data = this.data;
    compare = 'function' === typeof compare ? compare : this.compare;
    len = data.length;
    pos = 0;
    flag = this.isReverse(compare) ? -1 : 1;
    if (len) {
      if (compare(data[0], obj) === 0) {
        return 0;
      }
      while ((pos = Math.ceil((pos + len) / 2)) < len && len > 1) {
        switch (compare(data[pos], obj) * flag) {
          case 0:
            return this.result = pos;
          case 1:
            len = pos;
            pos = 0;
            break;
          default:
            pos = pos;
        }
      }
    }
    return this.result = -1;
  };

  DichotomySearcher.prototype.geFirst = function(obj, compare) {
    var data, flag, i, index, len1, value;
    data = this.data;
    compare = 'function' === typeof compare ? compare : this.compare;
    flag = this.isReverse(compare) ? -1 : 1;
    for (index = i = 0, len1 = data.length; i < len1; index = ++i) {
      value = data[index];
      if (compare(value, obj) * flag >= 0) {
        return index;
      }
    }
    return data.length;
  };

  DichotomySearcher.prototype.ge = function(obj, compare) {
    var len, pos, ret;
    pos = this.geFirst(obj, compare);
    ret = [];
    len = this.data.length;
    if ((len > pos && pos > -1)) {
      while (pos < len) {
        ret.push(this.data[pos++]);
      }
    }
    return ret;
  };

  return DichotomySearcher;

})();

_exports = {
  SortSet: SortSet,
  SortMap: SortMap,
  Set: Set,
  Iterator: Iterator,
  DichotomySearcher: DichotomySearcher
};

if ((typeof module !== "undefined" && module !== null) && (module.exports != null)) {
  module.exports = _exports;
}

if ('function' === typeof define && (define.amd != null)) {
  define(null, [], function() {
    return _exports;
  });
}

//# sourceMappingURL=sortset.js.map
