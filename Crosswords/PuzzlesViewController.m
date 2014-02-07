//
//  PuzzlesViewController.m
//  Crosswords
//
//  Created by Mark Alldritt on 2/1/2014.
//  Copyright (c) 2014 Late Night Software Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "PuzzlesViewController.h"
#import "DetailViewController.h"
#import "CluesViewController.h"
#import "GTMNSString+HTML.h"

@interface PuzzlesViewController ()

@property (strong, nonatomic) PuzzleHelper* selectedPuzzle;
@property (strong, nonatomic) NSArray* sortedSections;

@end

@implementation PuzzlesViewController

@synthesize sortedSections = mSortedSections;

- (NSArray*)sortedSections {
    if (!mSortedSections)
        mSortedSections = [self.puzzles.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    return mSortedSections;
}

- (void)awakeFromNib {
    self.clearsSelectionOnViewWillAppear = NO;
    self.preferredContentSize = CGSizeMake(320.0, 600.0);
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"PuzzlesBack", @"Crossword Puzzles Back Button")
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:nil
                                                                            action:nil];
    
#if 0
    UISegmentedControl* control = [[UISegmentedControl alloc] initWithFrame:CGRectZero];
    
    [control insertSegmentWithImage:[UIImage imageNamed:@"Publisher"] atIndex:0 animated:NO];
    [control insertSegmentWithImage:[UIImage imageNamed:@"Author"] atIndex:0 animated:NO];
    [control insertSegmentWithImage:[UIImage imageNamed:@"Calendar"] atIndex:0 animated:NO];
    [control sizeToFit];
    CGSize size = self.navigationController.toolbar.frame.size;
    CGRect frame = CGRectInset(control.frame, -30.0, -3.0);
    
    frame.origin.x = (size.width - CGRectGetWidth(frame)) / 2.0;
    
    [control setFrame:frame];
    
    UIBarButtonItem* barItem = [[UIBarButtonItem alloc] initWithCustomView:control];
    
    [self setToolbarItems:@[barItem] animated:NO];
#endif
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    CluesViewController* cluesController = segue.destinationViewController;
    
    cluesController.puzzle = self.selectedPuzzle;
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sortedSections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.puzzles[self.sortedSections[section]] count];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sortedSections[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSDictionary* puzzle = self.puzzles[self.sortedSections[indexPath.section]][indexPath.row];
    
    cell.textLabel.text = [puzzle[@"title"] gtm_stringByUnescapingFromHTML];
    
    if (self.puzzles == gPublishers)
        cell.detailTextLabel.text = [puzzle[@"author"] gtm_stringByUnescapingFromHTML];
    else if (self.puzzles == gAuthors)
        cell.detailTextLabel.text = [puzzle[@"publisher"] gtm_stringByUnescapingFromHTML];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary* crossword = self.puzzles[self.sortedSections[indexPath.section]][indexPath.row];
    
    self.selectedPuzzle = [[PuzzleHelper alloc] initWithPuzzle:crossword];
    self.detailViewController.puzzle = self.selectedPuzzle;
    
    [self performSegueWithIdentifier:@"cluesSegue" sender:self];
}

@end


@implementation PuzzlesByPublisherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.puzzles = gPublishers;
}

@end


@implementation PuzzlesByAuthorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.puzzles = gAuthors;
}

@end
