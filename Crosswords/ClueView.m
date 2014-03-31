//
//  ClueView.m
//  Crosswords
//
//  Created by Mark Alldritt on 2014-03-30.
//  Copyright (c) 2014 Late Night Software Ltd. All rights reserved.
//

#import "ClueView.h"


NSString* ClueViewSelectedClueChangedNotification = @"ClueViewSelectedClueChangedNotification";


@implementation ClueView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [[UIColor blueColor] set];
    UIRectFill(rect);
}

@end
