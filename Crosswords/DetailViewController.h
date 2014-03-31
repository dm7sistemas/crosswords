//
//  DetailViewController.h
//  Crosswords
//
//  Created by Mark Alldritt on 2/1/2014.
//  Copyright (c) 2014 Late Night Software Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Puzzle.h"
#import "GridView.h"
#import "ClueView.h"


@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) Puzzle* puzzle;

@property (weak, nonatomic) IBOutlet UILabel *authorView;
@property (weak, nonatomic) IBOutlet UILabel *copyrightView;
@property (weak, nonatomic) IBOutlet UILabel *notesView;
@property (weak, nonatomic) IBOutlet GridView *gridView;
@property (weak, nonatomic) IBOutlet ClueView *clueView;

@property (assign, nonatomic) BOOL showInGrid;

@end
