//
//  DetailViewController.m
//  Crosswords
//
//  Created by Mark Alldritt on 2/1/2014.
//  Copyright (c) 2014 Late Night Software Ltd. All rights reserved.
//

#import "DetailViewController.h"
#import "PuzzleHelper.h"

@interface DetailViewController ()

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) PuzzleHelper* helper;

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setCrossword:(id)newCrossword
{
    if (_crossword != newCrossword) {
        _crossword = newCrossword;
        _helper = [[PuzzleHelper alloc] initWithPuzzle:newCrossword];
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.crossword) {
        NSDictionary* puzzle = self.crossword;
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
        self.gridView.puzzle = self.helper;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Puzzles", @"Crossword puzzles");
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
