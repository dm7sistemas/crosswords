//
//  PuzzleHelper.h
//  Crosswords
//
//  Created by Mark Alldritt on 2/6/2014.
//  Copyright (c) 2014 Late Night Software Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PuzzleHelper : NSObject

@property (strong, readonly, nonatomic) NSDictionary* puzzle;
@property (readonly, nonatomic) NSDictionary* cluesAcross;
@property (readonly, nonatomic) NSDictionary* cluesDown;

- (instancetype)initWithPuzzle:(NSDictionary*)puzzle;

- (NSArray*)cluesAtRow:(NSInteger)row column:(NSInteger)column;
- (NSDictionary*)bestClueForRow:(NSInteger)row column:(NSInteger)column;
- (NSArray*)cluesIntersectingClue:(NSDictionary*) clue;

@end
