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

-(NSDictionary *)map:(TupleToTupleBlock)mapFunction
{
    
    NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
    
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [result addTuple:mapFunction([Tuple tupleWithValue:obj forKey:key])];
    }];
    
    NSDictionary* retVal = [NSDictionary dictionaryWithDictionary:result];
    [result release];
    return retVal;
    
}

-(NSArray *)mapToArray:(TupleToObjectBlock)mapFunction
{
    NSMutableArray* result = [[NSMutableArray alloc] init];
    
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        Tuple* tuple = [[Tuple alloc] initWithValue:obj forKey:key];
        [result addObject:mapFunction(tuple)];
        [tuple release];
    }];
    
    NSArray* retVal = [NSArray arrayWithArray:result];
    [result release];
    return retVal;
}

@end

@implementation NSDictionary (Filter)

-(NSDictionary *)filter:(TupleToBoolBlock)filterFunction
{
    NSMutableDictionary* result = [NSMutableDictionary dictionary];
    
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        Tuple* tuple = [[Tuple alloc] initWithValue:obj forKey:key];
        if(filterFunction(tuple))
        {
            [result addTuple:tuple];
        }
        [tuple release];
    }];
    
    
    NSDictionary* retVal = [NSDictionary dictionaryWithDictionary:result];
    [result release];
    return retVal;
}

@end

@implementation NSDictionary (Tuple)

+(NSDictionary*)dictionaryWithTuples:(NSArray*)tuples;
{
    return [[[NSDictionary alloc] initWithTuples:tuples] autorelease];
}

-(NSDictionary *)initWithTuples:(NSArray *)tuples
{
    return [[NSDictionary alloc] initWithObjects:[tuples valueForKey:@"value"] forKeys:[tuples valueForKey:@"key"]];
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

-(NSArray *)map:(ObjectAndIndexToObjectBlock)mapFunction
{
    NSMutableArray* result = [[NSMutableArray alloc] init];
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [result addObject:mapFunction(obj, idx)];
    }];
    
    NSArray* retVal = [NSArray arrayWithArray:result];
    [result release];
    return retVal;
}

-(NSArray *)filter:(ObjectAndIndexToBoolBlock)filterFunction
{
    NSMutableArray* result = [[NSMutableArray alloc] init];
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if(filterFunction(obj, idx) == YES)
        {
            [result addObject:obj];
        }
    }];
    
    NSArray* retVal = [NSArray arrayWithArray:result];
    [result release];
    return retVal;
    
}

@end

#pragma mark - Tuple

@implementation Tuple

-(Tuple *)initWithValue:(NSObject*)value forKey:(NSObject<NSCopying>*)key
{
    if(self = [super init])
    {
        _key = [key retain];
        _value = [value retain];
    }
    return self;
}

+(Tuple *)tupleWithValue:(NSObject*)value forKey:(NSObject<NSCopying>*)key
{
    return [[[Tuple alloc] initWithValue:value forKey:key] autorelease];
}

-(void)dealloc
{
    [_key release];
    [_value release];
    [super dealloc];
}

@end