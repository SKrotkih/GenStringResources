//  QOLocalizableStrings
//
//  QOSummaryStrings.h
//
//  Created by Sergey Krotkih on 3/14/11.
//  Copyright 2011 Quickoffice. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class QOLocalizableStringsController;

@interface QOSummaryStrings : NSObject
{
    QOLocalizableStringsController* appController;
    NSThread* thread;
}

@property(nonatomic, assign) QOLocalizableStringsController* appController;

+ (QOSummaryStrings*) sharedSummaryStrings;
- (void) startScan;

@end
