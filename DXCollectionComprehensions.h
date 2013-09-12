//
//  DXCollectionComprehensions.h
//  CollectionComprehensionSample
//
//  Created by Tim Gostony on 9/12/13.
//  Copyright (c) 2013 Tim Gostony. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - Types

@class Tuple;

typedef Tuple* (^TupleToTupleBlock)(Tuple* tuple);
typedef NSObject* (^TupleToObjectBlock)(Tuple* tuple);
typedef NSObject* (^ObjectAndIndexToObjectBlock)(NSObject* object, int index);
typedef BOOL (^TupleToBoolBlock)(Tuple* tuple);
typedef BOOL (^ObjectAndIndexToBoolBlock)(NSObject* object, int index);

#pragma mark - Dictionary categories

@interface NSDictionary (Map)

- (NSDictionary*)map:(TupleToTupleBlock)mapFunction;
- (NSArray*)mapToArray:(TupleToObjectBlock)mapFunction;

@end

@interface NSDictionary (Filter)

- (NSDictionary*)filter:(TupleToBoolBlock)filterFunction;

@end

@interface NSDictionary (Tuple)

+ (NSDictionary*)dictionaryWithTuples:(NSArray*)tuples;
- (NSDictionary*)initWithTuples:(NSArray*)tuples;

@end

@interface NSMutableDictionary (Tuple)

- (void)addTuple:(Tuple*)tuple;

@end

#pragma mark - Array categories

@interface NSArray (Map)

- (NSArray*)map:(ObjectAndIndexToObjectBlock)mapFunction;

@end

@interface NSArray (Filter)

- (NSArray*)filter:(ObjectAndIndexToBoolBlock)filterFunction;

@end


#pragma mark - Tuple

@interface Tuple : NSObject

+(Tuple*)tupleWithValue:(NSObject*)value forKey:(NSObject<NSCopying>*)key;

-(Tuple*)initWithValue:(NSObject*)value forKey:(NSObject<NSCopying>*)key;

@property (nonatomic, retain) NSObject<NSCopying>* key;
@property (nonatomic, retain) NSObject* value;

@end