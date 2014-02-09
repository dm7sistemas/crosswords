//
//  GridView.h
//  Crosswords
//
//  Created by Mark Alldritt on 2/6/2014.
//  Copyright (c) 2014 Late Night Software Ltd. All rights reserved.
//

#import "MPWView_iOS.h"
#import "PuzzleHelper.h"


extern NSString* GridViewSelectedClueChangedNotification;


@interface GridView : MPWView

@property (strong, nonatomic) PuzzleHelper* puzzle;
@property (strong, nonatomic) NSDictionary* selectedClue;
@property (nonatomic) BOOL showAnswers;

@end
