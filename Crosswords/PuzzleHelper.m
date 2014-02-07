//
//  PuzzleHelper.m
//  Crosswords
//
//  Created by Mark Alldritt on 2/6/2014.
//  Copyright (c) 2014 Late Night Software Ltd. All rights reserved.
//
//
//  Puzzles are stored in NSDictionary instances, but sometimes some logic is needed to pull out useful
//  information.  This object pairs with the puzzel NSDictionary to provide useful accessors

#import "PuzzleHelper.h"
#import "GTMNSString+HTML.h"


@implementation PuzzleHelper

@synthesize puzzle = mPuzzle;
@synthesize cluesAcross = mCluesAcross;
@synthesize cluesDown = mCluesDown;

- (instancetype)initWithPuzzle:(NSDictionary *)puzzle {
    NSParameterAssert([puzzle isKindOfClass:[NSDictionary class]]);

    if ((self = [super init])) {
        mPuzzle = puzzle;
    }
    
    return self;
}

- (NSDictionary*)_makeDictionaryForClues:(NSArray*) clues answers:(NSArray*) answers across:(BOOL) across {
    NSRegularExpression* regEx = [NSRegularExpression regularExpressionWithPattern:@"^(\\d+)\\.\\s*(.*)$" options:0 error:nil];
    NSMutableDictionary* result = [NSMutableDictionary dictionary];
    NSArray* gridNums = self.puzzle[@"gridnums"];
    NSInteger rows = [[self.puzzle valueForKeyPath:@"size.rows"] integerValue];
    NSInteger cols = [[self.puzzle valueForKeyPath:@"size.cols"] integerValue];
    NSInteger i = 0;
    
    for (NSString* aClue in clues) {
        //  Clues are expressed as strings: '1. clue text'.  Here we break this up into a number, and the text
        NSTextCheckingResult* match = [regEx firstMatchInString:aClue options:0 range:NSMakeRange(0, aClue.length)];
        
        NSAssert(match.numberOfRanges == 3, @"invalue clue string"); // make the code defensive for this in future
        
        NSInteger clueNo = [[aClue substringWithRange:[match rangeAtIndex:1]] integerValue];
        NSString* clue = [[aClue substringWithRange:[match rangeAtIndex:2]] gtm_stringByUnescapingFromHTML];
        NSString* answer = [answers[i] gtm_stringByUnescapingFromHTML];
        NSInteger row = -1;
        NSInteger col = -1;
        
        NSUInteger j = 0;
        for (NSNumber* aGridNum in gridNums) {
            if (aGridNum.integerValue == clueNo) {
                row = j / cols;
                col = j % cols;
                break;
            }
            ++j;
        }
        
        NSAssert(row >= 0, @"gridnum not found");
        NSAssert(row < rows, @"gridnum row too big!");
        NSAssert(col >= 0, @"gridnum not found");
        NSAssert(col < cols, @"gridnum row too big!");
        
        CGRect area = across ? CGRectMake(col, row, answer.length, 1.0) : CGRectMake(col, row, 1.0, answer.length);

        result[@(clueNo)] = @{@"gridnum": @(clueNo), @"clue": clue, @"answer" : answer, @"row" : @(row), @"col" : @(col), @"across" : @(across), @"area" : [NSValue valueWithCGRect:area]};
        ++i;
    }
    
    return result.copy; // return a non-mutable version of the data;
}

- (NSDictionary*)cluesAcross {
    //  The problem with the JSON format we are using is that clues are delivered as an array of strings.  This code turns those
    //  strings into a dictionary keyed by clue number.  Also, each dictionary entry is a dictionary of useful information:
    //  - gridnum
    //  - clue
    //  - answer
    //  - row
    //  - column
    //  - accros
    //
    //  This is all done in a brute force fashion, but the data sets are not that large so I don't think we are going to
    //  experience too much of a performance hit.  If this becomes a problem, we can return here in future and improve the
    //  approach.
    
    if (!mCluesAcross)
        mCluesAcross = [self _makeDictionaryForClues:[self.puzzle valueForKeyPath:@"clues.across"]
                                             answers:[self.puzzle valueForKeyPath:@"answers.across"]
                                              across:YES];
    return mCluesAcross;
}

- (NSDictionary*)cluesDown {
    //  The problem with the JSON format we are using is that clues are delivered as an array of strings.  This code turns those
    //  strings into a dictionary keyed by clue number.  Also, each dictionary entry is a dictionary of useful information:
    //  - gridnum
    //  - clue
    //  - answer
    //  - row
    //  - column
    //  - accros
    //
    //  This is all done in a brute force fashion, but the data sets are not that large so I don't think we are going to
    //  experience too much of a performance hit.  If this becomes a problem, we can return here in future and improve the
    //  approach.
    
    if (!mCluesDown)
        mCluesDown = [self _makeDictionaryForClues:[self.puzzle valueForKeyPath:@"clues.down"]
                                           answers:[self.puzzle valueForKeyPath:@"answers.down"]
                                            across:NO];
    return mCluesDown;
}

- (NSArray*)cluesAtRow:(NSInteger)row column:(NSInteger)column {
    //  Given a row & column, return the clue that begins at that location on the grid.
    NSInteger cols = [[self.puzzle valueForKeyPath:@"size.cols"] integerValue];
    NSInteger index = row * cols + column;
    NSNumber* clueNo = self.puzzle[@"gridnums"][index];
    
    if (clueNo > 0) {
        NSDictionary* acrossClue = self.cluesAcross[clueNo];
        NSDictionary* downClue = self.cluesDown[clueNo];
        
        if (acrossClue && downClue)
            return @[acrossClue, downClue];
        else if (acrossClue)
            return @[acrossClue];
        else if (downClue)
            return @[downClue];
        else
            return nil;
    }
    return nil;
}

- (NSDictionary*)bestClueForRow:(NSInteger)row column:(NSInteger)column {
    //  This routine differs from cluesAtRow:column: in that the row and column need not be the explicit start of a
    //  clue.  This routine looks around the row & column specified for the "best" clue.  For now, "best" is defined
    //  as the clue that begines at the cell "closest" to the row & column specified.  If there is a tie, its the
    //  first one found.
    //
    //  We can make this smarter if the wrong thing happens during play.  I intend to use this to find the clue the
    //  user is tapping on.
    
    //  Start by seeing if the we can get a direct hit on the beginning on a clue.
    NSDictionary* clue = [self cluesAtRow:row column:column][0];
    
    if (!clue) {
        //  Nope.  Hunt through all the clues for a clue that intersects the row & column specified.  For
        //  each intersecting clue, calculate a "distance" from the row & column specified.  With the distance, we
        //  can then look for hits with the shortest distance.
        
        NSInteger distance = NSIntegerMax;
        
        for (NSDictionary* aClue in self.cluesAcross.allValues) {
            if (row == [aClue[@"row"] integerValue] &&
                column >= [aClue[@"col"] integerValue] &&
                column < [aClue[@"col"] integerValue] + [aClue[@"answer"] length]) {
                NSUInteger aClueDistance = MAX(ABS([aClue[@"col"] integerValue] - column), ABS([aClue[@"row"] integerValue] - row));
                
                if (aClueDistance < distance) {
                    distance = aClueDistance;
                    clue = aClue;
                }
            }
        }

        for (NSDictionary* aClue in self.cluesDown.allValues) {
            if (column == [aClue[@"col"] integerValue] &&
                row >= [aClue[@"row"] integerValue] &&
                row < [aClue[@"row"] integerValue] + [aClue[@"answer"] length]) {
                NSUInteger aClueDistance = MAX(ABS([aClue[@"col"] integerValue] - column), ABS([aClue[@"row"] integerValue] - row));
                
                if (aClueDistance < distance) {
                    distance = aClueDistance;
                    clue = aClue;
                }
            }
        }
    }
    
    return clue;
}

- (NSArray*)cluesIntersectingClue:(NSDictionary*) clue {
    if (!clue)
        return nil;
    NSAssert(clue[@"area"], @"This does not appear to be a clue dictionary");

    //  Determine all the clues that intersect with the answer for a clue.  This is brute force, but for now, its good enough.
    
    CGRect clueArea = [clue[@"area"] CGRectValue];
    NSMutableArray* result = nil;
    
    for (NSDictionary* aClue in self.cluesAcross.allValues) {
        if (CGRectIntersectsRect(clueArea, [aClue[@"area"] CGRectValue])) {
            if (result)
                [result addObject:aClue];
            else
                result = [NSMutableArray arrayWithObject:aClue];
        }
    }
    for (NSDictionary* aClue in self.cluesDown.allValues) {
        if (CGRectIntersectsRect(clueArea, [aClue[@"area"] CGRectValue])) {
            if (result)
                [result addObject:aClue];
            else
                result = [NSMutableArray arrayWithObject:aClue];
        }
    }
    
    return result.copy; // return a non-mutable version...
}

@end
