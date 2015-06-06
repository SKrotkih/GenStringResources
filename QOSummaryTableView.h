//  QOLocalizableStrings
//
//  QOSummaryTableView.h
//
//  Created by Sergey Krotkih on 3/14/11.
//  Copyright 2011 Quickoffice. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QOLocalizableStringsTableView.h"

typedef enum  
{
    TYPE_DICTIONARY_CURRENT,
    TYPE_DICTIONARY_ACTUAL,
    TYPE_NO_TRANSLATION
} TYPE_FILE;

@interface QOSummaryTableView : QOLocalizableStringsTableView
{
    NSMenu* contextMenu;
    TYPE_FILE typeFile;
}

- (id) initWithDictionary: (NSMutableArray*)aRecords lng: (NSString*)aLng;

@property(readwrite, nonatomic, assign) TYPE_FILE typeFile;

@end
