//  QOLocalizableStrings
//
//  QOLocalizableStringsTableView.h
//
//  Created by Sergey Krotkih on 23.02.11.
//  Copyright 2011 Quickoffice. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum  
{
    TYPE_DATA_MAIN,
    TYPE_DATA_ORG,
    TYPE_DATA_NEW,
    TYPE_DATA_NO_TRANSLATION
} TYPE_FILE;


@class QOLocalizableStringsController;

@interface QOLocalizableStringsTableView : NSScrollView  <NSTableViewDelegate, NSTableViewDataSource>
{
    NSTableView* tableView;
    NSMutableArray* records;
    NSMutableArray* repeatedString;
    NSMutableArray* similarStrings;
    BOOL isShowSimilarStrings;
    
    QOLocalizableStringsController* parentController;
    NSString* projectName;
    TYPE_FILE typeFile;
    NSMenu* contextMenu;
    NSString* targetLanguage;
    NSString* sourceFile;
    NSString* targetFile;    
}

@property(nonatomic, retain) NSArray* records;
@property(readwrite, nonatomic, retain) QOLocalizableStringsController* parentController;
@property(readwrite, nonatomic, assign) TYPE_FILE typeFile;
@property(readwrite, nonatomic, copy) NSString* sourceFile;
@property(readwrite, nonatomic, copy) NSString* targetFile;

-(QOLocalizableStringsTableView*) initWithFile: (NSString*)aFileName encoding: (NSStringEncoding)enc projectName: (NSString*)aProjectName lng: (NSString*)aLng;

@end
