//  GenStringResources
//
//  QOSummaryStrings.h
//
//  Created by Sergey Krotkih on 3/14/11.
//  Copyright 2011 Quickoffice. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GenStringResourcesController;

@interface QOSummaryStrings : NSObject
{
    GenStringResourcesController* appController;
    NSThread* thread;
}

@property(nonatomic, assign) GenStringResourcesController* appController;

+ (QOSummaryStrings*) sharedSummaryStrings;
- (void) startScan;

@end
