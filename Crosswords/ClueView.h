//
//  ClueView.h
//  Crosswords
//
//  Created by Mark Alldritt on 2014-03-30.
//  Copyright (c) 2014 Late Night Software Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Puzzle.h"
#import "PuzzleClue.h"


extern NSString* ClueViewSelectedClueChangedNotification;


@interface ClueView : UIView

@property (strong, nonatomic) Puzzle* puzzle;
@property (strong, nonatomic) PuzzleClue* selectedClue;
@property (nonatomic) BOOL showAnswers;
@property (nonatomic) BOOL showCluesInGrid;

@end
