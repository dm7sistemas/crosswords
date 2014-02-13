//
//  CluesViewController.h
//  Crosswords
//
//  Created by Mark Alldritt on 2/7/2014.
//  Copyright (c) 2014 Late Night Software Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PuzzleHelper.h"
#import "PuzzleClue.h"

extern NSString* DetailViewControllerSelectedClueChangedNotification;


@interface CluesViewController : UITableViewController

@property (strong, nonatomic) PuzzleHelper* puzzle;
@property (strong, nonatomic) PuzzleClue* selectedClue;

@end


@interface CluesSearchTableCell : UITableViewCell

@end