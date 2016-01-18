//
//  AppDelegate.m
//  CustomImageRep
//
//  Created by Freddie Tilley on 18-01-16.
//  Copyright © 2016 Impending. All rights reserved.
//

#import "AppDelegate.h"
#import "IMZorqImageRep.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSImageView *imageView;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.imageView.image = [NSImage imageNamed: @"dice"];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
