//
//  SimpleCache.h
//  SimpleCache
//
//  Created by kishikawa katsumi on 2015/01/08.
//  Copyright (c) 2015 kishikawa katsumi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SimpleCache : NSObject

@property (nonatomic, readonly) NSUInteger capacity;
@property (nonatomic, readonly) NSUInteger count;

@property (nonatomic, readonly) NSArray *allKeys;

- (instancetype)init;
- (instancetype)initWithCapacity:(NSUInteger)capacity;

- (id)objectForKey:(id)key;
- (void)setObject:(id)object forKey:(id<NSCopying>)key;

- (id)objectForKeyedSubscript:(id)key;
- (void)setObject:(id)object forKeyedSubscript:(id<NSCopying>)key;

- (void)removeObjectForKey:(id)key;

- (id)peekObjectForKey:(id)key;

@end
