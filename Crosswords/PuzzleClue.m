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

- (instancetype)initWithPuzzle:(PuzzleHelper*) puzzle
                           row:(NSUInteger) row
                        column:(NSUInteger) column
                    gridNumber:(NSUInteger) gridNumber
                        across:(BOOL) across
                          clue:(NSString*) clue
                        answer:(NSString*) answer {
    if ((self = [super init])) {
        _puzzle = puzzle;
        _row = row;
        _column = column;
        _gridNumber = gridNumber;
        _across = across;
        _clue = clue;
        _answer = answer;
    }
    
    return self;
}

- (CGRect)area {
    return self.across ? CGRectMake(self.column, self.row, self.length, 1.0) : CGRectMake(self.column, self.row, 1.0, self.length);
}

- (NSUInteger) length {
    //  Note that the answer may be longer for "trick" puzzles where a grid cell can
    //  hold more than one letter.  This method needs to be made aware of this and
    //  return an accurate number of grid cells for the clue.

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
        NSAssert3([[self.answer substringWithRange:NSMakeRange(i, s.length)] isEqualToString:s], @"Answer '%@' does not match grid ('%@' != '%@')", self.answer, [self.answer substringWithRange:NSMakeRange(i, s.length)], s);
        
        i += s.length;
        result += 1;
        if (self.across)
            ++column;
        else
            ++row;
    }
    return result;
}

- (NSArray*) words {
#warning TODO
    //  Some anwsers are made up of multiple words.  The JSON data format we are iusing does not
    //  provide a means of representing this.  In time, I'll have to sort that out and make this
    //  accessor returning something useful.
    
#if 0
    //  Debug code to simulate word ranges within an answer.  Matt's cryptic crossword has these, so when I get that
    //  imported, all this code can go.
    if (!words) {
        //  For testing, simulate some data
        NSMutableArray* r = [NSMutableArray array];
        NSString* answer = clue.answer;
        NSUInteger p = 0;
        
        while (p + 5 < answer.length) {
            [r addObject:[NSValue valueWithRange:NSMakeRange(p, 5)]];
            p += 5;
        }
        if (p > 0) {
            [r addObject:[NSValue valueWithRange:NSMakeRange(p, answer.length - p)]];
            words = r.copy;
        }
    }
#else
    return nil;
#endif
}

- (NSArray*) intersectingClues {
    //  Determine all the clues that intersect with the answer for a clue.  This is brute force, but for now, its good enough.
    
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
    
    return result.copy; // return a non-mutable version...
}

@end
