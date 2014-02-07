//
//  GridView.m
//  Crosswords
//
//  Created by Mark Alldritt on 2/6/2014.
//  Copyright (c) 2014 Late Night Software Ltd. All rights reserved.
//

#import "GridView.h"

@interface GridView ()

@property (strong, nonatomic) NSDictionary* selectedClue;

@end


@implementation GridView

@synthesize puzzle = mPuzzle;
@synthesize selectedClue = mSelectedClue;

-(void)_getRow:(NSInteger*) row andColumn:(NSInteger*) column at:(CGPoint) where {
    NSParameterAssert(row);
    NSParameterAssert(column);
    
    CGRect frame = self.frame;
    CGFloat width = floor(CGRectGetWidth(frame));
    CGFloat height = floor(CGRectGetHeight(frame));
    NSUInteger rows = [[self.puzzle.puzzle valueForKeyPath:@"size.rows"] integerValue];
    NSUInteger cols = [[self.puzzle.puzzle valueForKeyPath:@"size.cols"] integerValue];
    CGFloat cellSize = floor(MIN(width / cols, height / rows));
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
    
    NSDictionary* clue = [self.puzzle bestClueForRow:row column:col];
    NSLog(@"recognizer: %@, where: %@, row: %d, column: %d, best clue: %@", recognizer, NSStringFromCGPoint(where), (int)row, (int)col, clue);
    
    self.selectedClue = clue;
}

-(void)_handleLongTap:(UITapGestureRecognizer*) recognizer {
    NSLog(@"recognizer: %@", recognizer);
}

-(void)awakeFromNib {
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleSingleTap:)];
    [self addGestureRecognizer:singleFingerTap];
}

-(void)setPuzzle:(PuzzleHelper *)puzzle {
    if (puzzle != mPuzzle) {
        mPuzzle = puzzle;
        mSelectedClue = nil;
        
        __weak GridView* weakSelf = self;
        self.drawingBlock = ^(id <MPWDrawingContext> context) {
            CGRect frame = weakSelf.frame;
            CGFloat width = floor(CGRectGetWidth(frame));
            CGFloat height = floor(CGRectGetHeight(frame));
            NSUInteger rows = [[weakSelf.puzzle.puzzle valueForKeyPath:@"size.rows"] integerValue];
            NSUInteger cols = [[weakSelf.puzzle.puzzle valueForKeyPath:@"size.cols"] integerValue];
            CGFloat cellSize = floor(MIN(width / cols, height / rows));
            CGFloat cellsWidth = cellSize * cols;
            CGFloat cellsHeight = cellSize * rows;
            CGFloat cellsLeft = (width - cellsWidth) / 2.0;
            CGFloat cellsTop = (height - cellsHeight) / 2.0;
            CGRect selectedArea = weakSelf.selectedClue ? [weakSelf.selectedClue[@"area"] CGRectValue] : CGRectMake(-1.0, -1.0, 0.0, 0.0);
            NSArray* interectingClues = [weakSelf.puzzle cluesIntersectingClue:weakSelf.selectedClue];
            
            id gridColor = [context colorGray:0.0 alpha:1.0];
            id boxColor = [context colorGray:0.5 alpha:1.0];
            id clueFont = [context fontWithName:@"Helvetica" size:9.0];
            id clueColor = [context colorGray:0.3 alpha:1.0];
            id letterFont = [context fontWithName:@"Helvetica" size:MAX(16.0, cellSize - 13.0)];
            id letterColor = gridColor;
            id selectedCellColor = [context colorRed:0.400 green:0.800 blue:1.000 alpha:1.0];
            id intersectingClueColor = [context colorRed:0.400 green:1.000 blue:1.000 alpha:0.2];
            
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
            
            NSArray* grid = weakSelf.puzzle.puzzle[@"grid"];
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
                    CGRect p = CGRectMake(col, row, 1.0, 1.0);
                    if (CGRectIntersectsRect(selectedArea, p)) {
                        NSRect r = NSInsetRect(NSMakeRect(cellsLeft + col * cellSize, cellsTop + cellsHeight - (row * cellSize) - cellSize, cellSize, cellSize), .5, .5);
                        [context setFillColor:selectedCellColor];
                        [context fillRect:r];
                    }
                    else {
                        for (NSDictionary* aClue in interectingClues) {
                            CGRect aClueArea = [aClue[@"area"] CGRectValue];
                            if (CGRectIntersectsRect(aClueArea, p)) {
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
                    [context setTextPosition:NSMakePoint(cellsLeft + col * cellSize + 1.0,
                                                         cellsTop + cellsHeight - (row * cellSize + 9.0))];
#if 1
                    [context show:[NSString stringWithFormat:@"%d", (int) num]];
#else
                    NSDictionary* answer = [weakSelf.puzzle cluesAtRow:row column:col][0];
                    
                    [context show:answer[@"clue"]];
#endif
                }
            }
        };

        [self setNeedsDisplay];
    }
}

- (void)setSelectedClue:(NSDictionary *)selectedClue {
    NSParameterAssert(selectedClue[@"gridnum"]);

    if (![self.selectedClue isEqual:selectedClue]) {
        mSelectedClue = selectedClue;
        [self setNeedsDisplay];
    }
}

@end
