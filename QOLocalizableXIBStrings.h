//  QOLocalizableStrings
//
//  QOLocalizableXIBStrings.h
//
//  Created by Sergey Krotkih on 08.03.11.
//  Copyright 2011 Quickoffice. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class QOLocalizableStringsController;

@interface QOLocalizableXIBStrings : NSObject 
{
    QOLocalizableStringsController* appController;
    NSThread* thread;
}

@property(nonatomic, assign) QOLocalizableStringsController* appController;

+ (QOLocalizableXIBStrings *) sharedLocalizableXIBStrings;
- (void) startScan;
- (void) openProject;

@end
