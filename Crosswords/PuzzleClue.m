//
//  PuzzleClue.m
//  Crosswords
//
//  Created by Mark Alldritt on 2/13/2014.
//  Copyright (c) 2014 Late Night Software Ltd. All rights reserved.
//

#import "PuzzleClue.h"
#import "Puzzle.h"


@implementation PuzzleClue

@synthesize intersectingClues = mIntersectingClues;
@synthesize length = mLength;

- (instancetype)initWithPuzzle:(Puzzle*) puzzle
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

- (NSUInteger)length {
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

- (NSArray*)intersectingClues {
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

- (NSArray*)siblingClues {
    //  This is corrently done using huristics.  Some clues are written as 'See n' while others are written as
    //  '(See n) clue text'.  The clues that contain 'clue text' are considered the primary clue.  This code
    //  attempts to link these corss references together.  All of this is very fragile and I'm sure we'll
    //  encounter puzzles that do this kind if clue linking in a different way.  However, it gets the Guardien
    //  puzzles working.

    NSRegularExpression* regEx = [NSRegularExpression regularExpressionWithPattern:@"^\\s*\\(see\\s+(\\d+)\\)" options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult* match = [regEx firstMatchInString:self.clue options:0 range:NSMakeRange(0, self.clue.length)];
    NSUInteger clueNo = 0;
    BOOL isPrimary = NO; // primary clue contains clue text, non-primary contains only a reference to the primary clue
    
    if (match) {
        clueNo = [self.clue substringWithRange:[match rangeAtIndex:1]].intValue;
        isPrimary = YES;
    }
    else {
        regEx = [NSRegularExpression regularExpressionWithPattern:@"^\\s*see\\s+(\\d+)" options:NSRegularExpressionCaseInsensitive error:nil];
        match = [regEx firstMatchInString:self.clue options:0 range:NSMakeRange(0, self.clue.length)];

        if (match)
            clueNo = [self.clue substringWithRange:[match rangeAtIndex:1]].intValue;
    }
    
    if (clueNo > 0) {
        PuzzleClue* clue = self.puzzle.cluesAcross[@(clueNo)];
        
        if (!clue)
            clue = self.puzzle.cluesDown[@(clueNo)];

        NSAssert2(clue != nil, @"clue %d referenced in '%@' not found", (int)clueNo, self.clue);
        if (clue)
            return @[clue];
    }
    return nil;
}

- (BOOL)isPrimary {
    //  Match '(See n)' to determine if this is NOT a primary clue
    NSRegularExpression* regEx = [NSRegularExpression regularExpressionWithPattern:@"^\\s*\\(?\\s*see\\s+\\d+\\s*\\)?\\s*$"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    NSTextCheckingResult* match = [regEx firstMatchInString:self.clue options:0 range:NSMakeRange(0, self.clue.length)];
    
    return match ? NO : YES;
}

- (PuzzleClue*)primaryClue {
    if (self.isPrimary)
        return self;
    else {
        for (PuzzleClue* siblingClue in self.siblingClues) {
            if (siblingClue.isPrimary) {
                return siblingClue;
            }
        }
        
        NSAssert(NO, @"no primary clue found for a non-primary clue");
        return self;
    }
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

- (NSString*)answerSeeAlsos {
    NSString* result = nil;
    NSArray* siblingClues = self.siblingClues;
    NSUInteger numSinglings = siblingClues.count;
    
    for (NSUInteger i = 0; i < numSinglings; ++i) {
        if (!result)
            result = [NSString stringWithFormat:@"See %d %@", [siblingClues[i] gridNumber], [siblingClues[i] across] ? @"across" : @"down"];
        else if (i != numSinglings - 1)
            result = [NSString stringWithFormat:@"%@, %d %@", result, [siblingClues[i] gridNumber], [siblingClues[i] across] ? @"across" : @"down"];
        else
            result = [NSString stringWithFormat:@"%@ and %d %@", result, [siblingClues[i] gridNumber], [siblingClues[i] across] ? @"across" : @"down"];
    }
    return result;
}

- (NSString*)displayClue {
    NSString* primaryClue = self.primaryClue.clue;
    
    //  Strip of any trailing letter count indications to make the clue string a little shorter.  This is used in sutations where
    //  letter counts are displayed elsewhere in the UI.
    NSRegularExpression* regEx = [NSRegularExpression regularExpressionWithPattern:@"(\\(?see\\s+\\d+\\s*\\)\\s*)?(.*?)\\s+\\([0-9, ]+\\)?$" options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult* match = [regEx firstMatchInString:primaryClue options:0 range:NSMakeRange(0, primaryClue.length)];
    
    if (match) {
        NSAssert1(match.numberOfRanges == 3, @"invalid clue string: '%@'", primaryClue); // make the code defensive for this in future
        
        return [primaryClue substringWithRange:[match rangeAtIndex:2]];
    }
    else
        return primaryClue;
}

@end
