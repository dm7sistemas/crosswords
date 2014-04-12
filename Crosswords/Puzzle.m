//
//  Puzzle.m
//  Crosswords
//
//  Created by Mark Alldritt on 2/6/2014.
//  Copyright (c) 2014 Late Night Software Ltd. All rights reserved.
//
//
//  Puzzles are stored in NSDictionary instances, but sometimes some logic is needed to pull out useful
//  information.  This object pairs with the puzzel NSDictionary to provide useful accessors

#import "Puzzle.h"
#import "PuzzleClue.h"
#import "GTMNSString+HTML.h"


@interface Puzzle ()

@property (strong, nonatomic) NSString* filename;

@end

@implementation Puzzle

@synthesize filename = mFilename;
@synthesize puzzle = mPuzzle;
@synthesize cluesAcross = mCluesAcross;
@synthesize cluesDown = mCluesDown;
@synthesize title = mTitle;
@synthesize author = mAuthor;
@synthesize editor = mEditor;
@synthesize publisher = mPublisher;
@synthesize copyright = mCopyright;
@synthesize notes = mNotes;
@synthesize playerGrid = mPlayerGrid;
@synthesize puzzleData = mPuzzleData;

- (NSString*)_localDataPath {
    NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *dataPath = [documentsPath stringByAppendingPathComponent:[[self.filename stringByDeletingPathExtension] stringByAppendingPathExtension:@"plist"]];
    
    return dataPath;
}

- (instancetype)initWithPuzzle:(NSDictionary *)puzzle filename:(NSString*) filename {
    //  We need a unique ID for the puzzle.  The contents of the puzzle don't guarentee this, so I'm using the file name.  This will
    //  probably not work in the long run, but it gets me moving forward.
    NSParameterAssert([puzzle isKindOfClass:[NSDictionary class]]);

    if ((self = [super init])) {
        mPuzzle = puzzle;
        mFilename = filename;
    }
    
    return self;
}

- (NSString*)_makeAnswerForAnswer:(id) answer words:(NSArray**) words {
    if ([answer isKindOfClass:[NSArray class]]) {
        NSMutableArray* wordsArray = [NSMutableArray arrayWithCapacity:[answer count]];
        NSString* result = @"";
        NSUInteger pos = 0;
        
        for (NSString* aWord in answer) {
            [wordsArray addObject:[NSValue valueWithRange:NSMakeRange(pos, aWord.length)]];
            result = [NSString stringWithFormat:@"%@%@", result, aWord];
            pos += aWord.length;
        }
        *words = wordsArray.copy; // non-mutable version
        return result;
    }
    else {
        *words = nil;
        return [answer gtm_stringByUnescapingFromHTML];
    }
}

- (NSDictionary*)_makeDictionaryForClues:(NSArray*) clues answers:(NSArray*) answers across:(BOOL) across {
    NSRegularExpression* regEx = [NSRegularExpression regularExpressionWithPattern:@"^\\s*(\\d+)\\.?\\s+(.*?)\\s*$" options:0 error:nil];
    NSMutableDictionary* result = [NSMutableDictionary dictionary];
    NSArray* gridNums = self.puzzle[@"gridnums"];
    NSInteger rows = self.rows;
    NSInteger columns = self.columns;
    NSInteger i = 0;
    
    for (NSString* aClue in clues) {
        //  Clues are expressed as strings: '1. clue text'.  Here we break this up into a number, and the text
        NSTextCheckingResult* match = [regEx firstMatchInString:aClue options:0 range:NSMakeRange(0, aClue.length)];
        
        NSAssert1(match.numberOfRanges == 3, @"invalid clue string: '%@'", aClue); // make the code defensive for this in future
        
        NSUInteger gridNumber = [[aClue substringWithRange:[match rangeAtIndex:1]] integerValue];
        NSString* clue = [[aClue substringWithRange:[match rangeAtIndex:2]] gtm_stringByUnescapingFromHTML];
        NSArray* words = nil;
        NSString* answer = [self _makeAnswerForAnswer:answers[i] words:&words];
        NSInteger row = -1;
        NSInteger column = -1;
        
        NSUInteger j = 0;
        for (NSNumber* aGridNum in gridNums) {
            if (aGridNum.integerValue == gridNumber) {
                row = j / columns;
                column = j % columns;
                break;
            }
            ++j;
        }
        
        NSAssert1(row >= 0, @"gridnum (%d) row not found", (int)gridNumber);
        NSAssert2(row < rows, @"gridnum row (%d) too big (%d)!", (int)row, (int)rows);
        NSAssert1(column >= 0, @"gridnum (%d)column not found", (int)gridNumber);
        NSAssert2(column < columns, @"gridnum column (%d) too big (%d)!", (int)column, (int)columns);

        result[@(gridNumber)] = [[PuzzleClue alloc] initWithPuzzle:self
                                                               row:row
                                                            column:column
                                                        gridNumber:gridNumber
                                                            across:across
                                                              clue:clue
                                                            answer:answer
                                                             words:words];
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
    NSParameterAssert(row >= 0 && row < self.rows);
    NSParameterAssert(column >= 0 && column < self.columns);
    
    //  Given a row & column, return the clue that begins at that location on the grid.
    NSInteger cols = self.columns;
    NSInteger index = row * cols + column;
    NSNumber* gridNumber = self.puzzle[@"gridnums"][index];
    
    if ([gridNumber integerValue] > 0) {
        NSDictionary* acrossClue = self.cluesAcross[gridNumber];
        NSDictionary* downClue = self.cluesDown[gridNumber];
        
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

- (PuzzleClue*)bestClueForRow:(NSInteger)row column:(NSInteger)column {
    //  This routine differs from cluesAtRow:column: in that the row and column need not be the explicit start of a
    //  clue.  This routine looks around the row & column specified for the "best" clue.  For now, "best" is defined
    //  as the clue that begines at the cell "closest" to the row & column specified.  If there is a tie, its the
    //  first one found.
    //
    //  We can make this smarter if the wrong thing happens during play.  I intend to use this to find the clue the
    //  user is tapping on.
    
    //  Start by seeing if the we can get a direct hit on the beginning on a clue.
    PuzzleClue* clue = [self cluesAtRow:row column:column][0];
    
    if (!clue) {
        //  Nope.  Hunt through all the clues for a clue that intersects the row & column specified.  For
        //  each intersecting clue, calculate a "distance" from the row & column specified.  With the distance, we
        //  can then look for hits with the shortest distance.
        
        NSUInteger distance = NSIntegerMax;
        
        for (PuzzleClue* aClue in self.cluesAcross.allValues) {
            if (row == aClue.row &&
                column >= aClue.column &&
                column < aClue.column + aClue.length) {
                NSUInteger aClueDistance = MAX(ABS((NSInteger)aClue.column - (NSInteger)column), ABS((NSInteger)aClue.row - (NSInteger)row));
                
                if (aClueDistance < distance) {
                    distance = aClueDistance;
                    clue = aClue;
                }
            }
        }

        for (PuzzleClue* aClue in self.cluesDown.allValues) {
            if (column == aClue.column &&
                row >= aClue.row &&
                row < aClue.row + aClue.length) {
                NSUInteger aClueDistance = MAX(ABS((NSInteger)aClue.column - (NSInteger)column), ABS((NSInteger)aClue.row - (NSInteger)row));
                
                if (aClueDistance < distance) {
                    distance = aClueDistance;
                    clue = aClue;
                }
            }
        }
    }
    
    return clue;
}

- (NSString*) title {
    if (!mTitle) {
        mTitle = self.puzzle[@"title"];
        if ([mTitle isEqual:[NSNull null]] || mTitle.length == 0)
            mTitle = @"Untitled";
        else
            mTitle = [[mTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] gtm_stringByUnescapingFromHTML];
    }
    return mTitle;
}

- (NSString*) author {
    if (!mAuthor) {
        mAuthor = self.puzzle[@"author"];
        if ([mAuthor isEqual:[NSNull null]] || mAuthor.length == 0)
            mAuthor = @"Author unknown";
        else
            mAuthor = [[mAuthor stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] gtm_stringByUnescapingFromHTML];
    }
    return mAuthor;
}

- (BOOL)hasAuthor {
    NSString* author = self.puzzle[@"author"];
    
    return [author isEqual:[NSNull null]] || author.length == 0 ? NO : YES;
}

- (NSString*) editor {
    if (!mEditor) {
        mEditor = self.puzzle[@"editor"];
        if ([mEditor isEqual:[NSNull null]] || mEditor.length == 0)
            mEditor = @"";
        else
            mEditor = [[mEditor stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] gtm_stringByUnescapingFromHTML];
    }
    return mEditor;
}

- (NSString*) publisher {
    if (!mPublisher) {
        mPublisher = self.puzzle[@"publisher"];
        if ([mPublisher isEqual:[NSNull null]] || mPublisher.length == 0)
            mPublisher = @"Unknown publisher";
        else
            mPublisher = [[mPublisher stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] gtm_stringByUnescapingFromHTML];
    }
    return mPublisher;
}

- (NSString*) copyright {
    if (!mCopyright) {
        mCopyright = self.puzzle[@"copyright"];
        if ([mCopyright isEqual:[NSNull null]] || mCopyright.length == 0)
            mCopyright = @"Unknown";
        else
            mCopyright = [[mCopyright stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] gtm_stringByUnescapingFromHTML];
    }
    return mCopyright;
}

- (NSString*) notes {
    if (!mNotes) {
        mNotes = self.puzzle[@"jnotes"];
        if ([mNotes isEqual:[NSNull null]] || mNotes.length == 0)
            mNotes = @"";
        else
            mNotes = [[mNotes stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] gtm_stringByUnescapingFromHTML];
    }
    return mNotes;
}

- (NSUInteger)rows { return [[self.puzzle valueForKeyPath:@"size.rows"] integerValue]; }
- (NSUInteger)columns { return [[self.puzzle valueForKeyPath:@"size.cols"] integerValue]; }

- (NSArray*) playerGrid {
    if (!mPlayerGrid) {
        NSMutableArray* grid = [NSMutableArray arrayWithArray:self.puzzle[@"grid"]];
        NSUInteger length = grid.count;
        
        for (NSUInteger i = 0; i < length; ++i) {
            if (![grid[i] isEqualToString:@"."])
                grid[i] = @"";
        }
        mPlayerGrid = grid.copy; // non-mutable copy.
                                 // In time, I'm going to have to save the player's answers which will require that I alter this
                                 // array.
    }
    return mPlayerGrid;
}

- (NSDictionary*)puzzleData {
    if (!mPuzzleData) {
        NSString* dataPath = [self _localDataPath];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath])
            mPuzzleData = [NSDictionary dictionaryWithContentsOfFile:dataPath];
        else
            mPuzzleData = @{};
    }
    
    return mPuzzleData;
}

- (void)setPuzzleData:(NSDictionary *)puzzleData {
    mPuzzleData = [puzzleData copy];
    [mPuzzleData writeToFile:[self _localDataPath] atomically:YES];
}

@end
