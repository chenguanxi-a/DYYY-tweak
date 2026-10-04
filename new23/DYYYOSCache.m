#import "DYYYNew23.h"

@implementation DYYYOSCacheEntry
@end

@implementation DYYYOSCache {
    NSUInteger _limit;
    NSMutableDictionary<NSString *, DYYYOSCacheEntry *> *_store;
    NSMapTable *_keyToObject;
    id _cacheDelegate;
}

- (instancetype)initWithLimit:(NSUInteger)limit {
    self = [super init];
    if (self) {
        _limit = limit;
        _store = [NSMutableDictionary dictionaryWithCapacity:limit];
        _keyToObject = [NSMapTable weakToWeakObjectsMapTable];
    }
    return self;
}

- (id)delegate {
    return _cacheDelegate;
}

- (void)setDelegate:(id)delegate {
    _cacheDelegate = delegate;
}

- (void)storeObject:(id)object forKey:(NSString *)key {
    @synchronized(self) {
        if (object == nil) {
            [_store removeObjectForKey:key];
            [_keyToObject removeObjectForKey:key];
            return;
        }
        DYYYOSCacheEntry *entry = [[DYYYOSCacheEntry alloc] init];
        entry.object = object;
        entry.key = key;
        entry.timestamp = CFAbsoluteTimeGetCurrent();
        _store[key] = entry;
        [_keyToObject setObject:object forKey:key];

        while (_store.count > _limit) {
            NSString *oldestKey = nil;
            DYYYOSCacheEntry *oldest = nil;
            for (NSString *k in _store.allKeys) {
                DYYYOSCacheEntry *e = _store[k];
                if (!oldest || e.timestamp < oldest.timestamp) {
                    oldestKey = k;
                    oldest = e;
                }
            }
            if (!oldestKey) break;
            if ([_cacheDelegate respondsToSelector:@selector(cacheShouldEvictObject:forKey:)]) {
                if (![(id)_cacheDelegate cacheShouldEvictObject:oldest.object forKey:oldestKey]) continue;
            }
            if ([_cacheDelegate respondsToSelector:@selector(cacheWillEvictObject:forKey:)]) {
                [(_cacheDelegate) cacheWillEvictObject:oldest.object forKey:oldestKey];
            }
            [_store removeObjectForKey:oldestKey];
            [_keyToObject removeObjectForKey:oldestKey];
        }
    }
}

- (id)objectForKey:(NSString *)key {
    @synchronized(self) {
        DYYYOSCacheEntry *entry = _store[key];
        if (!entry) return nil;
        entry.timestamp = CFAbsoluteTimeGetCurrent();
        return entry.object;
    }
}

- (BOOL)cacheShouldEvictObject:(id)obj forKey:(NSString *)key {
    return YES;
}

- (void)cacheWillEvictObject:(id)obj forKey:(NSString *)key {
}

- (void)cacheLimitAdjustedTo:(NSUInteger)limit {
    @synchronized(self) {
        _limit = limit;
    }
}

- (void)clear {
    @synchronized(self) {
        [_store removeAllObjects];
        [_keyToObject removeAllObjects];
    }
}
@end

static DYYYOSCache *_globalDYYYOSCache = nil;

DYYYOSCache *DYYYGlobalOSCache(void) {
    @synchronized(DYYYGlobalOSCache) {
        if (!_globalDYYYOSCache) {
            _globalDYYYOSCache = [[DYYYOSCache alloc] initWithLimit:64];
        }
        return _globalDYYYOSCache;
    }
}