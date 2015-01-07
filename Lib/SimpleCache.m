//
//  SimpleCache.m
//  SimpleCache
//
//  Created by kishikawa katsumi on 2015/01/08.
//  Copyright (c) 2015 kishikawa katsumi. All rights reserved.
//

#import "SimpleCache.h"

static const NSUInteger DefaultCapacity = 10;

@interface SimpleCache ()

@property (nonatomic) NSMutableDictionary *dictionary;
@property (nonatomic) NSMutableArray *stack;

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
        _stack = [[NSMutableArray alloc] initWithCapacity:capacity];
        
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
        id object = self.dictionary[key];
        
        [self.stack removeObject:key];
        [self.stack insertObject:key atIndex:0];
        
        return object;
    }
}

- (void)setObject:(id)object forKeyedSubscript:(id<NSCopying>)key {
    if (!key || !object) {
        return;
    }
    
    @synchronized(self) {
        [self.dictionary setObject:object forKey:key];
        
        NSUInteger index = [self.stack indexOfObject:key];
        if (index != NSNotFound) {
            [self.stack removeObjectAtIndex:index];
        }
        [self.stack insertObject:key atIndex:0];
        
        if (self.stack.count > self.capacity) {
            id object = self.stack.lastObject;
            [self.dictionary removeObjectForKey:object];
            [self.stack removeObject:object];
        }
    }
}

- (void)removeObjectForKey:(id)key {
    if (!key) {
        return;
    }
    
    @synchronized(self) {
        [self.dictionary removeObjectForKey:key];
        NSUInteger index = [self.stack indexOfObject:key];
        if (index != NSNotFound) {
            [self.stack removeObjectAtIndex:index];
        }
    }
}

- (void)removeAllObjects {
    @synchronized(self) {
        [self.dictionary removeAllObjects];
        [self.stack removeAllObjects];
    }
}

- (NSUInteger)count {
    return self.stack.count;
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
    NSMutableString *string = [[NSMutableString alloc] initWithString:@"(\n"];
    for (id key in self.stack) {
        [string appendFormat:@"%@: %@\n", key, self.dictionary[key]];
    }
    [string appendString:@")"];
    return string.copy;
}

@end
