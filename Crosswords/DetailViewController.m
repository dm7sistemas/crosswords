//
//  DetailViewController.m
//  Crosswords
//
//  Created by Mark Alldritt on 2/1/2014.
//  Copyright (c) 2014 Late Night Software Ltd. All rights reserved.
//

#import "DetailViewController.h"
#import "Puzzle.h"
#import "CluesViewController.h"
#import "OptionsViewController.h"
#import "GTMNSString+HTML.h"


@interface DetailViewController ()

@property (strong, nonatomic) UIPopoverController* masterPopoverController;
@property (strong, nonatomic) UIPopoverController* currentPopoverController;

@end

@implementation DetailViewController

@synthesize puzzle = mPuzzle;

-(void)_cluesTableSelectionChanged:(NSNotification*) notification {
    CluesViewController* cluesViewController = notification.object;
    PuzzleClue* clue = notification.userInfo[@"clue"];
    
    if (cluesViewController.puzzle == self.puzzle) {
        self.gridView.selectedClue = self.clueView.selectedClue = clue;
    }
}

- (void)_selectedClueChanged:(NSNotification*) notification {
    PuzzleClue* clue = notification.userInfo[@"clue"];

    self.gridView.selectedClue = clue;
    self.clueView.selectedClue = clue;
}

- (void)setPuzzle:(Puzzle*)newPuzzle {
    if (mPuzzle != newPuzzle) {
        mPuzzle = newPuzzle;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)setShowInGrid:(BOOL)showInGrid {
    if (self.showInGrid != showInGrid) {
        _showInGrid = showInGrid;
        [self configureView];
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
        self.notesView.text = self.puzzle.notes.gtm_stringByUnescapingFromHTML;
        self.gridView.puzzle = self.puzzle;
        self.clueView.puzzle = self.puzzle;
        self.gridView.hidden = !self.showInGrid;
        self.clueView.hidden = self.showInGrid;
        self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"Clues", @"Puzzle Clues");
    }
    else {
        self.navigationItem.title = NSLocalizedString(@"ChoosePuzzle", @"Choose a puzzle");
        self.authorView.text = @"";
        self.copyrightView.text = @"";
        self.notesView.text = @"";
        self.gridView.puzzle = self.clueView.puzzle = nil;
        self.gridView.hidden = YES;
        self.clueView.hidden = YES;
        self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"Puzzles", @"Crossword Puzzles");
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.showInGrid = NO;
    [self configureView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_selectedClueChanged:)
                                                 name:GridViewSelectedClueChangedNotification
                                               object:self.gridView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_selectedClueChanged:)
                                                 name:ClueViewSelectedClueChangedNotification
                                               object:self.clueView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_cluesTableSelectionChanged:)
                                                 name:DetailViewControllerSelectedClueChangedNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.currentPopoverController dismissPopoverAnimated:YES];
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

#pragma mark - UIStoryboardDelegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self.currentPopoverController dismissPopoverAnimated:YES];

    UIPopoverController* popoverController = [(UIStoryboardPopoverSegue*)segue popoverController];
    OptionsViewController* optionsViewController = (OptionsViewController*) segue.destinationViewController;
    
    optionsViewController.detailViewController = self;
    self.currentPopoverController = popoverController;
}

#pragma mark - UIPopoverControllerDelegate

- (void) popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    self.currentPopoverController = nil;
}

@end
