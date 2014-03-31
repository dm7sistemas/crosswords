//
//  OptionsViewController.h
//  StaticTableTest
//
//  Created by Mark Alldritt on 2014-03-30.
//  Copyright (c) 2014 Late Night Software Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailViewController.h"


@interface OptionsViewController : UITableViewController

@property (strong, nonatomic) DetailViewController* detailViewController;

@property (weak, nonatomic) IBOutlet UISwitch *showAnswersSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *showCluesInGridSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *showClueDirectionSwitch;
@property (weak, nonatomic) IBOutlet UITableViewCell *showGridCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showSingleClueCell;

- (IBAction)toggleShowAnswers:(id)sender;
- (IBAction)toggleShowCluesInGrid:(id)sender;
- (IBAction)toggleShowClueDirection:(id)sender;

@end
