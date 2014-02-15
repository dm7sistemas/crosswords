//
//  GridView.h
//  Crosswords
//
//  Created by Mark Alldritt on 2/6/2014.
//  Copyright (c) 2014 Late Night Software Ltd. All rights reserved.
//

#import "PuzzleHelper.h"
#import "PuzzleClue.h"

extern NSString* GridViewSelectedClueChangedNotification;


@interface GridView : UIView

@property (strong, nonatomic) PuzzleHelper* puzzle;
@property (strong, nonatomic) PuzzleClue* selectedClue;
@property (nonatomic) BOOL showAnswers;

@end
