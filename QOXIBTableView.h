//  QOLocalizableStrings
//
//  QOXIBTableView.h
//
//  Created by Sergey Krotkih on 07.03.11.
//  Copyright 2011 Quickoffice. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QOLocalizableStringsTableView.h"

typedef enum  
{
    TYPE_DATA_MAIN,
    TYPE_DATA_ORG,
    TYPE_DATA_NEW,
    TYPE_DATA_NO_TRANSLATION
} TYPE_FILE;

@interface QOXIBTableView : QOLocalizableStringsTableView
{
    TYPE_FILE typeFile;
    NSMenu* contextMenu;
}

@property(readwrite, nonatomic, assign) TYPE_FILE typeFile;

-(id) initWithFile: (NSString*)aFileName encoding: (NSStringEncoding)enc projectName: (NSString*)aProjectName lng: (NSString*)aLng;

@end
