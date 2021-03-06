//
//  SimpleCache.m
//  SimpleCache
//
//  Created by kishikawa katsumi on 2015/01/08.
//  Copyright (c) 2015 kishikawa katsumi. All rights reserved.
//

#import "SimpleCache.h"

static const NSUInteger DefaultLimit = 10;

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
        [self insertObject:node beforeObject:_firstNode];
    }
}

- (void)insertObject:(Node *)newNode beforeObject:(Node *)node {
    newNode.previousNode = node.previousNode;
    newNode.nextNode = node;
    if (!node.previousNode) {
        _firstNode = newNode;
    } else {
        node.previousNode.nextNode = newNode;
    }
    node.previousNode = newNode;
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
    node.previousNode = nil;
    node.nextNode = nil;
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

@property (nonatomic) NSURLSession *session;
@property (nonatomic) NSMutableDictionary *tasks;

@end

@implementation SimpleCache

- (instancetype)init {
    return [self initWithLimit:DefaultLimit];
}

- (instancetype)initWithLimit:(NSUInteger)limit {
    self = [super init];
    if (self) {
        _dictionary = [[NSMutableDictionary alloc] initWithCapacity:limit];
        _list = [[List alloc] init];
        
        _limit = limit;
        
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        _tasks = [[NSMutableDictionary alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [self cancelAllDownloads];
    [_session invalidateAndCancel];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

#pragma mark -

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

#pragma mark -

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

#pragma mark -

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

#pragma mark -

- (UIImage *)imageWithURL:(NSURL *)imageURL placeholderImage:(UIImage *)placeholderImage completionHandler:(void (^)(UIImage *image, NSURL *imageURL, NSError *error))completionHandler {
    if (!imageURL) {
        return placeholderImage;
    }
    
    UIImage *cachedImage = self[imageURL.absoluteString];
    if (cachedImage) {
        return cachedImage;
    }
    
    @synchronized(self) {
        NSURLSessionTask *task = [_session dataTaskWithURL:imageURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            UIImage *image;
            if (!error && data) {
                UIImage *downloadedImage = [UIImage imageWithData:data];
                if (downloadedImage) {
                    self[imageURL.absoluteString] = downloadedImage;
                    image = downloadedImage;
                }
            }
            
            if (completionHandler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler(image, imageURL, error);
                });
            }
            
            [_tasks removeObjectForKey:imageURL.absoluteString];
        }];
        [task resume];
        
        _tasks[imageURL.absoluteString] = task;
        
        return placeholderImage;
    }
}

- (void)cancelDownloadURL:(NSURL *)downloadURL {
    NSString *key = downloadURL.absoluteString;
    if (!key) {
        return;
    }
    
    @synchronized(self) {
        NSURLSessionTask *task = _tasks[key];
        [task cancel];
        
        [_tasks removeObjectForKey:key];
    }
}

- (void)cancelAllDownloads {
    @synchronized(self) {
        [_tasks.allValues makeObjectsPerformSelector:@selector(cancel)];
        [_tasks removeAllObjects];
    }
}

#pragma mark -

- (id)peekObjectForKey:(id)key {
    @synchronized(self) {
        return _dictionary[key];
    }
}

- (void)didReceiveMemoryWarning:(NSNotification *)notification {
    [self removeAllObjects];
}

#pragma mark -

- (NSString *)description {
    return [NSString stringWithFormat:@"%@", _list];
}

@end
