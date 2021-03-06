//
//  AppDelegate.m
//  Crosswords
//
//  Created by Mark Alldritt on 2/1/2014.
//  Copyright (c) 2014 Late Night Software Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "Puzzle.h"


NSMutableDictionary* gPublishers = nil;
NSMutableDictionary* gAuthors = nil;


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    gPublishers = [NSMutableDictionary dictionary];
    gAuthors = [NSMutableDictionary dictionary];
    
    for (NSString* jsonPath in [[NSBundle mainBundle] pathsForResourcesOfType:@"json" inDirectory:nil]) {
        NSError* error = nil;
        NSDictionary* puzzle = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:jsonPath]
                                                               options:0
                                                                 error:&error];
        
        if (puzzle) {
            Puzzle* helper = [[Puzzle alloc] initWithPuzzle:puzzle filename:[jsonPath lastPathComponent]];
            NSString* publisher = helper.publisher;
            NSString* author = helper.author;
            
            if (!gPublishers[publisher])
                gPublishers[publisher] = [NSMutableArray arrayWithObject:helper];
            else
                [gPublishers[publisher] addObject:helper];

            if (!gAuthors[author])
                gAuthors[author] = [NSMutableArray arrayWithObject:helper];
            else
                [gAuthors[author] addObject:helper];
        }
        else
            NSLog(@"Failed to read %@, error: %@", jsonPath, error);
    }

    // Override point for customization after application launch.
    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
    splitViewController.delegate = (id)navigationController.topViewController;
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
