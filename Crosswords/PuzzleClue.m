//
//  PuzzleClue.m
//  Crosswords
//
//  Created by Mark Alldritt on 2/13/2014.
//  Copyright (c) 2014 Late Night Software Ltd. All rights reserved.
//

#import "PuzzleClue.h"
#import "PuzzleHelper.h"


@implementation PuzzleClue

@synthesize intersectingClues = mIntersectingClues;
@synthesize length = mLength;

- (instancetype)initWithPuzzle:(PuzzleHelper*) puzzle
                           row:(NSUInteger) row
                        column:(NSUInteger) column
                    gridNumber:(NSUInteger) gridNumber
                        across:(BOOL) across
                          clue:(NSString*) clue
                        answer:(NSString*) answer
                         words:(NSArray*) words {
    if ((self = [super init])) {
        _puzzle = puzzle;
        _row = row;
        _column = column;
        _gridNumber = gridNumber;
        _across = across;
        _clue = clue;
        _answer = answer;
        _words = words;
    }
    
    return self;
}

- (CGRect)area {
    return self.across ? CGRectMake(self.column, self.row, self.length, 1.0) : CGRectMake(self.column, self.row, 1.0, self.length);
}

- (NSUInteger) length {
    //  Note that the answer may be longer for "trick" puzzles where a grid cell can hold more than one letter.  This method
    //  addresses this issue and returns a length in Grid Cells even when an answer string is longer.

    //  Cache this value on demand...
    if (mLength == 0) {
        NSArray* grid = self.puzzle.puzzle[@"grid"];
        NSUInteger rows = self.puzzle.rows;
        NSUInteger columns = self.puzzle.columns;
        NSUInteger row = self.row;
        NSUInteger column = self.column;
        NSUInteger result = 0;
        NSUInteger answerLength = self.answer.length;
        NSUInteger i = 0;
        
        while (i < answerLength) {
            NSAssert2(row < rows, @"row (%d) too large (%d)", (int)row, (int)rows);
            NSAssert2(column < columns, @"column (%d) too large (%d)", (int)column, (int)columns);
            NSString* s = grid[columns * row + column];
            NSAssert3([s isEqualToString:@" "] || [[self.answer substringWithRange:NSMakeRange(i, s.length)] isEqualToString:s], @"Answer '%@' does not match grid ('%@' != '%@')", self.answer, [self.answer substringWithRange:NSMakeRange(i, s.length)], s);
            
            i += s.length;
            result += 1;
            if (self.across)
                ++column;
            else
                ++row;
        }
        mLength = result;
    }
    return mLength;
}

- (NSArray*) intersectingClues {
    //  Determine all the clues that intersect with the answer for a clue.  This is brute force, but for now, its good enough.
    
    //  Cache this value on demand...
    if (!mIntersectingClues) {
        CGRect clueArea = self.area;
        NSMutableArray* result = nil;
        
        for (PuzzleClue* aClue in self.puzzle.cluesAcross.allValues) {
            if (![aClue isEqual:self] && CGRectIntersectsRect(clueArea, aClue.area)) {
                if (result)
                    [result addObject:aClue];
                else
                    result = [NSMutableArray arrayWithObject:aClue];
            }
        }
        for (PuzzleClue* aClue in self.puzzle.cluesDown.allValues) {
            if (![aClue isEqual:self] && CGRectIntersectsRect(clueArea, aClue.area)) {
                if (result)
                    [result addObject:aClue];
                else
                    result = [NSMutableArray arrayWithObject:aClue];
            }
        }
        
        mIntersectingClues = result.copy; // non-mutable version is cached
    }
    
    return mIntersectingClues;
}

- (NSString*)answerLetterCounts {
    NSArray* words = self.words;
    
    if (words) {
        NSUInteger numWords = words.count;
        NSString* result = @"";
        
        for (NSUInteger i = 0; i < numWords; ++i) {
            if (result.length == 0)
                result = [NSString stringWithFormat:@"%d", (int)[words[i] rangeValue].length];
            else if (i != numWords - 1)
                result = [NSString stringWithFormat:@"%@, %d", result, (int)[words[i] rangeValue].length];
            else
                result = [NSString stringWithFormat:@"%@ and %d", result, (int)[words[i] rangeValue].length];
        }
        
        return [NSString stringWithFormat:@"%@ letters", result];
    }
    else
        return [NSString stringWithFormat:@"%d letters", (int)self.answer.length];
}

- (NSString*)displayClue {
    //  Strip of any trailing letter count indications to make the clue string a little shorter.  This is used in sutations where
    //  letter counts are displayed elsewhere in the UI.
    NSRegularExpression* regEx = [NSRegularExpression regularExpressionWithPattern:@"(.*?)\\s+\\([0-9, ]+\\)?$" options:0 error:nil];
    NSTextCheckingResult* match = [regEx firstMatchInString:self.clue options:0 range:NSMakeRange(0, self.clue.length)];
    
    if (match) {
        NSAssert1(match.numberOfRanges == 2, @"invalid clue string: '%@'", self.clue); // make the code defensive for this in future
        
        return [self.clue substringWithRange:[match rangeAtIndex:1]];
    }
    else
        return self.clue;
}

@end
