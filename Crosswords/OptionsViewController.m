//
//  OptionsViewController.m
//  StaticTableTest
//
//  Created by Mark Alldritt on 2014-03-30.
//  Copyright (c) 2014 Late Night Software Ltd. All rights reserved.
//

#import "OptionsViewController.h"


#define kUseBetterIcons  1

@interface OptionsViewController ()

@end

@implementation OptionsViewController

- (void)_configureCells {
#if kUseBetterIcons
    ((UIImageView*)self.showGridCell.accessoryView).image = self.detailViewController.showInGrid ? [UIImage imageNamed:@"Checked"] : nil /*[UIImage imageNamed:@"Unchecked"]*/;
    ((UIImageView*)self.showSingleClueCell.accessoryView).image = (!self.detailViewController.showInGrid) ? [UIImage imageNamed:@"Checked"] : nil /*[UIImage imageNamed:@"Unchecked"]*/;
#else
    self.showGridCell.accessoryType = self.detailViewController.showInGrid ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    self.showSingleClueCell.accessoryType = (!self.detailViewController.showInGrid) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
#endif
    
    self.showAnswersSwitch.on = self.detailViewController.gridView.showAnswers;
    self.showClueDirectionSwitch.on = self.detailViewController.gridView.showClueDirections;
    self.showCluesInGridSwitch.on = self.detailViewController.gridView.showCluesInGrid;
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
#if kUseBetterIcons
    self.showGridCell.accessoryView = [[UIImageView alloc ] initWithFrame:CGRectMake(0, 0, 32, 32)];
    self.showSingleClueCell.accessoryView = [[UIImageView alloc ] initWithFrame:CGRectMake(0, 0, 32, 32)];
#endif
    [self _configureCells];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setDetailViewController:(DetailViewController *)detailViewController {
    if (self.detailViewController != detailViewController) {
        _detailViewController = detailViewController;
        [self _configureCells];
    }
}

- (IBAction)toggleShowAnswers:(id)sender {
    self.detailViewController.gridView.showAnswers = !self.detailViewController.gridView.showAnswers;
    [self _configureCells];
}

- (IBAction)toggleShowCluesInGrid:(id)sender {
    self.detailViewController.gridView.showCluesInGrid = !self.detailViewController.gridView.showCluesInGrid;
    [self _configureCells];
}

- (IBAction)toggleShowClueDirection:(id)sender {
    self.detailViewController.gridView.showClueDirections = !self.detailViewController.gridView.showClueDirections;
    [self _configureCells];
}

#pragma mark - Table view data source

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];

    if ([cell isEqual:self.showGridCell] || [cell isEqual:self.showSingleClueCell]) {
        return YES;
    }

    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];

    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];

    if ([cell isEqual:self.showGridCell]) {
        self.detailViewController.showInGrid = YES;
        [self _configureCells];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else if ([cell isEqual:self.showSingleClueCell]) {
        self.detailViewController.showInGrid = NO;
        [self _configureCells];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

@end
