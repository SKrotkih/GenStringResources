//
//  QOProjectTreeViewController.m
//  GenStringResources
//
//  Created by Sergey Krotkih on 21.05.11.
//  Copyright 2011 Quickoffice. All rights reserved.
//

#import "QOProjectTreeViewController.h"
#import "GenStringResourcesController.h"
#import "QOModuleStrings.h"
#import "QOSharedLibrary.h"
#import "QOStringsTableView.h"
#import "TCallScript.h"
#import "CopyingModulesWindowController.h"

@interface QOProjectTreeViewController (QOLocalProjectTreeViewControllerMethods)
- (NSString*) fullPathOfAppleScriptFormatLogFile: (NSString*) aFileName;
@end

@implementation QOProjectTreeViewController

@synthesize appController;
@synthesize pathOfProject;
@synthesize projectName;
@synthesize targetOfBuild;
@synthesize routineNSLocalizedString;
@synthesize tabViewXcodeProject;
@synthesize rootXcodeDirectory;
@synthesize localizableStringsFileName;

- (void)awakeFromNib
{
    appController = [GenStringResourcesController appController];
    treeOutlineView.delegate = self;
    treeOutlineView.parentViewController = self;
    projectTree = [[NSMutableArray alloc] init];
    [textView didLoadNib];    
}

- (void) dealloc
{
    [projectTree release];
    [tabViewXcodeProject release];
    pathOfProject = nil;
    projectName = nil;
    textView= nil;
    treeOutlineView = nil;
    routineNSLocalizedString = nil;
    
	[super dealloc];
}

- (NSString*) workFolderPath
{
    NSString* fillPath = [NSString stringWithFormat: @"%@/%@", rootXcodeDirectory, projectName];
    [QOSharedLibrary createDirectory: fillPath];
    return fillPath;
}

- (NSArray*) parseModule: (NSString*) aModuleFullPath
{
    NSArray* arrResult = nil;
    NSString* tempDirectory = [NSString stringWithFormat: @"%@/Temp", [self workFolderPath]];
    [QOSharedLibrary createDirectory: tempDirectory];    
    NSString* resultFileName = [NSString stringWithFormat: @"%@/Localizable.strings", tempDirectory];
    [QOSharedLibrary deleteFile: resultFileName];
    
    NSString* command = [NSString stringWithFormat: @"genstrings -a -s %@ -o %@ %@", 
                         routineNSLocalizedString,
                         tempDirectory,
                         aModuleFullPath];
    
    const char* cString = [command UTF8String];
    int result = system(cString);    
    if (result != 0) 
    {
        NSLog(@"Couldn't execute the command. Return code is %d", result);
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath: resultFileName] == YES) 
    {
        NSError* error;
        NSString* contentOfFile = [NSString stringWithContentsOfFile: resultFileName
                                                            encoding: NSUTF16StringEncoding 
                                                               error: &error];

        arrResult = [contentOfFile componentsSeparatedByString: @"\n"];        
    }
    NSString* addCommand = [NSString stringWithFormat: @"genstrings -a -s %@ -o %@ %@", 
                         routineNSLocalizedString,
                         [self workFolderPath],
                         aModuleFullPath];
    
    cString = [addCommand UTF8String];
    result = system(cString);    
    if (result != 0) 
    {
        NSLog(@"Can't execute genstrings command. Return code is %d", result);
    }
    
    return arrResult;
}    

- (void) parseBuildResult
{
    [projectTree removeAllObjects]; 
    NSString* buildlog = [NSString stringWithFormat: @"%@/build.log", [self workFolderPath]];
    NSString* errorslog = [NSString stringWithFormat: @"%@/errors.log", [self workFolderPath]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath: buildlog] == YES) 
    {
        NSString* fileStrings = [NSString stringWithFormat: @"%@/Localizable.strings", [self workFolderPath]];
        [QOSharedLibrary deleteFile: fileStrings];
        
        NSError* error = nil;
        NSString* contentOfFile = [NSString stringWithContentsOfFile: buildlog
                                                            encoding: NSUTF8StringEncoding 
                                                               error: &error];
        if (contentOfFile == nil) 
        {
            contentOfFile = [NSString stringWithContentsOfFile: buildlog
                                                      encoding: NSUTF16StringEncoding 
                                                         error: &error];
        }
        if (contentOfFile == nil) 
        {
            NSBeginAlertSheet(NSLocalizedString(@"Error", @"Error"), nil, nil, nil, MAINWINDOW, nil, nil, nil, nil, 
                              NSLocalizedString(@"Can't read file %@.\nReturn code is %d", @"Alert after failed read file with build result."), 
                              buildlog, error);
            return;
        }
        
        NSArray* srcLines = [contentOfFile componentsSeparatedByString: @"\n"];
        NSUInteger linesCount = [srcLines count];
        NSUInteger indexLine = 0;
        
        NSString* dst = @"";
        while (indexLine < linesCount)
        {
            NSString* src = [srcLines objectAtIndex: indexLine];
            
            if ([src hasPrefix: @"CompileC "] || [src hasPrefix: @"Distributed-CompileC "])
            {
                indexLine++;
                while (indexLine < linesCount)
                {
                    src = [srcLines objectAtIndex: indexLine];
                    
                    if ([src length] == 0)
                    {
                        break;
                    }
                    
                    //' -c ...  '
                    NSRange rng = [src rangeOfString: @" -c "];

                    if (rng.location != NSNotFound)
                    {
                        NSString* src2 = [src substringFromIndex: rng.location + 4];
                        NSRange rngNextSpace = [src2 rangeOfString: @" "];
                        NSString* fullModuleName = @"";
                        
                        if ([src2 hasPrefix: @"\""])
                        {
                            NSRange rngNextP = [[src2 substringFromIndex: 1] rangeOfString: @"\""];

                            if (rngNextP.location != NSNotFound)
                            {
                                NSRange rng = {1, rngNextP.location};
                                fullModuleName = [src2 substringWithRange: rng];
                            }
                        }
                        else if (rngNextSpace.location != NSNotFound)
                        {
                            fullModuleName = [src2 substringToIndex: rngNextSpace.location];
                        }

                        if ([fullModuleName length] > 0)
                        {
                            NSArray* localizableStrings = [self parseModule: fullModuleName];
                            QOModuleStrings* obj = [[QOModuleStrings alloc] initWithLocalizableStrings: localizableStrings
                                                                                              inModule: fullModuleName];
                            [projectTree addObject: obj];
                            dst = [dst stringByAppendingString: [obj contentOfOutlioneView]];
                            [obj release];
                        }
                    }

                    indexLine++;
                }
            }
            
            indexLine++;
        }
        
        NSString* dstFile = [NSString stringWithFormat: @"%@/ContentOfTree.txt", [self workFolderPath]];
        error = nil;
        [dst writeToFile: dstFile 
              atomically: YES 
                encoding: NSUTF16StringEncoding 
                   error: &error];
        
        //[projectTree sortUsingSelector: @selector(compare:)];
    }
    else if ([[NSFileManager defaultManager] fileExistsAtPath: errorslog] == YES)
    {
        NSError* error = nil;
        NSString* contentOfFile = [NSString stringWithContentsOfFile: errorslog
                                                            encoding: NSUTF8StringEncoding 
                                                               error: &error];
        if (contentOfFile == nil) 
        {
            contentOfFile = [NSString stringWithContentsOfFile: errorslog
                                                      encoding: NSUTF16StringEncoding 
                                                         error: &error];
        }
        if (contentOfFile == nil) 
        {
            return;
        }

        [textView setString: contentOfFile];
    }
}

-(void) openBuildResult
{
    [projectTree removeAllObjects]; 
    NSString* contentOfTreeFile = [NSString stringWithFormat: @"%@/ContentOfTree.txt", [self workFolderPath]];

    if ([[NSFileManager defaultManager] fileExistsAtPath: contentOfTreeFile] == YES) 
    {
        NSError* error = nil;
        NSString* contentOfFile = [NSString stringWithContentsOfFile: contentOfTreeFile
                                                  encoding: NSUTF16StringEncoding 
                                                     error: &error];
        if (contentOfFile == nil) 
        {
            NSBeginAlertSheet(NSLocalizedString(@"Error", @"Error"), nil, nil, nil, MAINWINDOW, nil, nil, nil, nil, 
                              NSLocalizedString(@"Can't read file %@.\nReturn code is %d", @"Alert after failed read file with content of the source modules tree."), 
                              contentOfTreeFile, error);
            return;
        }
        
        NSArray* arrayOfContent = [contentOfFile componentsSeparatedByString: @"\n"];
        if ([arrayOfContent count] > 0) 
        {
            int i = 0;
            QOModuleStrings* obj;
             while ((obj = [QOModuleStrings createObjectWithContentFromArray: arrayOfContent atIndex: &i]) != nil)
            {
                [projectTree addObject: obj];
            }
        }
    }
}

- (void) buildProjectOnAppleScript
{
    if (pathOfProject == nil || projectName == nil) 
    {
        return;
    }
    
    NSBundle* bundle = [NSBundle mainBundle];
	NSURL* scriptURL = [[NSURL alloc] initFileURLWithPath: [bundle pathForResource: @"buildproject" 
                                                                            ofType: @"scpt"]];
	
    TCallScript* callScript = [[TCallScript alloc] initWithURLToCompiledScript: scriptURL];
    [scriptURL release];
    if (callScript == nil) 
    {
        return;
    }
    
    NSString* buildlog = [self fullPathOfAppleScriptFormatLogFile: @"build"];
    NSString* builderrorslog = [self fullPathOfAppleScriptFormatLogFile: @"errors"];
    NSString* cleanlog = [self fullPathOfAppleScriptFormatLogFile: @"clean"]; 

    NSString* buildConfigurationType = @"Debug";
    NSString* plistPath = [[NSBundle mainBundle] pathForResource: @"xcodebuild" ofType: @"plist"];
	NSMutableArray* arrayContent = [[NSArray arrayWithContentsOfFile: plistPath] mutableCopy];
    NSEnumerator* arrayContentEnumerator = [arrayContent objectEnumerator];
    NSDictionary* xcodebuildAttributes;
    while ((xcodebuildAttributes = [arrayContentEnumerator nextObject])) 
    {
        if ([[xcodebuildAttributes objectForKey: @"target"] isEqual: projectName]) 
        {
            buildConfigurationType = [xcodebuildAttributes objectForKey: @"configuration"];
        }
    }            
    [arrayContent release];    
    
    NSLog(@"%@\n%@\n%@\n%@\n%@\n%@", pathOfProject, projectName, cleanlog, buildlog, builderrorslog, buildConfigurationType);
    
    [callScript callHandler: @"runBuildProject" withParameters: pathOfProject, projectName, cleanlog, buildlog, builderrorslog, buildConfigurationType, nil];
    [callScript release];
}

- (void) buildProjectOnXcodebuild
{
    if (pathOfProject == nil || projectName == nil) 
    {
        return;
    }
    
    NSString* target = targetOfBuild;
    NSString* plistPath = [[NSBundle mainBundle] pathForResource: @"xcodebuild" 
                                                          ofType: @"plist"];
	NSMutableArray* arrayContent = [[NSArray arrayWithContentsOfFile: plistPath] mutableCopy];
    NSEnumerator* arrayContentEnumerator = [arrayContent objectEnumerator];
    NSDictionary* xcodebuildAttributes;
    NSString* configurationType = @"Debug"; // by default
    NSString* sdk = @"iphoneos6.1";         // by default
    //NSString* configurationType = @"Development";
    //NSString* sdk = @"macosx10.7";

    while ((xcodebuildAttributes = [arrayContentEnumerator nextObject])) 
    {
        if ([[xcodebuildAttributes objectForKey: @"target"] isEqual: target]) 
        {
            configurationType = [xcodebuildAttributes objectForKey: @"configuration"];
            sdk = [xcodebuildAttributes objectForKey: @"sdk"];
        }
    }            
    [arrayContent release];    

    NSString* currentPath = [[NSFileManager defaultManager] currentDirectoryPath];
    NSArray* foldersCurrPath = [[currentPath substringFromIndex: 1] componentsSeparatedByString: @"/"];
    NSArray* foldersProjPath = [pathOfProject componentsSeparatedByString: @":"];
    NSUInteger len = [foldersCurrPath count];
    NSUInteger len2 = [foldersProjPath count];
    NSMutableArray* mutablePath = [NSMutableArray arrayWithCapacity: 0];
    NSInteger ind2 = -1;
    
    for (NSUInteger i = 0; i < len; i++)
    {
        if (i < len2)
        {
            if ([[foldersCurrPath objectAtIndex: i] isEqualToString: [foldersProjPath objectAtIndex: i]])
            {
                continue;
            }

            if (ind2 == -1)
            {
                ind2 = i;
            }
        }

        [mutablePath addObject: @".."];
    }
    
    for (NSUInteger i = ind2; i < len2; i++)
    {
        [mutablePath addObject: [foldersProjPath objectAtIndex: i]];
    }

    NSString* project = [NSString pathWithComponents: mutablePath];
    NSString* buildOptions = [NSString stringWithFormat: @"SYMROOT=%@/BIN_BUILD", [self workFolderPath]];
    NSString* log = [NSString stringWithFormat: @"%@/build.log", [self workFolderPath]];

    //#!/bin/bash
    //xcodebuild -target Quicksheet -configuration Debug -sdk iphoneos6.0 -project ../../Development/Quickoffcie_iOS_2_0/Quicksheet/IPH_QSH_App/prj/Quicksheet.xcodeproj build SYMROOT=/Users/oldman/Development/SA_BUILD > ./build.log
    NSString* commandLine = [NSString stringWithFormat: @"xcodebuild -target %@ -configuration %@ -sdk %@ -project %@ build %@ > %@", 
                             target,
                             configurationType,
                             sdk,
                             project,
                             buildOptions,
                             log];
    

    NSLog(@"\n\n%@\n\n", commandLine);

    NSLog(@"%@\n%@\n%@\n%@\n%@\n%@",
          target,
          configurationType,
          sdk,
          project,
          buildOptions,
          log);
    
    const char* cString = [commandLine UTF8String];
    int result = system(cString);    
    if (result != 0) 
    {
        NSBeginAlertSheet(NSLocalizedString(@"Error", @"Error"), nil, nil, nil, MAINWINDOW, nil, nil, nil, nil, 
                          NSLocalizedString(@"Can't execute xcodebuild command. Return code is %d", @"Alert failed result of call xcodebuild."), 
                          result);
        
    }
    
}

- (NSString*) fullPathOfAppleScriptFormatLogFile: (NSString*) aFileName
{
    NSString* fullFileName = [NSString stringWithFormat: @"%@/%@.log", [self workFolderPath], aFileName];
    fullFileName = [fullFileName stringByReplacingOccurrencesOfString: @"/" 
                                                           withString: @":"];
    fullFileName = [fullFileName substringFromIndex: 1];            
    return fullFileName;
}

- (void) addLocalizableStringsTab
{
    NSString* fileName = @"Localizable.strings";
    
    localizableStringsFileName = [NSString stringWithFormat: @"%@/%@", [self workFolderPath], fileName];
    [QOSharedLibrary orderingOnKeyStringsDataInFile: localizableStringsFileName];
    // second time call method for remove extra comments:
    [QOSharedLibrary orderingOnKeyStringsDataInFile: localizableStringsFileName];        
    
    QOStringsTableView* scrollViewLngOrg = [[QOStringsTableView alloc] initWithFile: localizableStringsFileName 
                                                                           encoding: NSUTF16StringEncoding
                                                                        projectName: projectName
                                                                                lng: @"en"];
    scrollViewLngOrg.typeFile = TYPE_DATA_ORG;
    scrollViewLngOrg.sourceFile = localizableStringsFileName;
    
    NSTabViewItem* tabViewItemXcodeFiles = nil;
    int tabViewCount = [tabViewXcodeProject numberOfTabViewItems];
    for (int tabViewItemIndex = (tabViewCount - 1); tabViewItemIndex >= 0; tabViewItemIndex--)
    {
        NSTabViewItem* currTabViewItem = [tabViewXcodeProject tabViewItemAtIndex: tabViewItemIndex]; 
        if ([[currTabViewItem label] isEqualToString: fileName] == YES) 
        {
            tabViewItemXcodeFiles = currTabViewItem;
        }
    }
    if (tabViewItemXcodeFiles == nil) 
    {
        NSTabViewItem* tabViewItemXcodeFiles = [[NSTabViewItem alloc] init];
        [tabViewItemXcodeFiles setLabel: fileName];
        [tabViewItemXcodeFiles setView: scrollViewLngOrg];
        [scrollViewLngOrg release];
        
        [tabViewXcodeProject addTabViewItem: tabViewItemXcodeFiles];
        [tabViewItemXcodeFiles release];
    }
    else 
    {
        [tabViewItemXcodeFiles setView: scrollViewLngOrg];
        [scrollViewLngOrg release];
    }
}

#pragma mark Context menu items handling

- (void) runBuild
{
    
    // TODO: I don't know but it isn't working now. I should fix it!
    //[self buildProjectOnAppleScript];
    
    [self buildProjectOnXcodebuild];
    
    [self parseBuildResult];

    [treeOutlineView reloadData];
    
    [treeOutlineView expandItem: projectTree];
    
    [self addLocalizableStringsTab];
}

- (void) openBuild
{
    [self openBuildResult];
    
    [treeOutlineView reloadData];
    
    [treeOutlineView expandItem: projectTree];

    [self addLocalizableStringsTab];
}


- (void) saveListModulesToFile
{
    NSSavePanel* savePanel = [NSSavePanel savePanel];
    [savePanel setTreatsFilePackagesAsDirectories: NO];
    [savePanel beginSheetModalForWindow: MAINWINDOW completionHandler: ^(NSInteger result) 
     {
         if (result == NSOKButton) 
         {
             [savePanel orderOut: self];
             NSString* fileName = [[savePanel URL] absoluteString];
             
             NSEnumerator* srcStream = [projectTree objectEnumerator];    
             NSString* src;
             NSString* dst = @"";
             while ((src = [srcStream nextObject]) != nil)
             {
                 dst = [dst stringByAppendingString: [src description]];
                 dst = [dst stringByAppendingString: @"\n"];
             }
             
             NSError* error = nil;
             [dst writeToFile: fileName
                    atomically: YES 
                      encoding: NSUTF16StringEncoding 
                         error: &error];
             if (error != nil) 
             {
                 NSBeginAlertSheet(@"Error", nil, nil, nil, MAINWINDOW, nil, nil, nil, nil, 
                                   @"Error '%@' while save to file\n%@!", [error description], fileName);
             }
             else
             {
                 NSBeginAlertSheet(@"Saved data is OK", nil, nil, nil, MAINWINDOW, nil, nil, nil, nil,
                                   @"List of moduls saved to file\n%@!", fileName);
             }
         }
     }];
}

- (void) copyModulesToOtherFolder
{
    CopyingModulesWindowController* controller = [[CopyingModulesWindowController alloc] initWithModulesTreeAray: projectTree
                                                                                                       operation: COPY
                                                                                                           title: @"Save modules to other folder"];
    [controller showWindow: self];
    [[NSApplication sharedApplication] runModalForWindow: [controller window]];
    [controller release];
}

- (void) prepareCopyModulesToOtherFolder
{
    CopyingModulesWindowController* controller = [[CopyingModulesWindowController alloc] initWithModulesTreeAray: projectTree
                                                                                                       operation: PREPARE
                                                                                                           title: @"Prepare copying modules to other folder"];
    [controller showWindow: self];
    [[NSApplication sharedApplication] runModalForWindow: [controller window]];
    [controller release];
}

- (void) getListFilesForDeleteInOtherFolder
{
    CopyingModulesWindowController* controller = [[CopyingModulesWindowController alloc] initWithModulesTreeAray: projectTree
                                                                                                       operation: FOR_DELETE
                                                                                                           title: @"Get lis files for delete in other folder"];
    [controller showWindow: self];
    [[NSApplication sharedApplication] runModalForWindow: [controller window]];
    [controller release];
}


#pragma mark Select row handling

- (void)outlineViewSelectionIsChanging: (NSNotification *) notification
{
    NSInteger selectedRow = [treeOutlineView selectedRow];
    if (selectedRow > 0) 
    {
        id selectedItem = [treeOutlineView itemAtRow: selectedRow];
        id parentItem = [treeOutlineView parentForItem: selectedItem];
        // Name of module level 
        if (parentItem == projectTree) 
        {
            NSString* modulePath = [selectedItem description];
            NSError* error;
            NSString* contentOfFile = [NSString stringWithContentsOfFile: modulePath
                                                                encoding: NSUTF8StringEncoding 
                                                                   error: &error];
            if (contentOfFile == nil)
            {
                [textView setString: [NSString stringWithFormat: @"error: %@", error]];
            }
            else
            {
                [textView setString: contentOfFile];
            }
        }
        else
        {
            NSString* selectedString = [selectedItem description];
            NSArray* keyValue = [selectedString componentsSeparatedByString: @" = "];
            if ([keyValue count] == 2) 
            {
                [textView searchString: [keyValue objectAtIndex: 0]];
            }    
        }
    }
}

#pragma mark NSOutlineViewDelegate protocol handle

- (id)outlineView: (NSOutlineView *) outlineView
            child: (NSInteger) index
           ofItem: (id) item
{
	if( !item )
		return projectTree;
	
	return [((NSArray*)item) objectAtIndex: index];
}

- (BOOL)outlineView: (NSOutlineView *) outlineView isItemExpandable: (id) item
{
	if( item == projectTree || item == nil )
		return YES;
    
    NSInteger countOfChildren = 0;
	if ([item respondsToSelector: @selector(count)]) 
    {
        countOfChildren = [((NSArray*)item) count]; 
    }

    return countOfChildren > 0;
}

- (NSInteger) outlineView: (NSOutlineView *)outlineView
   numberOfChildrenOfItem: (id)item
{
	if( item == self || item == nil )
		return 1;
	
    NSInteger countOfChildren = 0;
	if ([item respondsToSelector: @selector(count)]) 
    {
        countOfChildren = [((NSArray*)item) count]; 
    }
    
    return countOfChildren;
}

- (id)outlineView: (NSOutlineView *)outlineView objectValueForTableColumn: (NSTableColumn *)tableColumn byItem: (id)item
{
	NSString* textOfOutlineViewItem = nil;
	
	if ( item == projectTree ) 
    {
		textOfOutlineViewItem = projectName;        
    }
    else  if( [item respondsToSelector: @selector(description)] )
    {
		textOfOutlineViewItem = [item description];
    }
	
	if( !textOfOutlineViewItem )
		textOfOutlineViewItem = @"-";
    
	return textOfOutlineViewItem;
}

// The delegate can modify cell to alter its display attributes; for example, making uneditable values display in italic or gray text.
- (void)outlineView: (NSOutlineView *)outlineView willDisplayCell: (id)cell forTableColumn: (NSTableColumn *)tableColumn item: (id)item
{
    
}

#pragma mark -

@end
