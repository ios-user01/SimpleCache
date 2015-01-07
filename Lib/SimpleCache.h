//
//  SimpleCache.h
//  SimpleCache
//
//  Created by kishikawa katsumi on 2015/01/08.
//  Copyright (c) 2015 kishikawa katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SimpleCache : NSObject

@property (nonatomic, readonly) NSUInteger limit;
@property (nonatomic, readonly) NSUInteger count;

@property (nonatomic, readonly) NSArray *allKeys;
@property (nonatomic, readonly) NSArray *allValues;

- (instancetype)init;
- (instancetype)initWithLimit:(NSUInteger)limit;

- (id)objectForKey:(id)key;
- (void)setObject:(id)object forKey:(id<NSCopying>)key;

- (id)objectForKeyedSubscript:(id)key;
- (void)setObject:(id)object forKeyedSubscript:(id<NSCopying>)key;

- (void)removeObjectForKey:(id)key;
- (void)removeAllObjects;

- (id)peekObjectForKey:(id)key;

@end
