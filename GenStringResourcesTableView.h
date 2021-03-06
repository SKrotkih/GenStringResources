//  GenStringResources
//
//  GenStringResourcesTableView.h
//
//  Created by Sergey Krotkih on 23.02.11.
//  Copyright 2011 Quickoffice. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GenStringResourcesController;

@interface GenStringResourcesTableView : NSScrollView  <NSTableViewDelegate, NSTableViewDataSource>
{
    NSTableView* tableView;
    NSMutableArray* records;
    NSMutableArray* repeatedStrings;
    NSMutableArray* similarStrings;
    NSMenuItem* checkSimilarMenuItem;
    BOOL isShowSimilarStrings;
    
    GenStringResourcesController* appController;
    NSString* projectName;
    NSString* targetLanguage;
    NSString* sourceFile;
    NSString* targetFile; 
    NSThread* thread;
}


@property(nonatomic, assign) NSTableView* tableView;
@property(nonatomic, retain) NSArray* records;
@property(readwrite, nonatomic, assign) GenStringResourcesController* appController;
@property(readwrite, nonatomic, copy) NSString* sourceFile;
@property(readwrite, nonatomic, copy) NSString* targetFile;

-(id) initWithFile: (NSString*)aFileName encoding: (NSStringEncoding)enc projectName: (NSString*)aProjectName lng: (NSString*)aLng;

@end
