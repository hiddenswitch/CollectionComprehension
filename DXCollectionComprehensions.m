//
//  DXCollectionComprehensions.m
//  CollectionComprehensionSample
//
//  Created by Tim Gostony on 9/12/13.
//  Copyright (c) 2013 Tim Gostony. All rights reserved.
//

#import "DXCollectionComprehensions.h"

#pragma mark - Dictionary categories

@implementation NSDictionary (Comprehensions)

-(NSDictionary *)mappedDictionaryUsingBlock:(TupleToTupleBlock)mapFunction
{
    return [NSDictionary dictionaryWithTuples:[self.tuples mappedArrayUsingBlock:^id(id object, NSUInteger index) {
        Tuple* tuple = (Tuple*)object;
        return mapFunction(tuple);
    }]];
    
}

-(NSArray *)mappedArrayUsingBlock:(TupleToObjectBlock)mapFunction
{
    return [self.tuples mappedArrayUsingBlock:^id (id object, NSUInteger index) {
        return mapFunction((Tuple*)object);
    }];

}

@end

@implementation NSDictionary (Filter)

-(NSDictionary *)filteredDictionaryUsingBlock:(TupleToBoolBlock)filterFunction
{
    return [NSDictionary dictionaryWithTuples:[self.tuples filteredArrayUsingBlock:^BOOL(id object, NSUInteger index) {
        return filterFunction((Tuple*)object);
    }]];
}

@end

@implementation NSDictionary (Tuple)

+(NSDictionary*)dictionaryWithTuples:(NSArray*)tuples;
{
    return [[[NSDictionary alloc] initWithTuples:tuples] autorelease];
}

-(NSDictionary *)initWithTuples:(NSArray *)tuples
{
    // we use [self initWithObjects...] instead of [super initWithObjects...] because we are not a subclass of NSDictionary, we are a category
    self = [self initWithObjects:[tuples valueForKey:@"value"] forKeys:[tuples valueForKey:@"key"]];
    return self;
}

-(NSArray *)tuples
{
    return [self.allKeys mappedArrayUsingBlock:^id(id object, NSUInteger index) {
        return [Tuple tupleWithValue:self[object] forKey:(id<NSCopying,NSObject>)object];
    }];

}

@end

@implementation NSMutableDictionary (Tuple)

-(void)addTuple:(Tuple *)tuple
{
    [self setObject:tuple.value forKey:tuple.key];
}

@end

#pragma mark - Array categories

@implementation NSArray (Map)

-(NSArray *)mappedArrayUsingBlock:(ObjectAndIndexToObjectBlock)mapFunction
{
    dispatch_queue_t queue = dispatch_queue_create("map queue", DISPATCH_QUEUE_CONCURRENT);
    NSArray* result = [self map:mapFunction onQueue:queue];
    dispatch_release(queue);
    return result;
}

-(NSArray *)map:(ObjectAndIndexToObjectBlock)mapFunction onQueue:(dispatch_queue_t)queue
{
    
    NSArray* retVal;
    NSUInteger count = self.count;
    id* results = malloc(count * sizeof(id));
    dispatch_apply(count, queue, ^(size_t index)
    {
        id obj = mapFunction(self[(int)index], (int)index);
        results[index] = [obj retain];
    });
    retVal = [NSArray arrayWithObjects:results count:count];
    dispatch_apply(count, queue, ^(size_t index)
    {
        [results[index] release];
    });
    free(results);
    
    return retVal;
}

@end

@implementation NSArray (MapAndJoin)

-(NSArray *)mappedAndJoinedArrayUsingBlock:(ObjectAndIndexToArrayBlock)mapFunction
{
    
    dispatch_queue_t queue = dispatch_queue_create("map and join queue", DISPATCH_QUEUE_CONCURRENT);
    NSArray* result = [self mapAndJoin:mapFunction onQueue:queue];
    dispatch_release(queue);
    return result;
}

-(NSArray *)mapAndJoin:(ObjectAndIndexToArrayBlock)mapFunction onQueue:(dispatch_queue_t)queue
{
    NSMutableArray* result = [NSMutableArray arrayWithCapacity:self.count];
    
    NSArray* mapped = [self map:mapFunction onQueue:queue];
    
    for(NSArray* array in mapped)
    {
        [result addObjectsFromArray:array];
    }
    return result;
}

@end



@implementation NSArray (Filter)

-(NSArray *)filteredArrayUsingBlock:(ObjectAndIndexToBoolBlock)filterFunction
{
    dispatch_queue_t queue = dispatch_queue_create("filter queue", DISPATCH_QUEUE_CONCURRENT);
    NSArray* result = [self filter:filterFunction onQueue:queue];
    dispatch_release(queue);
    return result;
}

-(NSArray *)filter:(ObjectAndIndexToBoolBlock)filterFunction onQueue:(dispatch_queue_t)queue
{    
    NSArray* retVal;
    NSUInteger count = self.count;
    id* results = malloc(count * sizeof(id));
    dispatch_apply(count, queue, ^(size_t index)
    {
        id obj = self[(int)index];
        BOOL add = filterFunction(self[(int)index], (int)index);
        if(add == YES)
        {
            results[index] = [obj retain];
        }
        else
        {
            results[index] = nil;
        }
    });
    id* newResults = malloc(count * sizeof(id));
    int resultCount = 0;
    for(int i=0; i < count; i++)
    {
        if(results[i] != nil)
        {
            newResults[resultCount++] = results[i];
        }
    }
    retVal = [NSArray arrayWithObjects:newResults count:resultCount];
    dispatch_apply(count, queue, ^(size_t index)
    {
        [results[index] release];
    });
    free(results);
    free(newResults);

    return retVal;
    
}

@end



@implementation NSArray (FilterFirstObject)

-(id)firstObjectMatchingFilter:(ObjectAndIndexToBoolBlock)filterFunction
{
    dispatch_queue_t queue = dispatch_queue_create("filter first queue", DISPATCH_QUEUE_CONCURRENT);
    id result = [self firstObjectMatchingFilter:filterFunction onQueue:queue];
    dispatch_release(queue);
    return result;
}

-(id)firstObjectMatchingFilter:(ObjectAndIndexToBoolBlock)filterFunction onQueue:(dispatch_queue_t)queue
{
    id retVal = nil;
    NSUInteger count = self.count;
    id* results = malloc(count * sizeof(id));
    memset(results, 0, count * sizeof(id));
    __block unsigned long lowest = ULONG_MAX;
    dispatch_apply(count, queue, ^(size_t index)
    {
        if(index < lowest)
        {
            id obj = self[(int)index];
            BOOL add = filterFunction(self[(int)index], (int)index);
            if(add == YES)
            {
                results[index] = [obj retain];
                lowest = index;
            }
        }
    });
    // find the lowest index within count
    for(int i=0; i < count && retVal == nil; i++)
    {
        if(results[i] != nil)
        {
            retVal = [results[i] retain];
        }
    }
    dispatch_apply(count, queue, ^(size_t index)
    {
        [results[index] release];
    });
    free(results);
    
    return retVal;
    
}

@end

#pragma mark - Tuple

@implementation Tuple

-(Tuple *)initWithValue:(id)value forKey:(id<NSCopying,NSObject>)key
{
    if(self = [super init])
    {
        _key = [key retain];
        _value = [value retain];
    }
    return self;
}

+(Tuple *)tupleWithValue:(id)value forKey:(id<NSCopying,NSObject>)key
{
    return [[[Tuple alloc] initWithValue:value forKey:key] autorelease];
}

-(BOOL)isEqual:(id)object
{
    return [self.key isEqual:((Tuple*)object).key] &&
           [self.value isEqual:((Tuple*)object).value];
}

-(void)dealloc
{
    [_key release];
    [_value release];
    [super dealloc];
}

@end
