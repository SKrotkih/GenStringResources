//  GenStringResources
//
//  QOLocalizableXIBStrings.h
//
//  Created by Sergey Krotkih on 08.03.11.
//  Copyright 2011 Quickoffice. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GenStringResourcesController;

@interface QOLocalizableXIBStrings : NSObject 
{
    GenStringResourcesController* appController;
    NSThread* thread;
}

@property(nonatomic, assign) GenStringResourcesController* appController;

+ (QOLocalizableXIBStrings *) sharedInstance;
- (void) startScan;
- (void) openProject;

@end
