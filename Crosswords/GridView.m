//
//  GridView.m
//  Crosswords
//
//  Created by Mark Alldritt on 2/6/2014.
//  Copyright (c) 2014 Late Night Software Ltd. All rights reserved.
//

#import "PopoverView.h"
#import "GridView.h"
#import "PuzzleClue.h"
#import "CluesViewController.h"


#define kMaxGridSize        40.0


NSString* GridViewSelectedClueChangedNotification = @"GridViewSelectedClueChangedNotification";

@interface GridView ()

@end


@implementation GridView

@synthesize puzzle = mPuzzle;
@synthesize selectedClue = mSelectedClue;
@synthesize showAnswers = mShowAnswers;

-(void)_cluesTableSelectionChanged:(NSNotification*) notification {
    CluesViewController* cluesViewController = notification.object;
    PuzzleClue* clue = notification.userInfo[@"clue"];

    if (cluesViewController.puzzle == self.puzzle) {
        self.selectedClue = clue;
    }
}

-(void)_getRow:(NSInteger*) row andColumn:(NSInteger*) column at:(CGPoint) where {
    NSParameterAssert(row);
    NSParameterAssert(column);
    
    CGRect frame = self.frame;
    CGFloat width = floor(CGRectGetWidth(frame));
    CGFloat height = floor(CGRectGetHeight(frame));
    NSUInteger rows = self.puzzle.rows;
    NSUInteger cols = self.puzzle.columns;
    CGFloat cellSize = MIN(floor(MIN(width / cols, height / rows)), kMaxGridSize);
    CGFloat cellsWidth = cellSize * cols;
    CGFloat cellsHeight = cellSize * rows;
    CGFloat cellsLeft = (width - cellsWidth) / 2.0;
    CGFloat cellsTop = (height - cellsHeight) / 2.0;
    
    if (where.x < cellsLeft || where.x > cellsLeft + cellsWidth ||
        where.y < cellsTop || where.y > cellsTop + cellsHeight) {
        *row = *column = -1; // not found
    }
    else {
        *row = (where.y - cellsTop) / cellSize;
        *column = (where.x - cellsLeft) / cellSize;
    }
}

-(void)_handleSingleTap:(UITapGestureRecognizer*) recognizer {
    CGPoint where = [recognizer locationInView:self];
    NSInteger row, col;
    
    [self _getRow:&row andColumn:&col at:where];
    
    if (row >= 0 && col >= 0) {
        PuzzleClue* clue = [self.puzzle bestClueForRow:row column:col];
        
        self.selectedClue = clue;
    }
    else
        self.selectedClue = nil;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)awakeFromNib {
    self.showAnswers = NO;
    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleSingleTap:)];
    [self addGestureRecognizer:tapRecognizer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_cluesTableSelectionChanged:)
                                                 name:DetailViewControllerSelectedClueChangedNotification
                                               object:nil];
}

- (BOOL)_row:(NSInteger) row column:(NSInteger) column inRectanges:(NSArray*) rects { // arrage of NSValues containing CGRects
    CGRect p = CGRectMake(column, row, 1.0, 1.0);
    
    for (NSValue* rect in rects) {
        if (CGRectIntersectsRect(p, [rect CGRectValue]))
            return YES;
    }
    return NO;
}

-(void)setPuzzle:(PuzzleHelper *)puzzle {
    if (puzzle != mPuzzle) {
        mPuzzle = puzzle;
        mSelectedClue = nil;
        
#warning TODO
        //  Some "trick" puzzles have grid cells with multi-letter values.  This code does not yet handle this
        //  case.  An example of this type of puzzle is nyt2.json.

        __weak GridView* weakSelf = self;
        self.drawingBlock = ^(id <MPWDrawingContext> context) {
            CGRect frame = weakSelf.frame;
            CGFloat width = floor(CGRectGetWidth(frame));
            CGFloat height = floor(CGRectGetHeight(frame));
            NSUInteger rows = weakSelf.puzzle.rows;
            NSUInteger cols = weakSelf.puzzle.columns;
            CGFloat cellSize = MIN(floor(MIN(width / cols, height / rows)), kMaxGridSize);
            CGFloat cellsWidth = cellSize * cols;
            CGFloat cellsHeight = cellSize * rows;
            CGFloat cellsLeft = (width - cellsWidth) / 2.0;
            CGFloat cellsTop = (height - cellsHeight) / 2.0;
            CGRect selectedArea = weakSelf.selectedClue ? weakSelf.selectedClue.area : CGRectMake(-1.0, -1.0, 0.0, 0.0);
            NSArray* interectingClues = weakSelf.selectedClue.intersectingClues;
            
            id gridColor = [context colorGray:0.0 alpha:1.0];
            id boxColor = [context colorGray:0.5 alpha:1.0];
            id clueFont = [context fontWithName:@"Helvetica" size:9.0];
            id clueColor = [context colorGray:0.3 alpha:1.0];
            id letterFont = [context fontWithName:@"Helvetica" size:MAX(16.0, cellSize - 13.0)];
            id letterColor = gridColor;
            id selectedCellColor = [context colorRed:0.400 green:0.800 blue:1.000 alpha:1.0];
            id intersectingClueColor = [context colorRed:0.400 green:1.000 blue:1.000 alpha:0.2];
            
            //  Draw the interior of each grid cell
            NSArray* grid = weakSelf.showAnswers ? weakSelf.puzzle.puzzle[@"grid"] : weakSelf.puzzle.playerGrid;
            NSArray* gridNums = weakSelf.puzzle.puzzle[@"gridnums"];
            
            for (NSInteger i = 0; i < rows * cols; ++i) {
                NSInteger row = i / cols;
                NSInteger col = i - row * cols;
                NSString* letter = grid[i];
                NSInteger num = [gridNums[i] integerValue];
                
                if ([letter isEqualToString:@"."]) {
                    NSRect r = NSInsetRect(NSMakeRect(cellsLeft + col * cellSize, cellsTop + cellsHeight - (row * cellSize) - cellSize, cellSize, cellSize), .5, .5);
                    [context setFillColor:boxColor];
                    [context fillRect:r];
                }
                else {
                    
                    //  Draw cell background.
                    CGRect p = CGRectMake(col, row, 1.0, 1.0);
                    if (CGRectIntersectsRect(selectedArea, p)) {
                        //  This cell is part of the selected clue
                        NSRect r = NSInsetRect(NSMakeRect(cellsLeft + col * cellSize, cellsTop + cellsHeight - (row * cellSize) - cellSize, cellSize, cellSize), .5, .5);
                        [context setFillColor:selectedCellColor];
                        [context fillRect:r];
                    }
                    else {
                        for (PuzzleClue* aClue in interectingClues) {
                            CGRect aClueArea = aClue.area;
                            if (CGRectIntersectsRect(aClueArea, p)) {
                                //  This cell is part of one of the clues that intersects the selected clue, and so has a part to play in the answer
                                NSRect r = NSInsetRect(NSMakeRect(cellsLeft + col * cellSize, cellsTop + cellsHeight - (row * cellSize) - cellSize, cellSize, cellSize), .5, .5);
                                [context setFillColor:intersectingClueColor];
                                [context fillRect:r];
                            }
                        }
                    }
                    NSSize size = [letter sizeWithAttributes:@{NSFontAttributeName:letterFont}];
                    
                    [context setFont:letterFont];
                    [context setFillColor:letterColor];
                    [context setTextPosition:NSMakePoint(cellsLeft + col * cellSize + (cellSize - size.width) / 2.0,
                                                         cellsTop + cellsHeight - (row * cellSize - (cellSize - size.height) / 2.0) - cellSize)];
                    [context show:letter];
                }
                if (num != 0) {
                    [context setFont:clueFont];
                    [context setFillColor:clueColor];
                    [context setTextPosition:NSMakePoint(cellsLeft + col * cellSize + 2.0,
                                                         cellsTop + cellsHeight - (row * cellSize + 9.0))];

                    NSArray* clues = [weakSelf.puzzle cluesAtRow:row column:col];
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
                                   across ? [NSString stringWithFormat:@"%C", (UniChar)0x2192] : @""]];
                    if (down) {
                        [context setTextPosition:NSMakePoint(cellsLeft + col * cellSize + 1.0,
                                                             cellsTop + cellsHeight - (row * cellSize + 9.0 + 10.0))];
                        
                        [context show:[NSString stringWithFormat:@"%C", (UniChar)0x2193]];
                    }
                }
            }
            
            //  Draw the grid frame
            [context setlinewidth:1.0];
            [context setStrokeColor:gridColor];
            
            for (NSUInteger r = 0; r <= rows; ++r) {
                [context moveto:cellsLeft :cellsTop + r * cellSize];
                [context lineto:cellsLeft + cellsWidth :cellsTop + r * cellSize];
            }
            for (NSUInteger c = 0; c <= cols; ++c) {
                [context moveto:cellsLeft + c * cellSize :cellsTop];
                [context lineto:cellsLeft + c * cellSize :cellsTop + cellsHeight];
            }
            [context stroke];
            
            //  Find any cells that need to have seperator bars.  These are cells that back the beginning/end of a word that
            //  is not next to a black wquare or the edge of the puzzle grid.  We also handle the case where a clue has a multi-
            //  word answer and we need to draw a seperator between the words.
            
            [context setlinewidth:3.0];
            [context setStrokeColor:gridColor];

            for (PuzzleClue* clue in weakSelf.puzzle.cluesAcross.allValues) {
                CGRect area = clue.area;
                NSArray* words = clue.words;
                NSArray* interectingCluesForClue = clue.intersectingClues;
                NSArray* intersectingRects = [interectingCluesForClue valueForKey:@"area"];
                
                //  Word seperators first...
                if (words) {
                    NSUInteger letters = 0;
                    NSUInteger numWords = words.count;

                    for (NSUInteger i = 0; i < numWords - 1; ++i) {
                        letters += [words[i] rangeValue].length;
                        
                        [context moveto:cellsLeft + (area.origin.x + letters) * cellSize :cellsTop + cellsHeight - (area.origin.y * cellSize)];
                        [context lineto:cellsLeft + (area.origin.x + letters) * cellSize :cellsTop + cellsHeight - (area.origin.y * cellSize + cellSize)];
                    }
                }
                
                for (NSUInteger col = CGRectGetMinX(area); col < CGRectGetMaxX(area); ++col) {
                    //NSAssert(col < cols, @"col (%d) too large (%d), clue: %@", (int)col, (int)rows, clue);
                    //  Do we need a divider left of the first letter?
                    if (col == area.origin.x && col > 0 && col < cols - 1 && ![grid[(int)(area.origin.y * cols + col - 1)] isEqualToString:@"."]) {
                        [context moveto:cellsLeft + (area.origin.x * cellSize) :cellsTop + cellsHeight - area.origin.y * cellSize];
                        [context lineto:cellsLeft + (area.origin.x * cellSize) :cellsTop + cellsHeight - (area.origin.y * cellSize + cellSize)];
                    }
                    //  Do we need a divider right of the last letter?
                    if (col == CGRectGetMaxX(area) - 1 && col > 0 && col < cols - 1 && ![grid[(int)(area.origin.y * cols + col + 1)] isEqualToString:@"."]) {
                        [context moveto:cellsLeft + (CGRectGetMaxX(area) * cellSize) :cellsTop + cellsHeight - area.origin.y * cellSize];
                        [context lineto:cellsLeft + (CGRectGetMaxX(area) * cellSize) :cellsTop + cellsHeight - (area.origin.y * cellSize + cellSize)];
                    }
                    //  Do we need a divider above the letter?
                    if (area.origin.y > 0 &&
                        ![grid[(int)((area.origin.y - 1) * cols + col)] isEqualToString:@"."] &&
                        ![weakSelf _row:area.origin.y - 1 column:col inRectanges:intersectingRects]) {

                        [context moveto:cellsLeft + col * cellSize :cellsTop + cellsHeight - CGRectGetMinY(area) * cellSize];
                        [context lineto:cellsLeft + (col * cellSize + cellSize) :cellsTop + cellsHeight - CGRectGetMinY(area) * cellSize];
                    }
                    //  Do we need a divider below the letter?
                    if (area.origin.y < rows - 2 &&
                        ![grid[(int)((area.origin.y + 1) * cols + col)] isEqualToString:@"."] &&
                        ![weakSelf _row:area.origin.y + 1 column:col inRectanges:intersectingRects]) {

                        [context moveto:cellsLeft + col * cellSize :cellsTop + cellsHeight - CGRectGetMaxY(area) * cellSize];
                        [context lineto:cellsLeft + (col * cellSize + cellSize) :cellsTop + cellsHeight - CGRectGetMaxY(area) * cellSize];
                    }
                }
            }
            for (PuzzleClue* clue in weakSelf.puzzle.cluesDown.allValues) {
                CGRect area = clue.area;
                NSArray* words = clue.words;
                NSArray* interectingCluesForClue = clue.intersectingClues;
                NSArray* intersectingRects = [interectingCluesForClue valueForKey:@"area"];
                
                //  Word seperators first...
                if (words) {
                    NSUInteger letters = 0;
                    NSUInteger numWords = words.count;
                    
                    for (NSUInteger i = 0; i < numWords - 1; ++i) {
                        letters += [words[i] rangeValue].length;
                        
                        [context moveto:cellsLeft + (area.origin.x * cellSize) :cellsTop + cellsHeight - (area.origin.y + letters) * cellSize];
                        [context lineto:cellsLeft + (area.origin.x * cellSize + cellSize) :cellsTop + cellsHeight - (area.origin.y + letters) * cellSize];
                    }
                }

                for (NSUInteger row = CGRectGetMinY(area); row < CGRectGetMaxY(area); ++row) {
                    //NSAssert(row < rows, @"row (%d) too large (%d), clue: %@", (int)row, (int)rows, clue);
                    //  Do we need a divider above of the first letter?
                    if (row == area.origin.y && row > 0 && row < rows - 1 && ![grid[(int)((row - 1) * cols + area.origin.x)] isEqualToString:@"."]) {
                        [context moveto:cellsLeft + (area.origin.x * cellSize) :cellsTop + cellsHeight - area.origin.y * cellSize];
                        [context lineto:cellsLeft + (area.origin.x * cellSize + cellSize) :cellsTop + cellsHeight - (area.origin.y * cellSize)];
                    }
                    //  Do we need a divider below of the last letter?
                    if (row == CGRectGetMaxY(area) - 1 && row > 0 && row < rows - 1 && ![grid[(int)((row + 1) * cols + area.origin.x)] isEqualToString:@"."]) {
                        [context moveto:cellsLeft + (area.origin.x * cellSize) :cellsTop + cellsHeight - CGRectGetMaxY(area) * cellSize];
                        [context lineto:cellsLeft + (area.origin.x * cellSize + cellSize) :cellsTop + cellsHeight - CGRectGetMaxY(area) * cellSize];
                    }
                    //  Do we need a divider left of letter?
                    if (area.origin.x > 0 &&
                        ![grid[(int)(row * cols + area.origin.x - 1)] isEqualToString:@"."] &&
                        ![weakSelf _row:row column:area.origin.x - 1 inRectanges:intersectingRects]) {
                        [context moveto:cellsLeft + CGRectGetMinX(area) * cellSize :cellsTop + cellsHeight - row * cellSize];
                        [context lineto:cellsLeft + CGRectGetMinX(area) * cellSize :cellsTop + cellsHeight - (row * cellSize + cellSize)];
                    }
                    //  Do we need a divider right of letter?
                    if (area.origin.x < cols - 2 &&
                        ![grid[(int)(row * cols + area.origin.x + 1)] isEqualToString:@"."] &&
                        ![weakSelf _row:row column:area.origin.x + 1 inRectanges:intersectingRects]) {
                        [context moveto:cellsLeft + CGRectGetMaxX(area) * cellSize :cellsTop + cellsHeight - row * cellSize];
                        [context lineto:cellsLeft + CGRectGetMaxX(area) * cellSize :cellsTop + cellsHeight - (row * cellSize + cellSize)];
                    }
                }
            }
            [context stroke];
            
            //  Draw "circle in square" markers if they are there.
            NSArray* circles = weakSelf.puzzle.puzzle[@"circles"];
            
            if (circles && ![circles isEqual:[NSNull null]]) {
                [context setlinewidth:1.0];
                [context setStrokeColor:gridColor];
                
                for (NSUInteger i = 0; i < rows * cols; ++i) {
                    if ([circles[i] integerValue] > 0) {
                        NSUInteger row = i / cols;
                        NSUInteger col = i % cols;
                        CGRect a = CGRectInset(CGRectMake(cellsLeft + col * cellSize, cellsTop + cellsHeight - row * cellSize - cellSize, cellSize, cellSize), 1.0, 1.0);
                        
                        [context ellipseInRect:a];
                    }
                }
                
                [context stroke];
            }
        };

        [self setNeedsDisplay];
    }
}

- (void)setSelectedClue:(PuzzleClue *)selectedClue {
    if (![self.selectedClue isEqual:selectedClue]) {
        mSelectedClue = selectedClue;
        [self setNeedsDisplay];
        [[NSNotificationCenter defaultCenter] postNotificationName:GridViewSelectedClueChangedNotification
                                                            object:self
                                                          userInfo:@{@"clue": selectedClue}];

        if (selectedClue) {
            CGRect frame = self.frame;
            CGFloat width = floor(CGRectGetWidth(frame));
            CGFloat height = floor(CGRectGetHeight(frame));
            NSUInteger rows = self.puzzle.rows;
            NSUInteger cols = self.puzzle.columns;
            CGFloat cellSize = MIN(floor(MIN(width / cols, height / rows)), kMaxGridSize);
            CGFloat cellsWidth = cellSize * cols;
            CGFloat cellsHeight = cellSize * rows;
            CGFloat cellsLeft = (width - cellsWidth) / 2.0;
            CGFloat cellsTop = (height - cellsHeight) / 2.0;

#if 1
            for (PuzzleClue* aClue in selectedClue.intersectingClues) {
                NSUInteger row = aClue.row;
                NSUInteger col = aClue.column;
                CGRect a1 = CGRectMake(cellsLeft + col * cellSize, cellsTop + row * cellSize, cellSize, cellSize);
                
                if (aClue.across)
                    col += aClue.length - 1;
                else
                    row += aClue.length - 1;
                CGRect a2 = CGRectMake(cellsLeft + col * cellSize, cellsTop + row * cellSize, cellSize, cellSize);
                CGRect clueArea = CGRectUnion(a1, a2);
                
                NSMutableAttributedString* ats1 = [[NSMutableAttributedString alloc] initWithString:aClue.clue
                                                                                         attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14.0],
                                                                                                      NSForegroundColorAttributeName: [UIColor blackColor]}];
#if 0
                NSAttributedString* ats2 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%d %@, %d letters",
                                                                                       (int)aClue.gridNumber,
                                                                                       aClue.across ? @"across" : @"down",
                                                                                       (int)aClue.answer.length]
                                                                           attributes:@{NSFontAttributeName: [UIFont italicSystemFontOfSize:10.0],
                                                                                        NSForegroundColorAttributeName: [UIColor grayColor]}];
                
                [ats1 appendAttributedString:ats2];
#endif
                PopoverView* v = [PopoverView showPopoverAtPoint:CGPointMake(CGRectGetMidX(clueArea), CGRectGetMinY(clueArea))
                                                          inView:self
                                              withAttributedText:ats1
                                                        delegate:nil];
                v.alpha = 0.8;
            }
#endif
            NSUInteger row = selectedClue.row;
            NSUInteger col = selectedClue.column;
            CGRect a1 = CGRectMake(cellsLeft + col * cellSize, cellsTop + row * cellSize, cellSize, cellSize);
            
            if (selectedClue.across)
                col += selectedClue.length - 1;
            else
                row += selectedClue.length - 1;
            CGRect a2 = CGRectMake(cellsLeft + col * cellSize, cellsTop + row * cellSize, cellSize, cellSize);
            CGRect clueArea = CGRectUnion(a1, a2);
            
            NSMutableAttributedString* ats1 = [[NSMutableAttributedString alloc] initWithString:selectedClue.clue
                                                                                     attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0],
                                                                                                  NSForegroundColorAttributeName: [UIColor blackColor]}];
            NSAttributedString* ats2 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%d %@, %d letters",
                                                                                   (int)selectedClue.gridNumber,
                                                                                   selectedClue.across ? @"across" : @"down",
                                                                                   (int)selectedClue.answer.length]
                                                                       attributes:@{NSFontAttributeName: [UIFont italicSystemFontOfSize:12.0],
                                                                                    NSForegroundColorAttributeName: [UIColor grayColor]}];
            
            [ats1 appendAttributedString:ats2];
            PopoverView* v = [PopoverView showPopoverAtPoint:CGPointMake(CGRectGetMidX(clueArea), CGRectGetMinY(clueArea))
                                                      inView:self
                                          withAttributedText:ats1
                                                    delegate:nil];
            v.alpha = .95;
        }
    }
}

- (void)setShowAnswers:(BOOL)showAnswers {
    if (self.showAnswers != showAnswers) {
        mShowAnswers = showAnswers;
        [self setNeedsDisplay];
    }
}

@end
