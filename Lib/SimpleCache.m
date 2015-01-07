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
    return [NSString stringWithFormat:@"[%@: %@]", self.key, self.value];
}

@end

@interface List : NSObject <NSFastEnumeration>

@property (nonatomic) Node *firstNode;
@property (nonatomic) Node *lastNode;

@end

@implementation List

- (Node *)lastObject {
    return self.lastNode;
}

- (void)insertFirst:(Node *)node {
    if (!self.firstNode) {
        self.firstNode = node;
        self.lastNode = node;
        node.previousNode = nil;
        node.nextNode = nil;
    } else {
        node.nextNode = self.firstNode;
        self.firstNode.previousNode = node;
        self.firstNode = node;
    }
}

- (void)removeObject:(Node *)node {
    if (!node.previousNode) {
        self.firstNode = node.nextNode;
    } else {
        node.previousNode.nextNode = node.nextNode;
    }
    if (!node.nextNode) {
        self.lastNode = node.previousNode;
    } else {
        node.nextNode.previousNode = node.previousNode;
    }
}

- (void)removeLastObject {
    [self removeObject:self.lastNode];
}

- (void)removeAllObjects {
    Node *node = self.firstNode;
    while (node) {
        node = node.nextNode;
        [self removeObject:node];
    }
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
    if (state->state == 0) {
        state->mutationsPtr = &state->extra[0];
        state->state = 1;
        state->extra[1] = (long)self.firstNode;
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
        [string appendFormat:@"  %@,\n", node];
    }
    [string appendString:@")"];
    return string.copy;
}

@end

@interface SimpleCache ()

@property (nonatomic) NSMutableDictionary *dictionary;
@property (nonatomic) List *list;

@property (nonatomic) NSUInteger capacity;

@end

@implementation SimpleCache

- (instancetype)init {
    return [self initWithCapacity:DefaultCapacity];
}

- (instancetype)initWithCapacity:(NSUInteger)capacity {
    self = [super init];
    if (self) {
        _dictionary = [[NSMutableDictionary alloc] initWithCapacity:capacity];
        _list = [[List alloc] init];
        
        _capacity = capacity;
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
        Node *node = self.dictionary[key];
        
        if (node) {
            [self.list removeObject:node];
            [self.list insertFirst:node];
        }
        
        return node.value;
    }
}

- (void)setObject:(id)object forKeyedSubscript:(id<NSCopying>)key {
    if (!key || !object) {
        return;
    }
    
    @synchronized(self) {
        Node *node = self.dictionary[key];
        
        if (node) {
            node.value = object;
            
            [self.list removeObject:node];
            [self.list insertFirst:node];
        } else {
            node = [[Node alloc] initWithKey:key value:object];
            
            [self.list insertFirst:node];
        }
        
        [self.dictionary setObject:node forKey:key];
        
        if (self.dictionary.count > self.capacity) {
            Node *last = [self.list lastObject];
            [self.dictionary removeObjectForKey:last.key];
            [self.list removeLastObject];
        }
    }
}

- (void)removeObjectForKey:(id)key {
    if (!key) {
        return;
    }
    
    @synchronized(self) {
        Node *node = self.dictionary[key];
        if (node) {
            [self.dictionary removeObjectForKey:key];
            [self.list removeObject:node];
        }
    }
}

- (void)removeAllObjects {
    @synchronized(self) {
        [self.dictionary removeAllObjects];
        [self.list removeAllObjects];
    }
}

- (NSUInteger)count {
    return self.dictionary.count;
}

#pragma mark -

- (NSArray *)allKeys {
    return self.dictionary.allKeys;
}

- (id)peekObjectForKey:(id)key {
    return self.dictionary[key];
}

#pragma mark -

- (NSString *)description {
    return [NSString stringWithFormat:@"%@", self.list];
}

@end
