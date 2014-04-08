//
//  ClueView.m
//  Crosswords
//
//  Created by Mark Alldritt on 2014-03-30.
//  Copyright (c) 2014 Late Night Software Ltd. All rights reserved.
//

#import "ClueView.h"
#import "MPWCGDrawingContext.h"


NSString* ClueViewSelectedClueChangedNotification = @"ClueViewSelectedClueChangedNotification";


#define kMaxGridSize        40.0


@implementation ClueView

@synthesize selectedClue = mSelectedClue;
@synthesize showAnswers = mShowAnswers;
@synthesize showCluesInGrid = mShowCluesInGrid;
@synthesize showClueDirections = mShowClueDirections;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelectedClue:(PuzzleClue *)selectedClue {
    if (![self.selectedClue isEqual:selectedClue]) {
        mSelectedClue = selectedClue;
        [self setNeedsDisplay];
        [[NSNotificationCenter defaultCenter] postNotificationName:ClueViewSelectedClueChangedNotification
                                                            object:self
                                                          userInfo:selectedClue ? @{@"clue": selectedClue} : nil];
    }
}

- (void)setShowAnswers:(BOOL)showAnswers {
    if (self.showAnswers != showAnswers) {
        mShowAnswers = showAnswers;
        [self setNeedsDisplay];
    }
}

- (void)setShowCluesInGrid:(BOOL)showCluesInGrid {
    if (self.showCluesInGrid != showCluesInGrid) {
        mShowCluesInGrid = showCluesInGrid;
        [self setNeedsDisplay];
    }
}

- (void)setShowClueDirections:(BOOL)showClueDirections {
    if (self.showClueDirections != mShowClueDirections) {
        mShowClueDirections = showClueDirections;
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect {
    if (self.selectedClue) {
        //[[UIColor blueColor] set];
        //UIRectFill(rect);

        MPWCGDrawingContext* context = [MPWCGDrawingContext currentContext];
        [context translate:0 :[self bounds].size.height];
        [[context scale:1 :-1] setlinewidth:1];
        
        CGRect frame = self.frame;
        CGFloat width = floor(CGRectGetWidth(frame));
        CGFloat height = floor(CGRectGetHeight(frame));
        NSUInteger length = self.selectedClue.length;
        CGFloat cellSize = MIN(floor(width / length), kMaxGridSize);
        CGFloat cellsWidth = cellSize * length;
        CGFloat cellsHeight = cellSize;
        CGFloat cellsLeft = (width - cellsWidth) / 2.0;
        CGFloat cellsTop = (height - cellsHeight) / 2.0;
        CGRect clueArea = self.selectedClue.area;
        NSUInteger rows = self.puzzle.rows;
        NSUInteger cols = self.puzzle.columns;

        id gridColor = [context colorGray:0.0 alpha:1.0];
        id boxColor = [context colorGray:0.5 alpha:1.0];
        id clueFont = [context fontWithName:@"Helvetica" size:9.0];
        id clueColor = [context colorGray:0.3 alpha:1.0];
        id letterFont = [context fontWithName:@"Helvetica" size:MAX(16.0, cellSize - 13.0)];
        id letterColor = gridColor;
        id selectedCellColor = [context colorRed:0.400 green:0.800 blue:1.000 alpha:1.0];
        id siblingCellColor = selectedCellColor;
        id intersectingClueColor = [context colorRed:0.400 green:1.000 blue:1.000 alpha:0.2];

        //  Draw the interior of each grid cell
        NSArray* grid = self.showAnswers ? self.puzzle.puzzle[@"grid"] : self.puzzle.playerGrid;
        NSArray* gridNums = self.puzzle.puzzle[@"gridnums"];

        for (NSUInteger i = 0; i < length; ++i) {
            NSUInteger row, col;
            
            if (self.selectedClue.across) {
                row = clueArea.origin.y;
                col = clueArea.origin.x + i;
            }
            else {
                row = clueArea.origin.x;
                col = clueArea.origin.y + i;
            }

            NSUInteger ii = row * cols + col;
            NSString* letter = grid[ii];
            NSInteger num = [gridNums[ii] integerValue];

            NSSize size = [letter sizeWithAttributes:@{NSFontAttributeName:letterFont}];
            
            [context setFont:letterFont];
            [context setFillColor:letterColor];
            [context setTextPosition:NSMakePoint(cellsLeft + i * cellSize + (cellSize - size.width) / 2.0, cellsTop + (cellSize - size.height) / 2.0)];
            [context show:letter];

            if (num != 0) {
                [context setFont:clueFont];
                [context setFillColor:clueColor];
                [context setTextPosition:NSMakePoint(cellsLeft + i * cellSize + 2.0,
                                                     cellsTop + cellsHeight - 9.0)];
                
                NSArray* clues = [self.puzzle cluesAtRow:row column:col];
                BOOL across = NO;
                BOOL down = NO;
                
                for (PuzzleClue* aClue in clues) {
                    if (aClue.across)
                        across = YES;
                    else
                        down = YES;
                }
                
                [context show:[NSString stringWithFormat:@"%d%@",
                               (int) num,
                               across && self.showClueDirections ? [NSString stringWithFormat:@"%C", (UniChar)0x2192] : @""]];
                if (down && self.showClueDirections) {
                    [context setTextPosition:NSMakePoint(cellsLeft + i * cellSize + 1.0,
                                                         cellsTop + cellsHeight - (9.0 + 10.0))];
                    
                    [context show:[NSString stringWithFormat:@"%C", (UniChar)0x2193]];
                }
            }
        }

        //  Draw the grid frame
        [context setlinewidth:1.0];
        [context setStrokeColor:gridColor];
        
        for (NSUInteger i = 0; i <= length; ++i) {
            [context moveto:cellsLeft + i * cellSize :cellsTop];
            [context lineto:cellsLeft + i * cellSize :cellsTop + cellsHeight];
        }
        [context moveto:cellsLeft :cellsTop];
        [context lineto:cellsLeft + length * cellSize :cellsTop];
        [context moveto:cellsLeft :cellsTop + cellSize];
        [context lineto:cellsLeft + length * cellSize :cellsTop + cellSize];
        [context stroke];

        [context setlinewidth:3.0];
        [context setStrokeColor:gridColor];

        NSArray* words = self.selectedClue.words;
        
        //  Word seperators first...
        if (words) {
            NSUInteger letters = 0;
            NSUInteger numWords = words.count;
            
            for (NSUInteger i = 0; i < numWords - 1; ++i) {
                letters += [words[i] rangeValue].length;
                
                [context moveto:cellsLeft + letters * cellSize :cellsTop];
                [context lineto:cellsLeft + letters * cellSize :cellsTop + cellSize];
            }
        }

        [context stroke];

        NSArray* interectingCluesForClue = self.selectedClue.intersectingClues;
        NSArray* intersectingRects = [interectingCluesForClue valueForKey:@"area"];
        NSUInteger intersectingClueIndex = 0;
        
        [context setlinewidth:1.0];
        [context setStrokeColor:gridColor];
        [context setStrokeColor:[UIColor blueColor]];

        for (PuzzleClue* intersectingClue in interectingCluesForClue) {
            CGRect intersectingClueArea = ((NSValue*)intersectingRects[intersectingClueIndex]).CGRectValue;
            CGRect rrr = CGRectIntersection(intersectingClueArea, clueArea);
            NSUInteger intersectingClueLength = intersectingClue.length;
            NSInteger clueCol;
            NSInteger intersectingClueRow;
            
            if (self.selectedClue.across) {
                clueCol = rrr.origin.x - clueArea.origin.x;
                intersectingClueRow = rrr.origin.y - clueArea.origin.y;
            }
            else {
                clueCol = rrr.origin.y - clueArea.origin.y;
                intersectingClueRow = rrr.origin.x - clueArea.origin.x;
            }
            
            [context nsrect:CGRectMake(cellsLeft + clueCol * cellSize,
                                       cellsTop + (intersectingClueRow - intersectingClueLength) * cellSize,
                                       cellSize,
                                       intersectingClueLength * cellSize)];
            intersectingClueIndex++;
        }

        [context stroke];
        
        //  Draw "circle in square" markers if they are there.
        NSArray* circles = self.puzzle.puzzle[@"circles"];
        
        if (circles && ![circles isEqual:[NSNull null]]) {
            [context setlinewidth:1.0];
            [context setStrokeColor:gridColor];
            
            for (NSUInteger i = 0; i < length; ++i) {
                NSUInteger row, col;
                
                if (self.selectedClue.across) {
                    row = clueArea.origin.y;
                    col = clueArea.origin.x + i;
                }
                else {
                    row = clueArea.origin.x;
                    col = clueArea.origin.y + i;
                }
                
                NSUInteger ii = row * cols + col;
                if ([circles[ii] integerValue] > 0) {
                    CGRect a = CGRectInset(CGRectMake(cellsLeft + i * cellSize, cellsTop + cellsHeight - cellSize, cellSize, cellSize), 1.0, 1.0);
                    
                    [context ellipseInRect:a];
                }
            }
            
            [context stroke];
        }
    }
    else {
        //  we should probably suggest the user select a clue to view...
    }
}

@end
