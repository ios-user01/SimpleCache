//
//  SimpleCache.m
//  SimpleCache
//
//  Created by kishikawa katsumi on 2015/01/08.
//  Copyright (c) 2015 kishikawa katsumi. All rights reserved.
//

#import "SimpleCache.h"

static const NSUInteger DefaultCapacity = 10;

@interface Node : NSObject

@property (nonatomic, readonly) id key;
@property (nonatomic) id value;

@property (nonatomic) Node *previousNode;
@property (nonatomic) Node *nextNode;

@end

@implementation Node

- (instancetype)initWithKey:(id)key value:(id)value
{
    self = [super init];
    if (self) {
        _key = key;
        _value = value;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"[%@: %@]", _key, _value];
}

@end

@interface List : NSObject <NSFastEnumeration>

@property (nonatomic) Node *firstNode;
@property (nonatomic) Node *lastNode;

@end

@implementation List

- (Node *)lastObject {
    return _lastNode;
}

- (void)insertFirst:(Node *)node {
    if (!_firstNode) {
        _firstNode = node;
        _lastNode = node;
        node.previousNode = nil;
        node.nextNode = nil;
    } else {
        node.nextNode = _firstNode;
        _firstNode.previousNode = node;
        _firstNode = node;
    }
}

- (void)removeObject:(Node *)node {
    if (!node.previousNode) {
        _firstNode = node.nextNode;
    } else {
        node.previousNode.nextNode = node.nextNode;
    }
    if (!node.nextNode) {
        _lastNode = node.previousNode;
    } else {
        node.nextNode.previousNode = node.previousNode;
    }
}

- (void)removeLastObject {
    [self removeObject:_lastNode];
}

- (void)removeAllObjects {
    Node *node = _firstNode;
    while (node) {
        node = node.nextNode;
        [self removeObject:node];
    }
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
    if (state->state == 0) {
        state->mutationsPtr = &state->extra[0];
        state->state = 1;
        state->extra[1] = (long)_firstNode;
    }
    
    NSUInteger count = 0;
    state->itemsPtr = buffer;
    
    void *n = (void *)state->extra[1];
    Node *node = (__bridge Node *)n;
    
    while (node) {
        buffer[count] = node;
        ++count;
        
        if (count < len) {
            node = node.nextNode;
        } else {
            break;
        }
    }
    
    state->extra[1] = (long)node.nextNode;
    
    return count;
}

- (NSString *)description {
    NSMutableString *string = [[NSMutableString alloc] initWithString:@"(\n"];
    for (Node *node in self) {
        [string appendFormat:@"    %@,\n", node];
    }
    [string appendString:@")"];
    return string.copy;
}

@end

@interface SimpleCache ()

@property (nonatomic, readwrite) NSUInteger limit;

@property (nonatomic) NSMutableDictionary *dictionary;
@property (nonatomic) List *list;

@end

@implementation SimpleCache

- (instancetype)init {
    return [self initWithLimit:DefaultCapacity];
}

- (instancetype)initWithLimit:(NSUInteger)limit {
    self = [super init];
    if (self) {
        _dictionary = [[NSMutableDictionary alloc] initWithCapacity:limit];
        _list = [[List alloc] init];
        
        _limit = limit;
    }
    return self;
}

- (id)objectForKey:(id)key {
    return [self objectForKeyedSubscript:key];
}

- (void)setObject:(id)object forKey:(id<NSCopying>)key {
    [self setObject:object forKeyedSubscript:key];
}

- (id)objectForKeyedSubscript:(id)key {
    if (!key) {
        return nil;
    }
    
    @synchronized(self) {
        Node *node = _dictionary[key];
        
        if (node) {
            [_list removeObject:node];
            [_list insertFirst:node];
        }
        
        return node.value;
    }
}

- (void)setObject:(id)object forKeyedSubscript:(id<NSCopying>)key {
    if (!key || !object) {
        return;
    }
    
    @synchronized(self) {
        Node *node = _dictionary[key];
        
        if (node) {
            node.value = object;
            [_list removeObject:node];
        } else {
            node = [[Node alloc] initWithKey:key value:object];
        }
        
        [_dictionary setObject:node forKey:key];
        [_list insertFirst:node];
        
        if (_dictionary.count > _limit) {
            Node *lastObject = [_list lastObject];
            [_dictionary removeObjectForKey:lastObject.key];
            [_list removeLastObject];
        }
    }
}

- (void)removeObjectForKey:(id)key {
    if (!key) {
        return;
    }
    
    @synchronized(self) {
        Node *node = _dictionary[key];
        if (node) {
            [_dictionary removeObjectForKey:key];
            [_list removeObject:node];
        }
    }
}

- (void)removeAllObjects {
    @synchronized(self) {
        [_dictionary removeAllObjects];
        [_list removeAllObjects];
    }
}

- (NSUInteger)count {
    @synchronized(self) {
        return _dictionary.count;
    }
}

- (NSArray *)allKeys {
    @synchronized(self) {
        return _dictionary.allKeys;
    }
}

- (NSArray *)allValues {
    @synchronized(self) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (Node *node in _list) {
            [array addObject:node.value];
        }
        return array.copy;
    }
}

- (id)peekObjectForKey:(id)key {
    @synchronized(self) {
        return _dictionary[key];
    }
}

#pragma mark -

- (NSString *)description {
    return [NSString stringWithFormat:@"%@", _list];
}

@end
