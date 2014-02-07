//
//  DetailViewController.m
//  Crosswords
//
//  Created by Mark Alldritt on 2/1/2014.
//  Copyright (c) 2014 Late Night Software Ltd. All rights reserved.
//

#import "DetailViewController.h"
#import "GridView.h"
#import "PuzzleHelper.h"


@interface DetailViewController ()

@property (strong, nonatomic) UIPopoverController *masterPopoverController;

@end

@implementation DetailViewController

@synthesize puzzle = mPuzzle;

#pragma mark - Managing the detail item

- (void)setPuzzle:(PuzzleHelper*)newPuzzle {
    if (mPuzzle != newPuzzle) {
        mPuzzle = newPuzzle;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView {
    // Update the user interface for the detail item.

    if (self.puzzle) {
        NSDictionary* puzzle = self.puzzle.puzzle;
        NSString* editor = puzzle[@"editor"];
        NSString* author = puzzle[@"author"];
        NSString* copyright = puzzle[@"copyright"];
        
        if ([editor isEqual:[NSNull null]] || editor.length == 0)
            editor = nil;
        if ([author isEqual:[NSNull null]] || author.length == 0)
            author = @"unknown";
        if ([copyright isEqual:[NSNull null]] || copyright.length == 0)
            copyright = nil;
        
        self.authorView.text = editor ? [NSString stringWithFormat:@"%@ (Editor: %@)", author, editor] : author;
        self.navigationItem.title = puzzle[@"title"];
        self.copyrightView.text = copyright ? [NSString stringWithFormat:@"%C %@", (UniChar) 0x00A9 /* Unicode copyright symbol */, copyright] : @"";
        self.gridView.puzzle = self.puzzle;
        self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"Clues", @"Puzzle Clues");
    }
    else {
        self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"Puzzles", @"Crossword Puzzles");        
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController {
    barButtonItem.title = self.puzzle ? NSLocalizedString(@"Clues", @"Puzzle Clues") : NSLocalizedString(@"Puzzles", @"Crossword Puzzles");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
