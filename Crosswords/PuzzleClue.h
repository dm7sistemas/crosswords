//
//  PuzzleClue.h
//  Crosswords
//
//  Created by Mark Alldritt on 2/13/2014.
//  Copyright (c) 2014 Late Night Software Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PuzzleHelper;

@interface PuzzleClue : NSObject

@property (weak, readonly, nonatomic) PuzzleHelper* puzzle;
@property (readonly, nonatomic) NSUInteger row;
@property (readonly, nonatomic) NSUInteger column;
@property (readonly, nonatomic) NSUInteger gridNumber;
@property (readonly, nonatomic) BOOL across;
@property (readonly, nonatomic) NSString* clue;
@property (readonly, nonatomic) NSString* answer;
@property (readonly, nonatomic) NSArray* words;

@property (readonly, nonatomic) NSUInteger length; // length in grid cells of the answer
@property (readonly, nonatomic) CGRect area; // area in grid cells of the answer
@property (readonly, nonatomic) NSArray* siblingClues; // portions of the answer sharing the same clue
@property (readonly, nonatomic) BOOL isPrimary;
@property (readonly, nonatomic) PuzzleClue* primaryClue;
@property (readonly, nonatomic) NSArray* intersectingClues;
@property (readonly, nonatomic) NSString* answerLetterCounts;
@property (readonly, nonatomic) NSString* answerSeeAlsos;
@property (readonly, nonatomic) NSString* displayClue; // stripped of letter counts

- (instancetype)initWithPuzzle:(PuzzleHelper*) puzzle
                           row:(NSUInteger) row
                        column:(NSUInteger) column
                    gridNumber:(NSUInteger) gridNum
                        across:(BOOL) across
                          clue:(NSString*) clue
                        answer:(NSString*) answer
                         words:(NSArray*) words;

@end
