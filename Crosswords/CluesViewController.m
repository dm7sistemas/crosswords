//
//  CluesViewController.m
//  Crosswords
//
//  Created by Mark Alldritt on 2/7/2014.
//  Copyright (c) 2014 Late Night Software Ltd. All rights reserved.
//

#import "CluesViewController.h"
#import "GridView.h"

NSString* DetailViewControllerSelectedClueChangedNotification = @"DetailViewControllerSelectedClueChangedNotification";


@interface CluesViewController ()

@property (strong, nonatomic) NSArray* acrossClues;
@property (strong, nonatomic) NSArray* downClues;
@property (strong, nonatomic) NSArray* searchResults;

@end

@implementation CluesViewController

@synthesize puzzle = mPuzzle;
@synthesize selectedClue = mSelectedClue;

- (void)_gridViewSelectionChanged:(NSNotification*) notification {
    GridView* gridView = notification.object;
    NSDictionary* clue = notification.userInfo;
    
    if (gridView.puzzle == self.puzzle) {
        self.selectedClue = clue;
    }
}

- (id)initWithStyle:(UITableViewStyle)style {
    if ((self = [super initWithStyle:style])) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_gridViewSelectionChanged:)
                                                 name:GridViewSelectedClueChangedNotification
                                               object:nil];
    self.clearsSelectionOnViewWillAppear = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setPuzzle:(PuzzleHelper *)newPuzzle {
    if (newPuzzle != mPuzzle) {
        mPuzzle = newPuzzle;
        
        self.acrossClues = [newPuzzle.cluesAcross.allKeys sortedArrayUsingSelector:@selector(compare:)];
        self.downClues = [newPuzzle.cluesDown.allKeys sortedArrayUsingSelector:@selector(compare:)];

        [self.tableView reloadData];
    }
}

- (void)setSelectedClue:(NSDictionary *)newSelectedClue {
    if (newSelectedClue != mSelectedClue) {
        mSelectedClue = newSelectedClue;
        
        NSNumber* key = newSelectedClue[@"gridnum"];
        NSUInteger section = self.puzzle.cluesAcross[key] == nil ? 1 : 0;
        NSUInteger row = section == 0 ? [self.acrossClues indexOfObject:key] : [self.downClues indexOfObject:key];
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        
        if (![self.tableView.indexPathForSelectedRow isEqual:indexPath]) {
            [self.tableView selectRowAtIndexPath:indexPath
                                        animated:YES
                                  scrollPosition:UITableViewScrollPositionMiddle];
        }
        
        if (self.searchDisplayController.isActive) {
            row = [self.searchResults indexOfObject:newSelectedClue];
            
            if (row == NSNotFound) {
                indexPath = self.searchDisplayController.searchResultsTableView.indexPathForSelectedRow;
                
                if (indexPath)
                    [self.searchDisplayController.searchResultsTableView deselectRowAtIndexPath:indexPath animated:YES];
            }
            else {
                indexPath = [NSIndexPath indexPathForItem:row inSection:0];

                if (![self.searchDisplayController.searchResultsTableView.indexPathForSelectedRow isEqual:indexPath]) {
                    [self.searchDisplayController.searchResultsTableView selectRowAtIndexPath:indexPath
                                                                                     animated:YES
                                                                               scrollPosition:UITableViewScrollPositionMiddle];
                }
            }
        }

        [[NSNotificationCenter defaultCenter] postNotificationName:DetailViewControllerSelectedClueChangedNotification
                                                            object:self
                                                          userInfo:newSelectedClue];
    }
}

#pragma mark - UISearchDisplayControllerDelegate

- (void)_filterContentForSearchText:(NSString*) searchString scope:(NSUInteger) scope {
    NSArray* acrossClues = [self.puzzle.cluesAcross.allValues filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"clue LIKE[c] %@", [NSString stringWithFormat:@"*%@*", searchString]]];
    NSArray* downClues = [self.puzzle.cluesDown.allValues filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"clue LIKE[c] %@", [NSString stringWithFormat:@"*%@*", searchString]]];
    
    NSMutableArray* r = [NSMutableArray arrayWithArray:acrossClues];
    [r addObjectsFromArray:downClues];

    NSSortDescriptor* descriptor = [[NSSortDescriptor alloc] initWithKey:@"clue" ascending:YES selector:@selector(caseInsensitiveCompare:)];

    self.searchResults = [r sortedArrayUsingDescriptors:@[descriptor]];
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView {
    [tableView registerClass:[CluesSearchTableCell class] forCellReuseIdentifier:@"Cell"];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self _filterContentForSearchText:searchString scope:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.searchDisplayController.searchResultsTableView)
        return 1;
    else
        return 2;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView)
        return nil;
    else
        switch (section) {
        case 0:
            return @"Across";

        case 1:
            return @"Down";

        default:
            return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView)
        return self.searchResults.count;
    else
        switch (section) {
        case 0:
            return self.acrossClues.count;
            
        case 1:
            return self.downClues.count;
            
        default:
            return 0;
    }
}

- (NSString*)_formatAnswerLetterCounts:(NSDictionary*)clue {
    NSArray* words = clue[@"words"];
    
    if (words) {
        NSUInteger numWords = words.count;
        NSString* result = @"";
        
        for (NSUInteger i = 0; i < numWords; ++i) {
            if (i != numWords - 1)
                result = [NSString stringWithFormat:@"%@, %d", result, (int)[words[i] rangeValue].length];
            else
                result = [NSString stringWithFormat:@"%@ and %d", result, (int)[words[i] rangeValue].length];
        }
        
        return [NSString stringWithFormat:@"%@ letters", result];
    }
    else
        return [NSString stringWithFormat:@"%d letters", (int)[clue[@"answer"] length]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSDictionary* clue = self.searchResults[indexPath.row];
        
        cell.textLabel.text = clue[@"clue"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d %@, %@", (int)[clue[@"gridnum"] integerValue], [clue[@"across"] boolValue] ? @"across" : @"down", [self _formatAnswerLetterCounts:clue]];
    }
    else {
        NSDictionary* clues = indexPath.section == 0 ? self.puzzle.cluesAcross : self.puzzle.cluesDown;
        NSNumber* key = indexPath.section == 0 ? self.acrossClues[indexPath.row] : self.downClues[indexPath.row];
        NSDictionary* clue = clues[key];
        
        NSMutableAttributedString* ats = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@. %@", key, clue[@"clue"]]];
        NSRange r = [ats.string rangeOfString:@"."];
        
        [ats addAttributes:@{NSForegroundColorAttributeName: [UIColor grayColor]} range:NSMakeRange(0, NSMaxRange(r))];
        cell.textLabel.attributedText = ats;
        cell.detailTextLabel.text = [self _formatAnswerLetterCounts:clue];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        self.selectedClue = self.searchResults[indexPath.row];
    }
    else {
        NSDictionary* clues = indexPath.section == 0 ? self.puzzle.cluesAcross : self.puzzle.cluesDown;
        NSNumber* key = indexPath.section == 0 ? self.acrossClues[indexPath.row] : self.downClues[indexPath.row];

        self.selectedClue = clues[key];
    }
}

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end



@implementation CluesSearchTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier])) {

    }
    return self;
}

@end