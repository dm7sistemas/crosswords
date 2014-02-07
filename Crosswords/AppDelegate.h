//
//  AppDelegate.h
//  Crosswords
//
//  Created by Mark Alldritt on 2/1/2014.
//  Copyright (c) 2014 Late Night Software Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


extern NSMutableDictionary* gPublishers;
extern NSMutableDictionary* gAuthors;


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
