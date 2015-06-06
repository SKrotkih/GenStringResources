//  QOLocalizableStrings
//
//  QOLocalizableStrings.h
//
//  Created by Sergey Krotkih on 08.03.11.
//  Copyright 2011 Quickoffice. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class QOLocalizableStringsController;

@interface QOLocalizableStrings : NSObject <NSApplicationDelegate>
{
    NSOperationQueue* scanQueue;
    QOLocalizableStringsController* appController;
    NSThread* thread;
    
}

@property(nonatomic, assign) QOLocalizableStringsController* appController;
@property(nonatomic, readwrite, assign) NSOperationQueue* scanQueue;

+ (QOLocalizableStrings *) sharedLocalizableStrings;
- (void) startScanStrings;
- (void) startScanModules;
- (void) openProject;
- (void) openProjectModules;

@end
