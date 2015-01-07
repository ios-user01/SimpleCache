//
//  SimpleCacheTests.m
//  SimpleCacheTests
//
//  Created by kishikawa katsumi on 2015/01/08.
//  Copyright (c) 2015 kishikawa katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "SimpleCache.h"

@interface SimpleCacheTests : XCTestCase

@end

@implementation SimpleCacheTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

// To get a sense of your problem-solving skills, we’d like to ask you to build
// a thread-safe, in-memory LRU cache with a maximum item count of 10.
// You can do this in either Objective-C or Swift, but be prepared to justify your decision!
//
// Design priorities should be:
// 1. Should perform well as a web image cache, (avg ~1MB)
// 2. Should be well tested
// 3. Simplicity of API
// 4. Overall performance
// 5. Thread safety

- (void)testSet {
    SimpleCache *cache = [[SimpleCache alloc] init];
    
    cache[@"KEY_1"] = @"VALUE_1";
    XCTAssertEqualObjects(cache[@"KEY_1"], @"VALUE_1");
    XCTAssertEqual(cache.count, 1);
}

- (void)testOverwrite {
    SimpleCache *cache = [[SimpleCache alloc] init];
    
    cache[@"KEY_1"] = @"VALUE_1";
    XCTAssertEqualObjects(cache[@"KEY_1"], @"VALUE_1");
    
    cache[@"KEY_1"] = @"VALUE_2";
    
    XCTAssertEqualObjects(cache[@"KEY_1"], @"VALUE_2");
    XCTAssertEqual(cache.count, 1);
}

- (void)testEvict {
    SimpleCache *cache = [[SimpleCache alloc] initWithLimit:2];
    
    cache[@"KEY_1"] = @"VALUE_1";
    cache[@"KEY_2"] = @"VALUE_2";
    
    cache[@"KEY_3"] = @"VALUE_3";
    
    XCTAssertNil(cache[@"KEY_1"]);
    XCTAssertEqualObjects(cache[@"KEY_2"], @"VALUE_2");
    XCTAssertEqualObjects(cache[@"KEY_3"], @"VALUE_3");
    
    XCTAssertEqual(cache.count, 2);
}

- (void)testSetSameKey1 {
    SimpleCache *cache = [[SimpleCache alloc] initWithLimit:2];
    
    cache[@"KEY_1"] = @"VALUE_1";
    cache[@"KEY_2"] = @"VALUE_2";
    
    cache[@"KEY_1"] = @"VALUE_1";
    
    XCTAssertEqualObjects(cache[@"KEY_1"], @"VALUE_1");
    XCTAssertEqualObjects(cache[@"KEY_2"], @"VALUE_2");
    
    XCTAssertEqual(cache.count, 2);
}

- (void)testSetSameKey2 {
    SimpleCache *cache = [[SimpleCache alloc] initWithLimit:2];
    
    cache[@"KEY_1"] = @"VALUE_1";
    cache[@"KEY_2"] = @"VALUE_2";
    
    cache[@"KEY_1"] = @"VALUE_1";
    cache[@"KEY_1"] = @"VALUE_1";
    
    XCTAssertEqualObjects(cache[@"KEY_1"], @"VALUE_1");
    XCTAssertEqualObjects(cache[@"KEY_2"], @"VALUE_2");
    
    XCTAssertEqual(cache.count, 2);
}

- (void)testSetSameKey3 {
    SimpleCache *cache = [[SimpleCache alloc] initWithLimit:2];
    
    cache[@"KEY_1"] = @"VALUE_1";
    cache[@"KEY_2"] = @"VALUE_2";
    
    cache[@"KEY_1"] = @"VALUE_1";
    cache[@"KEY_3"] = @"VALUE_3";
    
    XCTAssertEqualObjects(cache[@"KEY_1"], @"VALUE_1");
    XCTAssertNil(cache[@"KEY_2"]);
    XCTAssertEqualObjects(cache[@"KEY_3"], @"VALUE_3");
    
    XCTAssertEqual(cache.count, 2);
}

- (void)testGet {
    SimpleCache *cache = [[SimpleCache alloc] initWithLimit:2];
    
    cache[@"KEY_1"] = @"VALUE_1";
    cache[@"KEY_2"] = @"VALUE_2";
    XCTAssertEqualObjects(cache[@"KEY_1"], @"VALUE_1");
    cache[@"KEY_3"] = @"VALUE_3";
    XCTAssertEqualObjects(cache[@"KEY_1"], @"VALUE_1");
    XCTAssertNil(cache[@"KEY_2"]);
    XCTAssertEqualObjects(cache[@"KEY_3"], @"VALUE_3");
    
    XCTAssertEqual(cache.count, 2);
}

- (void)testGetAbsent1 {
    SimpleCache *cache = [[SimpleCache alloc] initWithLimit:2];
    
    cache[@"KEY_1"] = @"VALUE_1";
    cache[@"KEY_2"] = @"VALUE_2";
    
    XCTAssertNil(cache[@"KEY_4"]);
    XCTAssertNil(cache[@"KEY_5"]);
    XCTAssertNil(cache[@"KEY_6"]);
    
    XCTAssertEqualObjects(cache[@"KEY_1"], @"VALUE_1");
    
    cache[@"KEY_3"] = @"VALUE_3";
    
    XCTAssertEqualObjects(cache[@"KEY_1"], @"VALUE_1");
    XCTAssertNil(cache[@"KEY_2"]);
    XCTAssertEqualObjects(cache[@"KEY_3"], @"VALUE_3");
    
    XCTAssertEqual(cache.count, 2);
}

- (void)testGetAbsent2 {
    SimpleCache *cache = [[SimpleCache alloc] initWithLimit:2];
    
    XCTAssertNil(cache[@"KEY_1"]);
    XCTAssertNil(cache[@"KEY_2"]);
    XCTAssertNil(cache[@"KEY_3"]);
    
    cache[@"KEY_1"] = @"VALUE_1";
    cache[@"KEY_2"] = @"VALUE_2";
    cache[@"KEY_3"] = @"VALUE_3";
    
    XCTAssertNil(cache[@"KEY_1"]);
    XCTAssertEqualObjects(cache[@"KEY_2"], @"VALUE_2");
    XCTAssertEqualObjects(cache[@"KEY_3"], @"VALUE_3");
    
    XCTAssertEqual(cache.count, 2);
}

- (void)testRemove {
    SimpleCache *cache = [[SimpleCache alloc] initWithLimit:2];
    
    cache[@"KEY_1"] = @"VALUE_1";
    cache[@"KEY_2"] = @"VALUE_2";
    
    [cache removeObjectForKey:@"KEY_2"];
    
    cache[@"KEY_3"] = @"VALUE_3";
    
    XCTAssertEqualObjects(cache[@"KEY_1"], @"VALUE_1");
    XCTAssertNil(cache[@"KEY_2"]);
    XCTAssertEqualObjects(cache[@"KEY_3"], @"VALUE_3");
    
    XCTAssertEqual(cache.count, 2);
}

- (void)testRemoveAbsent {
    SimpleCache *cache = [[SimpleCache alloc] initWithLimit:2];
    
    cache[@"KEY_1"] = @"VALUE_1";
    cache[@"KEY_2"] = @"VALUE_2";
    
    [cache removeObjectForKey:@"KEY_3"];
    [cache removeObjectForKey:@"KEY_4"];
    
    cache[@"KEY_3"] = @"VALUE_3";
    
    XCTAssertNil(cache[@"KEY_1"]);
    XCTAssertEqualObjects(cache[@"KEY_2"], @"VALUE_2");
    XCTAssertEqualObjects(cache[@"KEY_3"], @"VALUE_3");
    
    XCTAssertEqual(cache.count, 2);
}

- (void)testRemoveAll {
    SimpleCache *cache = [[SimpleCache alloc] initWithLimit:2];
    
    cache[@"KEY_1"] = @"VALUE_1";
    cache[@"KEY_2"] = @"VALUE_2";
    cache[@"KEY_3"] = @"VALUE_3";
    
    [cache removeAllObjects];
    
    XCTAssertNil(cache[@"KEY_1"]);
    XCTAssertNil(cache[@"KEY_2"]);
    XCTAssertNil(cache[@"KEY_3"]);
    
    XCTAssertEqual(cache.count, 0);
}

- (void)testThreadSafety {
    SimpleCache *cache = [[SimpleCache alloc] init];
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create(NULL, DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_group_async(group, queue, ^{
        [self setManyObjects:cache];
        [self getManyObjects:cache];
    });
    dispatch_group_async(group, queue, ^{
        [self setManyObjects:cache];
        [self getManyObjects:cache];
    });
    dispatch_group_async(group, queue, ^{
        [self setManyObjects:cache];
        [self getManyObjects:cache];
    });
    
    dispatch_group_notify(group, queue, ^{
        NSArray *allKeys = cache.allKeys;
        for (id key in allKeys) {
            XCTAssertEqualObjects(key, cache[key]);
        }
    });
}

- (void)setManyObjects:(SimpleCache *)cache {
    for (int i = 0; i < 1000000; i++) {
        NSString *key = [NSString stringWithFormat:@"%d", arc4random()];
        NSString *object = key;
        cache[key] = object;
    }
}

- (NSArray *)getManyObjects:(SimpleCache *)cache {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < 1000000; i++) {
        NSString *key = [NSString stringWithFormat:@"%02d", i];
        NSString *object = cache[key];
        if (object) {
            [array addObject:object];
        }
    }
    return array.copy;
}

- (void)testPerformance {
    const int count = 10000;
    SimpleCache *cache = [[SimpleCache alloc] initWithLimit:count];
    
    [self measureBlock:^{
        for (int i = 0; i < count; i++) {
            NSString *key = [NSString stringWithFormat:@"%d", arc4random_uniform(count)];
            NSString *object = key;
            cache[key] = object;
        }
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (int i = 0; i < count; i++) {
            NSString *key = [NSString stringWithFormat:@"%d", arc4random_uniform(count)];
            NSString *object = cache[key];
            if (object) {
                [array addObject:object];
            }
        }
    }];
}

@end
