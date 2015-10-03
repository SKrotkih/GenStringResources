//  GenStringResources
//
//  QOLocalizableXIBStrings.m
//
//  Created by Sergey Krotkih on 08.03.11.
//  Copyright 2011 Quickoffice. All rights reserved.
//

#import "QOLocalizableXIBStrings.h"
#import "QOXIBTableView.h"
#import "GenStringResourcesController.h"
#import "QOSharedLibrary.h"
#import "QOPlistProcessing.h"
#import "QOSettingsController.h"

static NSString* const XIBS_TITLE = @"XIBs";

@implementation QOLocalizableXIBStrings

@synthesize appController;

+ (QOLocalizableXIBStrings*) sharedInstance
{
    static QOLocalizableXIBStrings* instance;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        instance = [[QOLocalizableXIBStrings alloc] init];
        instance.appController = [GenStringResourcesController appController];
    });
    
    return instance;
}

- (void) dealloc
{
    
	[super dealloc];
}

- (void)alertDidEnd: (NSAlert* )alert returnCode: (NSInteger)returnCode contextInfo: (void* )contextInfo 
{
    if ([(NSString*)contextInfo isEqualToString: @"Error in settings"] == YES) 
    {
        QOSettingsController* settings = [[QOSettingsController alloc] initWithWindowNibName: @"SettingsWindow"];
        [[NSApplication sharedApplication] runModalForWindow: [settings window]];
        [settings release];
    }
}

- (void) runCommand: (NSString*) aCommand
{
    const char* cString = [aCommand UTF8String];
    int result = system(cString);    
    
    if (result != 0) 
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSBeginAlertSheet(NSLocalizedString(@"Error", @"Error"), nil, nil, nil, MAINWINDOW, nil, nil, nil, nil,
                              NSLocalizedString(@"Couldn't execute the command. Return code is %d", @"Couldn't execute the command. Return code is %d"), result);
        });
    }
}

-(void) saveDictionaryToLocalizableStringsFileForPath: (NSString*) aResultProjectLprojPath dictionary: (NSMutableDictionary*) aDictionary
{
    NSString* localizableStringsFile = [NSString stringWithFormat: @"%@/Localizable.strings", aResultProjectLprojPath];
    if ([[NSFileManager defaultManager] fileExistsAtPath: localizableStringsFile] == YES)
    {
        NSError* error;
        [[NSFileManager defaultManager] removeItemAtPath: localizableStringsFile 
                                                   error: &error];
    }
    if (aDictionary != nil) 
    {
        NSString* text = @"";    
        for (id key in aDictionary) 
        {
            text = [text stringByAppendingString: [NSString stringWithFormat: @"\n\n/*%@*/\n", key]];
            NSString* value = [aDictionary objectForKey: key];
            text = [text stringByAppendingString: [NSString stringWithFormat: @"%@ = \"\";", [value stringByReplacingOccurrencesOfString: @";" 
                                                                                                                              withString: @""]]];
        }
        if ([text isEqualToString: @""] == NO) 
        {
            NSError* error = nil;
            [text writeToFile: localizableStringsFile 
                   atomically: YES 
                     encoding: NSUTF16StringEncoding 
                        error: &error];	          
            
            [QOSharedLibrary orderingOnKeyStringsDataInFile: localizableStringsFile];
        }
    }
}

-(BOOL) isParseLngLprojPath: (NSString*) aLprojPath toWorkProjectPath: (NSString*) aWorkProjectPath toDictionary: (NSMutableDictionary**)dictionaryStrings
{
    if ([[NSFileManager defaultManager] fileExistsAtPath: aLprojPath] == NO)    
    {
        return NO;
    }
    NSArray* pathCpomponents = [aLprojPath pathComponents];
    NSString* lProjName = [pathCpomponents objectAtIndex: [pathCpomponents count] - 1];
    
    NSString* resultProjectLprojPath = [NSString stringWithFormat: @"%@/%@", aWorkProjectPath, lProjName];    
    [QOSharedLibrary createDirectory: resultProjectLprojPath];
    NSArray* filelist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: aLprojPath 
                                                                            error: NULL];
    int xibFilesCount = [filelist count];
    int xibFileItemIndex;
    for (xibFileItemIndex = 0; xibFileItemIndex < xibFilesCount; xibFileItemIndex++)
    {
        NSString* currentXIBfile = [filelist objectAtIndex: xibFileItemIndex];
        if ([[currentXIBfile pathExtension] isEqualToString: @"xib"] == YES) 
        {
            NSString* resultFileStringsPath = [NSString stringWithFormat: @"%@/%@.strings", resultProjectLprojPath, currentXIBfile];
            NSString* fileXIBpath = [NSString stringWithFormat: @"%@/%@", aLprojPath, currentXIBfile];

#pragma mark RUN IBTOOL --EXPORT-STRINGS-FILE             
            
            NSString* command = [NSString stringWithFormat: @"ibtool --export-strings-file %@ %@", 
                                 resultFileStringsPath,
                                 fileXIBpath];
            [self runCommand: command];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath: resultFileStringsPath] == YES)
            {
                NSError* error = nil;
                NSString* content = [NSString stringWithContentsOfFile: resultFileStringsPath 
                                                              encoding: NSUTF16StringEncoding 
                                                                 error: &error];
                
                NSArray* srcLines = [content componentsSeparatedByString: @"\n"];
                NSEnumerator* srcStream = [srcLines objectEnumerator];    
                NSString* str;
                while ((str = [srcStream nextObject]) != nil) 
                {
                    NSMutableString* key;
                    NSMutableString* value;
                    if ([QOSharedLibrary parseStringToKeyAndValue: str 
                                                           getKey: &key 
                                                         getValue: &value] == YES) 
                    {
                        [*dictionaryStrings setObject: value forKey: [NSString stringWithFormat: @"%@:%@", currentXIBfile, key]];
                    }
                }
            }
        }
    }
    
    return YES;
}

- (void) parseProjectXIBDirectory: (NSString*) aXIBDir resultProjectPath: (NSString*) aResultProjectPath
{
    NSMutableDictionary* englishDictionary = [[NSMutableDictionary alloc] init];
    if ([self isParseLngLprojPath: [NSString stringWithFormat: @"%@/en.lproj", aXIBDir]
                toWorkProjectPath: aResultProjectPath
                     toDictionary: &englishDictionary] == NO) 
    {
        return;
    }

    NSArray* filelist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: aXIBDir 
                                                                            error: NULL];
    int dirItemsIndex;
    int dirItemsCount = [filelist count];
    for (dirItemsIndex = 0; dirItemsIndex < dirItemsCount; dirItemsIndex++)
    {
        NSString* lprojDirName = [filelist objectAtIndex: dirItemsIndex];
        NSString* currentXIBdir = [NSString stringWithFormat: @"%@/%@", aXIBDir, lprojDirName];
        if ([QOSharedLibrary isDirectory: currentXIBdir] == YES && [[lprojDirName pathExtension] isEqualToString: @"lproj"] == YES) 
        {
            NSString* lng = [lprojDirName substringToIndex: [lprojDirName rangeOfString: @"."].location];
            NSString* resultProjectLprojPath = [NSString stringWithFormat: @"%@/%@", aResultProjectPath, lprojDirName];    
            [QOSharedLibrary createDirectory: resultProjectLprojPath];
            currentXIBdir = [currentXIBdir stringByAppendingString: @"/"];                
            if ([lng isEqualToString: @"en"] == NO) 
            {
                NSMutableDictionary* lngDictionary = [[NSMutableDictionary alloc] init];
                if ([self isParseLngLprojPath: currentXIBdir
                            toWorkProjectPath: resultProjectLprojPath
                                 toDictionary: &lngDictionary] == NO) 
                {
                    continue;
                }
                NSMutableDictionary* noTranslateDictionary = [[NSMutableDictionary alloc] init];
                for (id xibNameFileAndControlsId in lngDictionary) 
                {
                    NSString* englishValue = [englishDictionary objectForKey: xibNameFileAndControlsId];
                    NSString* lngValue = [lngDictionary objectForKey: xibNameFileAndControlsId];
                    if ([englishValue isEqualToString: lngValue] == YES) 
                    {
                        [noTranslateDictionary setObject: lngValue forKey: xibNameFileAndControlsId];
                    }
                }
                [self saveDictionaryToLocalizableStringsFileForPath: resultProjectLprojPath 
                                                         dictionary: noTranslateDictionary];
                [noTranslateDictionary release];
                [lngDictionary release];
            }
        }
    }
    NSString* resultProjectLprojPath = [NSString stringWithFormat: @"%@/en.lproj", aResultProjectPath];    
    [self saveDictionaryToLocalizableStringsFileForPath: resultProjectLprojPath
                                             dictionary: englishDictionary];
    [englishDictionary release];
}


-(void) removeTabViewItemForName: (NSString*) aName tabView: (NSTabView*)aTabView
{
    int tabViewCount = [aTabView numberOfTabViewItems];
    int tabViewItemIndex;
    for (tabViewItemIndex = (tabViewCount - 1); tabViewItemIndex >= 0; tabViewItemIndex--)
    {
        NSTabViewItem* tabViewItem = [aTabView tabViewItemAtIndex: tabViewItemIndex]; 
        if ([[tabViewItem label] isEqualToString: aName] == YES) 
        {
            [aTabView removeTabViewItem: tabViewItem];
        }
    }
}

- (void) scanThread
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init]; 
    
    NSDictionary* plistProjects = nil;
    if ([QOPlistProcessing getPlistProject: &plistProjects 
                                    window: MAINWINDOW] == NO) 
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSBeginAlertSheet(NSLocalizedString(@"Warning!", @"Warning!"), nil, nil, nil,
                              MAINWINDOW,
                              self,
                              @selector(alertDidEnd:returnCode:contextInfo:),
                              nil,
                              @"Error in settings",
                              NSLocalizedString(@"Wrong directory path to the project in the settings. Please check data.", @"Wrong directory path to the project in the settings. Please check data."));
            [appController enableToolbar: YES];
        });
        
        [pool release];
        
        return;
    }
    [appController.progressBar startAnimation: self];
    
    NSTabView* tabView = appController.tabView;
    [self removeTabViewItemForName: XIBS_TITLE 
                           tabView: tabView];
    
    NSString* rootResultDirectory = [QOPlistProcessing workDirectory];        
    rootResultDirectory = [rootResultDirectory stringByAppendingString: [NSString stringWithFormat: @"/%@", XIBS_TITLE]];
    [[NSFileManager defaultManager] removeItemAtPath: rootResultDirectory error: nil];
    [QOSharedLibrary createDirectory: rootResultDirectory];
    rootResultDirectory = [rootResultDirectory stringByAppendingString: @"/"];
    
    NSTabViewItem* tabViewItemMain = [[NSTabViewItem alloc] init];
    [tabViewItemMain setLabel: XIBS_TITLE];
    [tabView addTabViewItem: tabViewItemMain];
    
    NSTabView* tabViewMain = [[NSTabView alloc] init];
    [tabViewMain setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
    [tabViewItemMain setView: tabViewMain];
    
    NSEnumerator* projectsPListEnumerator = [plistProjects objectEnumerator];
    NSDictionary* projectPListItem;
    while ((projectPListItem = [projectsPListEnumerator nextObject]) != nil)
    {
        NSString* projectRootDirectoryXIBPath = [projectPListItem objectForKey: @"XIBsPath"]; 
        BOOL enable = [[projectPListItem objectForKey: @"enable"] boolValue];
        if (projectRootDirectoryXIBPath == nil || [projectRootDirectoryXIBPath length] == 0 || enable == NO) 
        {
            continue;
        }
        
        NSString* projectName = [projectPListItem objectForKey: @"name"]; 
        NSString* projectResultsDirectory = [rootResultDirectory stringByAppendingString: projectName];
        [QOSharedLibrary createDirectory: projectResultsDirectory];

#pragma mark Create tab for Project
        
        NSTabViewItem* tabViewItem = [[NSTabViewItem alloc] init];
        [tabViewItem setLabel: projectName];
        [tabViewMain addTabViewItem: tabViewItem];
        
        NSTabView* tabViewProject = [[NSTabView alloc] init];
        [tabViewProject setAutoresizingMask: (NSViewWidthSizable | NSViewHeightSizable)];
        [tabViewItem setView: tabViewProject];

#pragma mark Parse XIB-directory
        
        [self parseProjectXIBDirectory: projectRootDirectoryXIBPath 
                     resultProjectPath: projectResultsDirectory];

        NSArray* filelist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: projectRootDirectoryXIBPath 
                                                                                error: NULL];
        int dirItemsIndex;
        int dirItemsCount = [filelist count];
        for (dirItemsIndex = 0; dirItemsIndex < dirItemsCount; dirItemsIndex++)
        {
            NSString* lprojDirName = [filelist objectAtIndex: dirItemsIndex];
            NSString* currentXIBdir = [NSString stringWithFormat: @"%@/%@", projectRootDirectoryXIBPath, lprojDirName];
            if ([QOSharedLibrary isDirectory: currentXIBdir] == YES) 
            {
                if ([[lprojDirName pathExtension] isEqualToString: @"lproj"] == YES) 
                {
                    NSString* fileWithPathXIBFile = [NSString stringWithFormat: @"%@/%@/sourcepath.txt", projectResultsDirectory, lprojDirName];
                    NSError* error = nil;
                    [currentXIBdir writeToFile: fileWithPathXIBFile atomically: YES 
                                          encoding: NSUTF16StringEncoding 
                                             error: &error];
                    NSString* lng = [lprojDirName substringToIndex: [lprojDirName rangeOfString: @"."].location];
                    NSString* localizableStringsFileName = [NSString stringWithFormat: @"%@/%@/Localizable.strings", projectResultsDirectory, lprojDirName];    
                    if ([[NSFileManager defaultManager] fileExistsAtPath: localizableStringsFileName] == YES)
                    {
                        QOXIBTableView* scrollView = [[QOXIBTableView alloc] initWithFile: localizableStringsFileName 
                                                                                                       encoding: NSUTF16StringEncoding
                                                                                                    projectName: projectName
                                                                                                            lng: lng];
                        scrollView.typeFile = TYPE_DATA_NEW;
                        scrollView.sourceFile = localizableStringsFileName;
                        scrollView.targetFile = currentXIBdir;
                        
                        NSTabViewItem* tabViewItemOrgStrings = [[NSTabViewItem alloc] init];
                        [tabViewItemOrgStrings setLabel: lng];
                        
                        [tabViewItemOrgStrings setView: scrollView];
                        [scrollView release];
                        
                        [tabViewProject addTabViewItem: tabViewItemOrgStrings];
                        [tabViewItemOrgStrings release];
                    }
                }
            }
        }
        [tabViewItem release];
        [tabViewProject release];
    }        
    [tabViewItemMain release];
    [tabViewMain release];

    
    [appController.progressBar stopAnimation: self];
    [appController enableToolbar: YES];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSBeginAlertSheet(NSLocalizedString(@"Scan data has finished successfully", @"Scan data has finished successfully"), nil, nil, nil, MAINWINDOW, nil, nil, nil, nil,
                          NSLocalizedString(@"No issues", @"No issues"));
    });
    
    [plistProjects release];
    [pool release];
}

- (void) openStringsThread
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init]; 

    NSString* rootResultDirectory = [QOPlistProcessing workDirectory];
    rootResultDirectory = [rootResultDirectory stringByAppendingString: [NSString stringWithFormat: @"/%@", XIBS_TITLE]];    
    if ([[NSFileManager defaultManager] fileExistsAtPath: rootResultDirectory] == NO)
    {
        [appController enableToolbar: YES];

        dispatch_async(dispatch_get_main_queue(), ^{
            NSBeginAlertSheet(NSLocalizedString(@"Couldn't find data", @"Couldn't find data"), nil, nil, nil, MAINWINDOW, nil, nil, nil, nil,
                              NSLocalizedString(@"Please start the process of the XIBs scanning", @"Please start the process of the XIBs scanning"));
        });

        [pool release];
        return;    
    }
    rootResultDirectory = [rootResultDirectory stringByAppendingString: @"/"];
                           
    [appController.progressBar startAnimation: self];
    
    NSTabView* tabView = appController.tabView;
    [self removeTabViewItemForName: XIBS_TITLE 
                           tabView: tabView];
    
    NSTabViewItem* tabViewItemMain = [[NSTabViewItem alloc] init];
    [tabViewItemMain setLabel: XIBS_TITLE];
    [tabView addTabViewItem: tabViewItemMain];
    
    NSTabView* tabViewMain = [[NSTabView alloc] init];
    [tabViewMain setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
    [tabViewItemMain setView: tabViewMain];
    
    
    NSArray* filelist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: rootResultDirectory 
                                                                            error: NULL];
    int dirItemsIndex;
    int dirItemsCount = [filelist count];
    for (dirItemsIndex = 0; dirItemsIndex < dirItemsCount; dirItemsIndex++)
    {
        NSString* projectName = [filelist objectAtIndex: dirItemsIndex];
        NSString* projectResultsDirectory = [rootResultDirectory stringByAppendingString: projectName];
        
        NSTabViewItem* tabViewItem = [[NSTabViewItem alloc] init];
        [tabViewItem setLabel: projectName];
        [tabViewMain addTabViewItem: tabViewItem];
        
        NSTabView* tabViewProject = [[NSTabView alloc] init];
        [tabViewProject setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
        [tabViewItem setView: tabViewProject];
        
        NSArray* projectfilelist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: projectResultsDirectory 
                                                                                       error: NULL];
        int projectDirItemsIndex;
        int progectDirItemsCount = [projectfilelist count];
        for (projectDirItemsIndex = 0; projectDirItemsIndex < progectDirItemsCount; projectDirItemsIndex++)
        {
            NSString* lprojDirName = [projectfilelist objectAtIndex: projectDirItemsIndex];
            if ([[lprojDirName pathExtension] isEqualToString: @"lproj"] == YES) 
            {
                NSString* lng = [lprojDirName substringToIndex: [lprojDirName rangeOfString: @"."].location];
                NSString* localizableStringsFileName = [NSString stringWithFormat: @"%@/%@/Localizable.strings", projectResultsDirectory, lprojDirName];    
                if ([[NSFileManager defaultManager] fileExistsAtPath: localizableStringsFileName] == YES)
                {
                    QOXIBTableView* scrollView = [[QOXIBTableView alloc] initWithFile: localizableStringsFileName
                                                                                                   encoding: NSUTF16StringEncoding
                                                                                                projectName: projectName
                                                                                                        lng: lng];
                    
                    NSString* fileWithPathXIB = [NSString stringWithFormat: @"%@/%@/sourcepath.txt", projectResultsDirectory, lprojDirName];
                    NSError* error = nil;
                    NSString* pathToXIBfile = [NSString stringWithContentsOfFile: fileWithPathXIB
                                                                        encoding: NSUTF16StringEncoding 
                                                                           error: &error];
                    
                    scrollView.typeFile = TYPE_DATA_NEW;
                    scrollView.sourceFile = localizableStringsFileName;
                    scrollView.targetFile = pathToXIBfile;
                    
                    NSTabViewItem* tabViewItemOrgStrings = [[NSTabViewItem alloc] init];
                    [tabViewItemOrgStrings setLabel: lng];
                    
                    [tabViewItemOrgStrings setView: scrollView];
                    [scrollView release];
                    
                    [tabViewProject addTabViewItem: tabViewItemOrgStrings];
                    [tabViewItemOrgStrings release];
                }
            }
        }
        [tabViewProject release];
        [tabViewItem release];
    } 
    [tabViewItemMain release];
    [tabViewMain release];    
    
    [appController.progressBar stopAnimation: self];
    [appController enableToolbar: YES];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSBeginAlertSheet(NSLocalizedString(@"Scan data has finished successfully", @"Scan data has finished successfully"), nil, nil, nil, MAINWINDOW, nil, nil, nil, nil,
                          NSLocalizedString(@"No issues", @"No issues"));
    });
    
    [pool release];
}

- (void) startScan
{
    [appController enableToolbar: NO];
    if (thread != nil) 
    {
        [thread cancel];
        [thread release];
    }
    thread = [[NSThread alloc] initWithTarget: self
                                     selector: @selector(scanThread)
                                       object: nil];
    [thread start];
}

- (void) openProject
{
    [appController enableToolbar: NO];
    if (thread != nil) 
    {
        [thread cancel];
        [thread release];
    }
    thread = [[NSThread alloc] initWithTarget: self
                                     selector: @selector(openStringsThread)
                                       object: nil];
    [thread start];
}

@end
