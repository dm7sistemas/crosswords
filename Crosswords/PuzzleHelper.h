//
//  PuzzleHelper.h
//  Crosswords
//
//  Created by Mark Alldritt on 2/6/2014.
//  Copyright (c) 2014 Late Night Software Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PuzzleClue;

@interface PuzzleHelper : NSObject

@property (strong, readonly, nonatomic) NSDictionary* puzzle;
@property (readonly, nonatomic) NSString* title;
@property (readonly, nonatomic) NSString* author;
@property (readonly, nonatomic) BOOL hasAuthor;
@property (readonly, nonatomic) NSString* editor;
@property (readonly, nonatomic) NSString* publisher;
@property (readonly, nonatomic) NSString* copyright;
@property (readonly, nonatomic) NSString* notes;
@property (readonly, nonatomic) NSDictionary* cluesAcross;
@property (readonly, nonatomic) NSDictionary* cluesDown;
@property (readonly, nonatomic) NSUInteger rows;
@property (readonly, nonatomic) NSUInteger columns;
@property (readonly, nonatomic) NSArray* playerGrid;

- (instancetype)initWithPuzzle:(NSDictionary*)puzzle filename:(NSString*) filename;

- (NSArray*)cluesAtRow:(NSInteger)row column:(NSInteger)column;
- (PuzzleClue*)bestClueForRow:(NSInteger)row column:(NSInteger)column;

@end
