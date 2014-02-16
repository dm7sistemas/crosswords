//
//  PuzzleTests.m
//  Crosswords
//
//  Created by Mark Alldritt on 2/6/2014.
//  Copyright (c) 2014 Late Night Software Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Puzzle.h"
#import "PuzzleClue.h"


@interface PuzzleTests : XCTestCase

@property (nonatomic) NSDictionary* puzzle;

@end

@implementation PuzzleTests

- (void)setUp {
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    
    NSString* puzzlePath = [[NSBundle mainBundle] pathForResource:@"crossword1" ofType:@"json"];
    
    self.puzzle = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:puzzlePath]
                                                  options:0
                                                    error:nil];
    XCTAssert(self.puzzle, @"failed to load puzzle at %@", puzzlePath);
}

- (void)tearDown {
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)test1 {
    //  Test the Puzzle accessors
    Puzzle* helper = [[Puzzle alloc] initWithPuzzle:self.puzzle filename:@"xxxx"];
    
    XCTAssert(helper.puzzle == self.puzzle, @"puzzle accessor failed");
    
    NSDictionary* cluesAcross = helper.cluesAcross;
    NSArray* cluesAcrossKeys = [cluesAcross.allKeys sortedArrayUsingSelector:@selector(compare:)];
    NSArray* expectedAcrossKeys = @[
        @1, @5, @12, @16, @18, @19, @20, @22, @23, @24, @26, @28, @29, @30, @31, @34, @35, @38,
        @39, @40, @42, @45, @47, @50, @52, @54, @55, @56, @57, @59, @61, @62, @63, @65, @67, @68,
        @70, @72, @74, @76, @77, @80, @82, @83, @85, @86, @87, @88, @89, @90, @92, @94, @95, @96,
        @98, @102, @104, @106, @107, @110, @112, @113, @115, @116, @117, @118, @119, @120, @121,
        @122, @123, @124 ];
    
    XCTAssert([cluesAcrossKeys isEqualToArray:expectedAcrossKeys], @"cluesAcross keys incorrect");
    XCTAssert([[NSSet setWithArray:[cluesAcross.allValues valueForKey:@"across"]] isEqualToSet:[NSSet setWithObject:@YES]], @"cluesAcross contains non across clues");
    
    NSDictionary* a1 = @{@"gridnum": @1,
                         @"across": @YES,
                         @"answer": @"HAWS",
                         @"area": [NSValue valueWithCGRect:CGRectMake(0, 0, 4, 1)],
                         @"clue": @"Turns left",
                         @"col": @0,
                         @"row": @0};
    NSDictionary* a5 = @{@"gridnum": @5,
                         @"across": @YES,
                         @"answer": @"LEERSAT",
                         @"area": [NSValue valueWithCGRect:CGRectMake(7, 0, 7, 1)],
                         @"clue": @"Ogles offensively",
                         @"col": @7,
                         @"row": @0};
    NSDictionary* a65 = @{@"gridnum": @65,
                          @"across": @YES,
                          @"answer": @"ROCOCO",
                          @"area": [NSValue valueWithCGRect:CGRectMake(11, 10, 6, 1)],
                          @"clue": @"Furniture style of Louis XV",
                          @"col": @11,
                          @"row": @10};
    NSDictionary* a68 = @{@"gridnum": @68,
                          @"across": @YES,
                          @"answer": @"DORA",
                          @"area": [NSValue valueWithCGRect:CGRectMake(2, 11, 4, 1)],
                          @"clue": @"___ the Explorer",
                          @"col": @2,
                          @"row": @11};
    NSDictionary* a120 = @{@"gridnum": @120,
                           @"across": @YES,
                           @"answer": @"ODE",
                           @"area": [NSValue valueWithCGRect:CGRectMake(0, 20, 3, 1)],
                           @"clue": @"Poetic rhapsody",
                           @"col": @0,
                           @"row": @20};
    
    //  Inspect a few of the across clues...
    XCTAssert([cluesAcross[@1] isEqual:a1], @"across clue 1 is incorrect");
    XCTAssert([cluesAcross[@5] isEqual:a5], @"across clue 5 is incorrect");
    XCTAssert([cluesAcross[@65] isEqual:a65], @"across clue 65 is incorrect");
    XCTAssert([cluesAcross[@68] isEqual:a68], @"across clue 68 is incorrect");
    XCTAssert([cluesAcross[@120] isEqual:a120], @"across clue 120 is incorrect");
    
    NSDictionary* cluesDown = helper.cluesDown;
    NSArray* cluesDownKeys = [cluesDown.allKeys sortedArrayUsingSelector:@selector(compare:)];
    NSArray* expectedDownKeys = @[
        @1, @2, @3, @4, @5, @6, @7, @8, @9, @10, @11, @12, @13, @14, @15, @17, @19, @21, @23,
        @25, @27, @31, @32, @33, @35, @36, @37, @38, @41, @42, @43, @44, @46, @48, @49, @51,
        @53, @55, @58, @60, @63, @64, @65, @66, @69, @71, @73, @74, @75, @78, @79, @81, @84,
        @91, @93, @94, @95, @97, @99, @100, @101, @103, @104, @105, @108, @109, @111, @114 ];

    XCTAssert([cluesDownKeys isEqualToArray:expectedDownKeys], @"cluesDown keys incorrect");
    XCTAssert([[NSSet setWithArray:[cluesDown.allValues valueForKey:@"across"]] isEqualToSet:[NSSet setWithObject:@NO]], @"cluesDown contains non down clues");

    NSDictionary* d3 = @{@"gridnum": @3,
                         @"across": @NO,
                         @"answer": @"WIDEN",
                         @"area": [NSValue valueWithCGRect:CGRectMake(2, 0, 1, 5)],
                         @"clue": @"Expand",
                         @"col": @2,
                         @"row": @0};
    NSDictionary* d23 = @{@"gridnum": @23,
                          @"across": @NO,
                          @"answer": @"KNOCKKNOCKWHOSTHERE",
                          @"area": [NSValue valueWithCGRect:CGRectMake(15, 2, 1, 19)],
                          @"clue": @"Start of many jokes",
                          @"col": @15,
                          @"row": @2};
    NSDictionary* d33 = @{@"gridnum": @33,
                          @"across": @NO,
                          @"answer": @"MUNI",
                          @"area": [NSValue valueWithCGRect:CGRectMake(11, 5, 1, 4)],
                          @"clue": @"Tax-free bond, for short",
                          @"col": @11,
                          @"row": @5};
    NSDictionary* d108 = @{@"gridnum": @108,
                           @"across": @NO,
                           @"answer": @"OENO",
                           @"area": [NSValue valueWithCGRect:CGRectMake(19, 17, 1, 4)],
                           @"clue": @"Prefix with -phile",
                           @"col": @19,
                           @"row": @17};
    NSDictionary* d109 = @{@"gridnum": @109,
                           @"across": @NO,
                           @"answer": @"TSKS",
                           @"area": [NSValue valueWithCGRect:CGRectMake(20, 17, 1, 4)],
                           @"clue": @"Some reproaches",
                           @"col": @20,
                           @"row": @17};

    //  Inspect a few of the down clues...
    XCTAssert([cluesDown[@3] isEqual:d3], @"down clue 3 is incorrect");
    XCTAssert([cluesDown[@23] isEqual:d23], @"down clue 23 is incorrect");
    XCTAssert([cluesDown[@33] isEqual:d33], @"down clue 33 is incorrect");
    XCTAssert([cluesDown[@108] isEqual:d108], @"down clue 108 is incorrect");
    XCTAssert([cluesDown[@109] isEqual:d109], @"down clue 109 is incorrect");
    
    //  Make sure all the grid numbers have been indexed.  This is kind of a lame test as across
    //  and down clues can claim the same grid number, but it does find the case where a grid
    //  number has no associated clue.
    NSMutableSet* gridNums = [NSMutableSet setWithArray:self.puzzle[@"gridnums"]];
    [gridNums removeObject:@0]; // never appears in a clue
    for (NSNumber* clueNum in cluesAcross.allKeys)
        [gridNums removeObject:clueNum];
    for (NSNumber* clueNum in cluesDown.allKeys)
        [gridNums removeObject:clueNum];
    XCTAssert(gridNums.count == 0, @"Not all grid nums have been indexed");
}

- (void)test2 {
    //  Test the Puzzle clue lookups
    Puzzle* helper = [[Puzzle alloc] initWithPuzzle:self.puzzle filename:@"xxxx"];
    NSDictionary* cluesAcross = helper.cluesAcross;
    NSDictionary* cluesDown = helper.cluesDown;
    
    //- (NSDictionary*)cluesAtRow:(NSInteger)row column:(NSInteger)column;
    
    for (NSDictionary* aClue in cluesAcross.allValues) {
        XCTAssert([[helper cluesAtRow:[aClue[@"row"] integerValue] column:[aClue[@"col"] integerValue]] containsObject:aClue], @"cluesAtRow:%@ column:%@ failed: returned %@, expected %@", aClue[@"row"], aClue[@"col"], [helper cluesAtRow:[aClue[@"row"] integerValue] column:[aClue[@"col"] integerValue]], aClue);
    }
    for (NSDictionary* aClue in cluesDown.allValues) {
        XCTAssert([[helper cluesAtRow:[aClue[@"row"] integerValue] column:[aClue[@"col"] integerValue]] containsObject:aClue], @"cluesAtRow:%@ column:%@ failed: returned %@, expected %@", aClue[@"row"], aClue[@"col"], [helper cluesAtRow:[aClue[@"row"] integerValue] column:[aClue[@"col"] integerValue]], aClue);
    }
    
    //  Makre sure we get nil for grid cells with no clue
    XCTAssert([helper cluesAtRow:7 column:10] == nil, @"cluesAtRow:7 column:10 found a clue when it should not have");
    XCTAssert([helper cluesAtRow:2 column:3] == nil, @"cluesAtRow:2 column:3 found a clue when it should not have");
    XCTAssert([helper cluesAtRow:20 column:20] == nil, @"cluesAtRow:20 column:20 found a clue when it should not have");
    XCTAssert([helper cluesAtRow:19 column:8] == nil, @"cluesAtRow:20 column:20 found a clue when it should not have");
    
    //- (NSDictionary*)bestClueForRow:(NSInteger)row column:(NSInteger)column;
    XCTAssert([[helper bestClueForRow:4 column:3] isEqual:cluesAcross[@28]], "bestClueForRow:4 column:3 returned the wrong object, received: %@, expected: %@", [helper bestClueForRow:4 column:3], cluesAcross[@28]);
    XCTAssert([[helper bestClueForRow:12 column:1] isEqual:cluesDown[@75]], "bestClueForRow:12 column:1 returned the wrong object, received: %@, expected: %@", [helper bestClueForRow:12 column:1], cluesAcross[@75]);
    XCTAssert([helper bestClueForRow:15 column:9] == nil, "bestClueForRow:15 column:9 returned the wrong object, received: %@, expected: nil", [helper bestClueForRow:15 column:9]);
    
    //- (NSArray*)cluesIntersectingClue:(NSDictionary*) clue;
    NSArray* r = [[cluesDown[@17] intersectingClues] valueForKey:@"gridNumber"];
    NSArray* rd17 = @[@28, @24, @20, @16, @17];
    XCTAssert([r isEqual:rd17], @"cluesIntersectingClue:17 returned the wrong objects, returned: %@, expected: %@", r, rd17);
    r = [[cluesAcross[@106] intersectingClues] valueForKey:@"gridNumber"];
    NSArray* ra106 = @[@106, @60, @58, @101, @100, @99, @94, @93];
    XCTAssert([r isEqual:ra106], @"cluesIntersectingClue:106 returned the wrong objects, returned: %@, expected: %@", r, ra106);
    r = [[cluesDown[@6] intersectingClues] valueForKey:@"gridNumber"];
    NSArray* rd6 = @[@28, @24, @22, @18, @5, @6];
    XCTAssert([r isEqual:rd6], @"cluesIntersectingClue:6 returned the wrong objects, returned: %@, expected: %@", r, rd6);
    r = [[cluesAcross[@121] intersectingClues] valueForKey:@"gridNumber"];
    NSArray* ra121 = @[@121, @58, @111, @21];
    XCTAssert([r isEqual:ra121], @"cluesIntersectingClue:121 returned the wrong objects, returned: %@, expected: %@", r, ra121);
}

@end
