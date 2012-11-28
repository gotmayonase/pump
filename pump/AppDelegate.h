//
//  AppDelegate.h
//  pump
//
//  Created by Mike Mayo on 11/26/12.
//  Copyright (c) 2012 Mike Mayo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSBox *spinnerBox;
@property (assign) IBOutlet NSProgressIndicator *spinner;
@property (assign) IBOutlet NSArrayController *sideBarController;
@property (assign) IBOutlet NSCollectionView *sideBarCollectionView, *contentCollectionView;
@property (nonatomic, strong) NSMutableArray *games, *streams;

@end
