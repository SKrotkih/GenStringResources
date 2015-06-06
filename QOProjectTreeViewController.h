//
//  QOProjectTreeViewController.h
//  QOLocalizableStrings
//
//  Created by Sergey Krotkih on 21.05.11.
//  Copyright 2011 Quickoffice. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QOxcodeprojOutlineView.h"
#import "QOColoredSyntaxTextView.h"

@class QOLocalizableStringsController;

@interface QOProjectTreeViewController : NSViewController <NSOutlineViewDelegate, NSOutlineViewDataSource>
{
    QOLocalizableStringsController* appController;
    NSTabView* tabViewXcodeProject;
	IBOutlet QOxcodeprojOutlineView* treeOutlineView;
	IBOutlet QOColoredSyntaxTextView* textView;
	NSMutableArray*	projectTree;
    NSString* pathOfProject;
    NSString* projectName;
    NSString* targetOfBuild;
    NSString* routineNSLocalizedString;
    NSString* rootXcodeDirectory;
    NSString* localizableStringsFileName;
}

@property (nonatomic, assign) QOLocalizableStringsController* appController;
@property (nonatomic, copy) NSString* pathOfProject;
@property (nonatomic, copy) NSString* projectName;
@property (nonatomic, copy) NSString* targetOfBuild;
@property (nonatomic, copy) NSString* routineNSLocalizedString;
@property (nonatomic, retain) NSTabView* tabViewXcodeProject;
@property (nonatomic, copy) NSString* rootXcodeDirectory;
@property (nonatomic, copy) NSString* localizableStringsFileName;

- (void) runBuild;
- (void) openBuild;
- (void) saveListModulesToFile;
- (void) parseBuildResult;
- (void) prepareCopyModulesToOtherFolder;
- (void) getListFilesForDeleteInOtherFolder;
- (void) copyModulesToOtherFolder;
- (NSString*) workFolderPath;

@end
