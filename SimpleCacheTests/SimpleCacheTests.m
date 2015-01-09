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

- (void)testSet1 {
    SimpleCache *cache = [[SimpleCache alloc] init];
    
    cache[@"KEY_1"] = @"VALUE_1";
    XCTAssertEqualObjects(cache[@"KEY_1"], @"VALUE_1");
    XCTAssertEqual(cache.count, 1);
}

- (void)testSet2 {
    SimpleCache *cache = [[SimpleCache alloc] initWithLimit:2];
    
    [cache setObject:@"VALUE_1" forKey:@"KEY_1"];
    XCTAssertEqualObjects([cache objectForKey:@"KEY_1"], @"VALUE_1");
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

- (void)testSetNil1 {
    SimpleCache *cache = [[SimpleCache alloc] init];
    
    cache[@"KEY_1"] = @"VALUE_1";
    cache[@"KEY_1"] = nil;
    XCTAssertEqualObjects(cache[@"KEY_1"], @"VALUE_1");
    XCTAssertEqual(cache.count, 1);
}

- (void)testSetNil2 {
    SimpleCache *cache = [[SimpleCache alloc] init];
    
    [cache setObject:@"VALUE_1" forKey:@"KEY_1"];
    [cache setObject:nil forKey:@"KEY_1"];
    XCTAssertEqualObjects([cache objectForKey:@"KEY_1"], @"VALUE_1");
    XCTAssertEqual(cache.count, 1);
}

- (void)testGetNil1 {
    SimpleCache *cache = [[SimpleCache alloc] init];
    
    NSString *key = nil;
    XCTAssertNil(cache[key]);
}

- (void)testGetNil2 {
    SimpleCache *cache = [[SimpleCache alloc] init];
    
    NSString *key = nil;
    XCTAssertNil([cache objectForKey:key]);
}

- (void)testAllKeys {
    SimpleCache *cache = [[SimpleCache alloc] initWithLimit:2];
    
    cache[@"KEY_1"] = @"VALUE_1";
    cache[@"KEY_2"] = @"VALUE_2";
    cache[@"KEY_3"] = @"VALUE_3";
    
    NSArray *allKeys = cache.allKeys;
    
    XCTAssertEqual(allKeys.count, 2);
    XCTAssertTrue([allKeys indexOfObject:@"KEY_3"] != NSNotFound);
    XCTAssertTrue([allKeys indexOfObject:@"KEY_2"] != NSNotFound);
}

- (void)testAllValues {
    SimpleCache *cache = [[SimpleCache alloc] initWithLimit:2];
    
    cache[@"KEY_1"] = @"VALUE_1";
    cache[@"KEY_2"] = @"VALUE_2";
    cache[@"KEY_3"] = @"VALUE_3";
    
    NSArray *allValues = cache.allValues;
    
    XCTAssertEqualObjects(allValues, (@[@"VALUE_3", @"VALUE_2"]));
}

- (void)testThreadSafety1 {
    SimpleCache *cache = [[SimpleCache alloc] init];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"join"];
    
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
        [expectation fulfill];
        
        NSArray *allKeys = cache.allKeys;
        for (id key in allKeys) {
            XCTAssertEqualObjects(key, cache[key]);
        }
        XCTAssertEqual(cache.count, 10);
    });
    
    [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testThreadSafety2 {
    SimpleCache *cache = [[SimpleCache alloc] init];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"join"];
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create(NULL, DISPATCH_QUEUE_CONCURRENT);
    
    for (int i = 0; i < 10; i++) {
        dispatch_group_async(group, queue, ^{
            for (int j = 0; j < 10000; j++) {
                NSString *key = [NSString stringWithFormat:@"%d", arc4random_uniform(100)];
                NSString *object = key;
                cache[key] = object;
                
                key = [NSString stringWithFormat:@"%d", arc4random_uniform(100)];
                object = cache[key];
                
                cache[key] = object;
            }
        });
    }
    
    dispatch_group_notify(group, queue, ^{
        [expectation fulfill];
        
        NSArray *allKeys = cache.allKeys;
        for (id key in allKeys) {
            XCTAssertEqualObjects(key, cache[key]);
        }
        XCTAssertEqual(cache.count, 10);
    });
    
    [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)setManyObjects:(SimpleCache *)cache {
    for (int i = 0; i < 10000; i++) {
        NSString *key = [NSString stringWithFormat:@"%d", arc4random_uniform(100)];
        NSString *object = key;
        cache[key] = object;
    }
}

- (NSArray *)getManyObjects:(SimpleCache *)cache {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < 10000; i++) {
        NSString *key = [NSString stringWithFormat:@"%02d", arc4random_uniform(100)];
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
