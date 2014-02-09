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
        NSString* editor = self.puzzle.editor;
        NSString* author = self.puzzle.author;
        NSString* copyright = self.puzzle.copyright;

        if ([author caseInsensitiveCompare:editor] == NSOrderedSame)
            editor = nil;

        self.navigationItem.title = self.puzzle.title;
        self.authorView.text = editor.length != 0 ? [NSString stringWithFormat:@"%@ (Editor: %@)", author, editor] : author;
        self.copyrightView.text = copyright.length != 0 ? [NSString stringWithFormat:@"%C %@", (UniChar) 0x00A9 /* Unicode copyright symbol */, copyright] : @"";
        self.notesView.text = self.puzzle.notes;
        self.gridView.puzzle = self.puzzle;
        self.showAnswersView.hidden = NO;
        self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"Clues", @"Puzzle Clues");
    }
    else {
        self.navigationItem.title = NSLocalizedString(@"ChoosePuzzle", @"Choose a puzzle");
        self.authorView.text = @"";
        self.copyrightView.text = @"";
        self.notesView.text = @"";
        self.gridView.puzzle = nil;
        self.showAnswersView.hidden = YES;
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

- (IBAction)toggleShowAnswers:(id)sender {
    self.gridView.showAnswers = !self.gridView.showAnswers;
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
