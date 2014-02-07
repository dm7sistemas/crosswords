//
//  PuzzlesViewController.h
//  Crosswords
//
//  Created by Mark Alldritt on 2/1/2014.
//  Copyright (c) 2014 Late Night Software Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface PuzzlesViewController : UITableViewController

@property (strong, nonatomic) DetailViewController* detailViewController;
@property (strong, nonatomic) NSDictionary* puzzles;

@end


@interface PuzzlesByPublisherViewController : PuzzlesViewController

@end


@interface PuzzlesByAuthorViewController : PuzzlesViewController

@end

