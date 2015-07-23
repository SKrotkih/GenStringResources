//  GenStringResources
//
//  GenStringResources.h
//
//  Created by Sergey Krotkih on 08.03.11.
//  Copyright 2011 Quickoffice. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GenStringResourcesController;

@interface GenStringResources : NSObject <NSApplicationDelegate>
{
    NSOperationQueue* scanQueue;
    GenStringResourcesController* appController;
    NSThread* thread;
    
}

@property(nonatomic, assign) GenStringResourcesController* appController;
@property(nonatomic, readwrite, assign) NSOperationQueue* scanQueue;

+ (GenStringResources *) sharedLocalizableStrings;
- (void) startScanStrings;
- (void) startScanModules;
- (void) openProject;
- (void) openProjectModules;

@end
