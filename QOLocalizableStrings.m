//  QOLocalizableStrings
//
//  QOLocalizableStrings.m
//
//  Created by Sergey Krotkih on 08.03.11.
//  Copyright 2011 Quickoffice. All rights reserved.
//

#import "QOLocalizableStrings.h"
#import "QOLocalizableStringsController.h"
#import "QOSettingsController.h"
#import "QOSharedLibrary.h"
#import "QOStringsTableView.h"
#import "QOPlistProcessing.h"
#import "QOProjectTreeViewController.h"

static NSString* const STRINGS_TITLE = @"Strings";
static NSString* const MODULES_TITLE = @"Modules";


@interface QOLocalizableStrings ()
- (void) scanStringsThread;
- (void) scanModulesThread;
- (void) openStringsThread;
- (void) openProjectModulesThread;
- (void) addXcodeTabsForLngDistribution: (NSTabView*) tabViewXcodeProject
             localizableStringsFileName: (NSString*) aLocalizableStringsFileName
                         workFolderPath: (NSString*) aWorkFolderPath;
- (NSString*) rootWorkFolderForTabName: (NSString*) aTabName withClean: (BOOL) aClean;
@end

@implementation QOLocalizableStrings

@synthesize appController, scanQueue;

+ (QOLocalizableStrings* ) sharedLocalizableStrings
{
	static QOLocalizableStrings*  _sharedLocalizableStrings = nil;
	
	if (_sharedLocalizableStrings == nil)
	{
		_sharedLocalizableStrings = [[QOLocalizableStrings alloc] init];
        _sharedLocalizableStrings.scanQueue = [[NSOperationQueue alloc] init];
        _sharedLocalizableStrings.scanQueue.name = @"ScanOfLocalizableStrings";
        _sharedLocalizableStrings.scanQueue.MaxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
        _sharedLocalizableStrings.appController = [QOLocalizableStringsController appController];
	}
	
	return _sharedLocalizableStrings;
}

- (void) dealloc
{
    [scanQueue cancelAllOperations];
    [scanQueue release];
    scanQueue = nil;
    [thread release];
    
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

#pragma mark -

- (void) runCommand: (NSString*) aCommand
{
    const char* cString = [aCommand UTF8String];
    
#pragma mark Run command genstrings
    
    int result = system(cString);
    
    if (result != 0)
    {
        NSBeginAlertSheet(NSLocalizedString(@"Error", @"Error"), nil, nil, nil, MAINWINDOW, nil, nil, nil, nil,
                          NSLocalizedString(@"Can't execute command. Return code is %d", @"Can't execute command. Return code is %d"), result);
    }
}

- (void) parseDirectory: (NSString*) aSourcesDir
        resultDirectory: (NSString*) aRootResultDirectory
routineNSLocalizedString: (NSString*) aRoutineNSLocalizedString
             extensions: (NSArray*) aListOfExtensions
            projectName: (NSString*) aProjectName
{
    int count, lengthOfListExtesions;
    int i, extensionIndex;
    
    lengthOfListExtesions = [aListOfExtensions count];
    for (extensionIndex = 0; extensionIndex < lengthOfListExtesions; extensionIndex++)
    {
        NSString* command = [NSString stringWithFormat: @"genstrings -a -s %@ -o %@ %@/*.%@",
                             aRoutineNSLocalizedString,
                             aRootResultDirectory,
                             aSourcesDir,
                             [aListOfExtensions objectAtIndex: extensionIndex]];
        
        [self runCommand: command];
    }
    
    NSString* dir = [NSString stringWithFormat: @"%@/", aSourcesDir];
    NSArray* filelist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: dir error: NULL];
    count = [filelist count];
    for (i = 0; i < count; i++)
    {
        NSString* currentDir = [NSString stringWithFormat: @"%@%@", dir, [filelist objectAtIndex: i]];
        if ([[currentDir pathExtension] isEqualToString: @"xcodeproj"] == YES)
        {
            NSString* pathsOfXcodeproj = [NSString stringWithFormat: @"%@/%@/xcodeproj.txt", [self rootWorkFolderForTabName: STRINGS_TITLE withClean: NO], aProjectName];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath: pathsOfXcodeproj] == NO)
            {
                [QOSharedLibrary createDirectoryForFullFilePath: pathsOfXcodeproj];
                [[NSFileManager defaultManager] createFileAtPath: pathsOfXcodeproj contents: nil attributes: nil];
            }
            NSFileHandle* outputHandle = [NSFileHandle fileHandleForWritingAtPath: pathsOfXcodeproj];
            [outputHandle seekToEndOfFile];
            currentDir = [NSString stringWithFormat: @"%@\n", [currentDir stringByReplacingOccurrencesOfString: @"/" withString: @":"]];
            currentDir = [currentDir substringFromIndex: 1];
            [outputHandle writeData: [currentDir dataUsingEncoding: NSUTF8StringEncoding]];
        }
        else if ([QOSharedLibrary isDirectory: currentDir] == YES)
        {
            [self parseDirectory: currentDir
                 resultDirectory: aRootResultDirectory
        routineNSLocalizedString: aRoutineNSLocalizedString
                      extensions: aListOfExtensions
                     projectName: aProjectName];
        }
    }
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

- (void) cleanDirectoryAtPath: (NSString*) directoryPath
{
    [[NSFileManager defaultManager] removeItemAtPath: directoryPath error: nil];
    [QOSharedLibrary createDirectory: directoryPath];
}

- (NSString*) rootWorkFolderForTabName: (NSString*) aTabName withClean: (BOOL) aClean
{
    NSString* rootWorkFolder = [QOPlistProcessing workDirectory];
    rootWorkFolder = [rootWorkFolder stringByAppendingString: [NSString stringWithFormat: @"/%@", aTabName]];
    if (aClean == YES)
    {
        [self cleanDirectoryAtPath: rootWorkFolder];
    }
    return rootWorkFolder;
}

#pragma mark Run process parsing project's direcory

- (NSString*) targetOfBuildForProject: (NSString*) aXcodeProject
                            plistItem: (NSDictionary*) projectPListItem
{
    NSString* xCodeProjectAndTarget = [projectPListItem objectForKey: @"xCodeProjectTarget"];
    NSArray* xCodeProjectAndTargetArray = [xCodeProjectAndTarget componentsSeparatedByString: @","];
    
    for (NSString* xCodeProjectAndTargetItem in xCodeProjectAndTargetArray)
    {
        NSArray* arr = [xCodeProjectAndTargetItem componentsSeparatedByString: @"/"];
        
        NSLog(@"%ld", [arr count]);
        
        NSString* xCodeProject = [arr objectAtIndex: 0];
        
        if ([xCodeProject isEqualToString: aXcodeProject])
        {
            return [NSString stringWithString: [arr objectAtIndex: 1]];
        }
    }
    
    return @"";
}

- (void) scanModulesThread
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    NSDictionary* plistProjects = nil;
    if ([QOPlistProcessing getPlistProject: &plistProjects
                                    window: MAINWINDOW] == NO)
    {
        NSBeginAlertSheet(NSLocalizedString(@"Warning!", @"Warning!"), nil, nil, nil,
                          MAINWINDOW,
                          self,
                          @selector(alertDidEnd:returnCode:contextInfo:),
                          nil,
                          @"Error in settings",
                          NSLocalizedString(@"Please check settings about directory path to the projects.", @"Please check settings about directory path to the projects."));
        [appController enableToolbar: YES];
        [pool release];
        
        return;
    }
    [appController.progressBar startAnimation: self];
    
    NSTabView* tabView = appController.tabView;
    
    [self removeTabViewItemForName: MODULES_TITLE
                           tabView: tabView];
    
    NSString* rootXcodeResultDirectory = [self rootWorkFolderForTabName: MODULES_TITLE withClean: NO];
    rootXcodeResultDirectory = [rootXcodeResultDirectory stringByAppendingString: @"/"];
    
    NSTabViewItem* tabViewItemXcode = [[NSTabViewItem alloc] init];
    [tabViewItemXcode setLabel: MODULES_TITLE];
    [tabView addTabViewItem: tabViewItemXcode];
    
    NSTabView* tabViewXcode = [[NSTabView alloc] init];
    [tabViewXcode setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
    [tabViewItemXcode setView: tabViewXcode];
    
    NSEnumerator* projectsPListEnumerator = [plistProjects objectEnumerator];
    NSDictionary* projectPListItem;
    
    while ((projectPListItem = [projectsPListEnumerator nextObject]))
    {
        BOOL generateXcodeProjectsData = [[projectPListItem objectForKey: @"generateXcodeProjectData"] boolValue];
        NSString* projectRootDirectoryPath = [[projectPListItem objectForKey: @"RootPath"] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([projectRootDirectoryPath isEqualToString: @""] || (generateXcodeProjectsData == NO))
        {
            continue;
        }
        
        NSString* projectName = [projectPListItem objectForKey: @"name"];
        
        NSString* rootXcodeDirectory = [rootXcodeResultDirectory stringByAppendingString: projectName];
        [QOSharedLibrary createDirectory: rootXcodeDirectory];
        [self cleanDirectoryAtPath: rootXcodeDirectory];
        
#pragma mark Create tab for Project
        
        NSTabViewItem* tabViewItemForXcode = [[NSTabViewItem alloc] init];
        [tabViewItemForXcode setLabel: projectName];
        [tabViewXcode addTabViewItem: tabViewItemForXcode];
        
        NSTabView* tabViewProjectForXcode = [[NSTabView alloc] init];
        [tabViewProjectForXcode setAutoresizingMask: (NSViewWidthSizable | NSViewHeightSizable)];
        [tabViewItemForXcode setView: tabViewProjectForXcode];
        
#pragma mark Xcode project tab create
        
        NSString* pathsOfXcodeproj = [NSString stringWithFormat: @"%@/%@/xcodeproj.txt", [self rootWorkFolderForTabName: STRINGS_TITLE withClean: NO], projectName];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath: pathsOfXcodeproj])
        {
            NSError* error = nil;
            NSString* contentOfFile = [NSString stringWithContentsOfFile: pathsOfXcodeproj
                                                                encoding: NSUTF8StringEncoding
                                                                   error: &error];
            NSArray* srcLines = [contentOfFile componentsSeparatedByString: @"\n"];
            NSEnumerator* srcStream = [srcLines objectEnumerator];
            NSString* pathStr;
            NSString* routineLocalizedString = [projectPListItem objectForKey: @"RoutineLocalizedString"];
            
            while ((pathStr = [srcStream nextObject]) != nil)
            {
                if ([pathStr length] == 0)
                {
                    continue;
                }
                
                NSArray* lines = [pathStr componentsSeparatedByString: @":"];
                NSString* xcodeProjName = [lines objectAtIndex: [lines count] - 1];
                
                lines = [xcodeProjName componentsSeparatedByString: @"."];
                xcodeProjName = [lines objectAtIndex: 0];
                
                NSString* targetOfBuild = [self targetOfBuildForProject: xcodeProjName
                                                              plistItem: projectPListItem];
                
                if ([targetOfBuild length] == 0)
                {
                    continue;
                }
                
                NSString* xcodeProjectResultDirectory = [NSString stringWithFormat: @"%@/%@", rootXcodeDirectory, xcodeProjName];
                [QOSharedLibrary createDirectory: xcodeProjectResultDirectory];
                
                NSScrollView* scrollView = [[NSScrollView alloc] init];
                scrollView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
                
                NSTabViewItem* tabViewItemXcodeProj = [[NSTabViewItem alloc] init];
                [tabViewItemXcodeProj setLabel: xcodeProjName];
                [tabViewProjectForXcode addTabViewItem: tabViewItemXcodeProj];
                
                NSTabView* tabViewXcodeProject = [[NSTabView alloc] init];
                [tabViewXcodeProject setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
                [tabViewItemXcodeProj setView: tabViewXcodeProject];
                
                NSTabViewItem* tabViewItemXcodeFiles = [[NSTabViewItem alloc] init];
                [tabViewItemXcodeFiles setLabel: @"Source Modules"];
                [tabViewXcodeProject addTabViewItem: tabViewItemXcodeFiles];
                
                QOProjectTreeViewController* treeVC = [[QOProjectTreeViewController alloc] initWithNibName: @"ProjectTreeViewController"
                                                                                                    bundle: nil];
                [scrollView setDocumentView: treeVC.view];
                [tabViewItemXcodeFiles setView: scrollView];
                [scrollView release];
                treeVC.pathOfProject = pathStr;
                treeVC.projectName = xcodeProjName;
                treeVC.targetOfBuild = targetOfBuild;
                treeVC.routineNSLocalizedString = routineLocalizedString;
                treeVC.tabViewXcodeProject = tabViewXcodeProject;
                treeVC.rootXcodeDirectory = rootXcodeDirectory;
                [treeVC runBuild];
                [treeVC release];
                [tabViewItemXcodeFiles release];
                [tabViewItemXcodeProj release];
                [tabViewXcodeProject release];
            }
        }
        
#pragma mark -
        
        [tabViewProjectForXcode release];
        [tabViewItemForXcode release];
    }
    [tabViewItemXcode release];
    [tabViewXcode release];
    
    [appController.progressBar stopAnimation: self];
    [appController enableToolbar: YES];
    
    NSBeginAlertSheet(NSLocalizedString(@"Scan Succeeded", @"Scan Succeeded"), nil, nil, nil, MAINWINDOW, nil, nil, nil, nil,
                      NSLocalizedString(@"No issues", @"No issues"));
    
    [plistProjects release];
    [pool release];
}

- (void) scanStringsThread
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    NSDictionary* plistProjects = nil;
    if ([QOPlistProcessing getPlistProject: &plistProjects
                                    window: MAINWINDOW] == NO)
    {
        NSBeginAlertSheet(NSLocalizedString(@"Warning!", @"Warning!"), nil, nil, nil,
                          MAINWINDOW,
                          self,
                          @selector(alertDidEnd:returnCode:contextInfo:),
                          nil,
                          @"Error in settings",
                          NSLocalizedString(@"Please check settings about directory path to the projects.", @"Please check settings about directory path to the projects."));
        [appController enableToolbar: YES];
        [pool release];
        
        return;
    }
    [appController.progressBar startAnimation: self];
    
    NSTabView* tabView = appController.tabView;
    
    [self removeTabViewItemForName: STRINGS_TITLE
                           tabView: tabView];
    
    NSString* rootResultDirectory = [self rootWorkFolderForTabName: STRINGS_TITLE withClean: NO];
    rootResultDirectory = [rootResultDirectory stringByAppendingString: @"/"];
    
    NSTabViewItem* tabViewItemMain = [[NSTabViewItem alloc] init];
    [tabViewItemMain setLabel: STRINGS_TITLE];
    [tabView addTabViewItem: tabViewItemMain];
    
    NSString* rootXcodeResultDirectory = [self rootWorkFolderForTabName: MODULES_TITLE withClean: NO];
    rootXcodeResultDirectory = [rootXcodeResultDirectory stringByAppendingString: @"/"];
    
    NSTabView* tabViewMain = [[NSTabView alloc] init];
    [tabViewMain setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
    [tabViewItemMain setView: tabViewMain];
    
    NSEnumerator* projectsPListEnumerator = [plistProjects objectEnumerator];
    NSDictionary* projectPListItem;
    
    while ((projectPListItem = [projectsPListEnumerator nextObject]))
    {
        NSString* projectRootDirectoryPath = [[projectPListItem objectForKey: @"RootPath"] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        BOOL enable = [[projectPListItem objectForKey: @"enable"] boolValue];
        
        if ([projectRootDirectoryPath isEqualToString: @""] == YES || enable == NO)
        {
            continue;
        }
        
        NSString* projectName = [projectPListItem objectForKey: @"name"];
        NSString* projectResultsDirectory = [rootResultDirectory stringByAppendingString: projectName];
        
        [QOSharedLibrary createDirectory: projectResultsDirectory];
        [self cleanDirectoryAtPath: projectResultsDirectory];
        
        NSString* projectLocalizable_stringsPath = [projectResultsDirectory stringByAppendingString: @"/Localizable.strings"];
        
        if ([QOSharedLibrary deleteFile: projectLocalizable_stringsPath] == NO)
        {
            NSBeginAlertSheet(NSLocalizedString(@"Error", @"Error"), nil, nil, nil, MAINWINDOW, nil, nil, nil, nil,
                              NSLocalizedString(@"Can't delete file", @"Can't delete file"), projectLocalizable_stringsPath);
            break;
        }
        NSString* list = [projectPListItem objectForKey: @"listOfExtensions"];
        NSArray* listOfExtensions = [list componentsSeparatedByString:@","];
        
#pragma mark Parse directory
        
        NSString* routineLocalizedString = [projectPListItem objectForKey: @"RoutineLocalizedString"];
        
        if (routineLocalizedString == nil || [routineLocalizedString isEqual: @""])
        {
            continue;
        }
        [self parseDirectory: projectRootDirectoryPath
             resultDirectory: projectResultsDirectory
    routineNSLocalizedString: routineLocalizedString
                  extensions: listOfExtensions
                 projectName: projectName];
        if ([[NSFileManager defaultManager] fileExistsAtPath: projectLocalizable_stringsPath] == NO)
        {
            NSBeginAlertSheet(NSLocalizedString(@"Warning!", @"Warning!"), nil, nil, nil, MAINWINDOW, nil, nil, nil, nil,
                              NSLocalizedString(@"File '%@' isn't exist after parsing %@ for routine %@!", @"File '%@' isn't exist after parsing %@ for routine %@!"), projectLocalizable_stringsPath, projectRootDirectoryPath, routineLocalizedString);
            continue;
        }
        
#pragma mark Ordering Data from file 'Localizable.strings' after parsing
        
        [QOSharedLibrary orderingOnKeyStringsDataInFile: projectLocalizable_stringsPath];
        
#pragma mark Create tab for Project
        
        NSTabViewItem* tabViewItem = [[NSTabViewItem alloc] init];
        [tabViewItem setLabel: projectName];
        [tabViewMain addTabViewItem: tabViewItem];
        
        NSTabView* tabViewProject = [[NSTabView alloc] init];
        [tabViewProject setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
        [tabViewItem setView: tabViewProject];
        
#pragma mark Create tab 'Localizable.strings' file after parsing current project
        
        {
            NSTabViewItem* tabViewItemLocalizableStrings = [[NSTabViewItem alloc] init];
            [tabViewItemLocalizableStrings setLabel: @"0"];
            
            NSScrollView* scrollView = [[ NSScrollView alloc] initWithFrame: NSMakeRect(0.0f, 0.0f, 400.0f, 400.0f)];
            
            [tabViewItemLocalizableStrings setView: scrollView];
            [scrollView release];
            
            [tabViewProject addTabViewItem: tabViewItemLocalizableStrings];
            [tabViewItemLocalizableStrings release];
        }
        
        sleep(1);
        
        {
            NSTabViewItem* tabViewItemLocalizableStrings = [[NSTabViewItem alloc] init];
            [tabViewItemLocalizableStrings setLabel: @"Localizable.strings"];
            QOStringsTableView* scrollView = [[QOStringsTableView alloc] initWithFile: projectLocalizable_stringsPath
                                                                             encoding: NSUTF16StringEncoding
                                                                          projectName: projectName
                                                                                  lng: @"en"];
            scrollView.typeFile = TYPE_DATA_MAIN;
            scrollView.sourceFile = projectLocalizable_stringsPath;
            
            [tabViewItemLocalizableStrings setView: scrollView];
            [scrollView release];
            
            [tabViewProject addTabViewItem: tabViewItemLocalizableStrings];
            [tabViewItemLocalizableStrings release];
        }
        
        sleep(1);
        
#pragma mark Copy all lproj content files to the 'dest' dir and create tab 'org' for each lng
        
        NSString* projectsResPath = [NSString stringWithFormat: @"%@/", [projectPListItem objectForKey: @"ResourcesPath"]];
        NSArray* filelist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: projectsResPath
                                                                                error: NULL];
        int lengthFileList = [filelist count];
        
        for (int i = 0; i < lengthFileList; i++)
        {
            NSString* currentDir = [filelist objectAtIndex: i];
            NSString* fullPathOfCurrentDir = [NSString stringWithFormat: @"%@%@", projectsResPath, currentDir];
            
            if ([QOSharedLibrary isDirectory: fullPathOfCurrentDir] == YES && [currentDir hasSuffix: @".lproj"] == YES)
            {
                NSString* fileStringsSource = [NSString stringWithFormat: @"%@/Localizable.strings", fullPathOfCurrentDir];
                
                if ([[NSFileManager defaultManager] fileExistsAtPath: fileStringsSource] == NO)
                {
                    continue;
                }
                
                NSRange rng = [currentDir rangeOfString: @"."];
                NSString* lng = [currentDir substringToIndex: rng.location];
                NSString* pathOrgRes = [NSString stringWithFormat: @"%@/%@", projectResultsDirectory, lng];
                [QOSharedLibrary createDirectory: pathOrgRes];
                
                NSString* fileStringsDestonation = [NSString stringWithFormat: @"%@/Localizable.strings", pathOrgRes];
                
                if ([QOSharedLibrary deleteFile: fileStringsDestonation] == NO)
                {
                    NSBeginAlertSheet(NSLocalizedString(@"Error", @"Error"), nil, nil, nil, MAINWINDOW, nil, nil, nil, nil,
                                      NSLocalizedString(@"Can't delete file", @"Can't delete file"), fileStringsDestonation);
                    break;
                }
                
                NSError* error = nil;
                [[NSFileManager defaultManager] copyItemAtPath: fileStringsSource
                                                        toPath: fileStringsDestonation
                                                         error: &error];
                
                NSString* fileWithPathFileStringsSource = [NSString stringWithFormat: @"%@/sourcepath.txt", pathOrgRes];
                error = nil;
                [fileStringsSource writeToFile: fileWithPathFileStringsSource atomically: YES
                                      encoding: NSUTF16StringEncoding
                                         error: &error];
                
                if ([lng isEqual: @"en"])
                {
                    [QOSharedLibrary createNewEnglishResourceFromLocalicableStringsPath: projectResultsDirectory];
                }
                else
                {
                    [QOSharedLibrary createNewLocalizableStringsForLng: (NSString*)lng path: projectResultsDirectory];
                }
                
                [QOSharedLibrary noTranslationCreateFileForLngAndPath: lng
                                                                 path: projectResultsDirectory];
                
#pragma mark Create tab LNG
                
                NSTabViewItem* tabViewItemLng = [[NSTabViewItem alloc] init];
                [tabViewItemLng setLabel: lng];
                
                NSTabView* tabViewProjectLng = [[NSTabView alloc] init];
                [tabViewProjectLng setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
                
#pragma mark Create tab ORG
                
                {
                    NSTabViewItem* tabViewItemLngOrg = [[NSTabViewItem alloc] init];
                    [tabViewItemLngOrg setLabel: NSLocalizedString(@"org", @"org")];
                    {
                        QOStringsTableView* scrollViewLngOrg = [[QOStringsTableView alloc] initWithFile: fileStringsDestonation
                                                                                               encoding: NSUTF8StringEncoding
                                                                                            projectName: projectName
                                                                                                    lng: lng];
                        scrollViewLngOrg.typeFile = TYPE_DATA_ORG;
                        scrollViewLngOrg.sourceFile = fileStringsDestonation;
                        
                        [tabViewItemLngOrg setView: scrollViewLngOrg];
                        [scrollViewLngOrg release];
                    }
                    [tabViewProjectLng addTabViewItem: tabViewItemLngOrg];
                    [tabViewItemLngOrg release];
                }
                
                sleep(1);
                
#pragma mark Create tab NEW
                
                {
                    // New string resources for current project
                    NSTabViewItem* tabViewItemLngNew = [[NSTabViewItem alloc] init];
                    [tabViewItemLngNew setLabel: NSLocalizedString(@"new", @"new")];
                    {
                        NSString* fileNewLocStrRes = [NSString stringWithFormat: @"%@/%@.txt", projectResultsDirectory, lng];
                        QOStringsTableView* scrollViewLngNew = [[QOStringsTableView alloc] initWithFile: fileNewLocStrRes
                                                                                               encoding: NSUTF16StringEncoding
                                                                                            projectName: projectName
                                                                                                    lng: lng];
                        scrollViewLngNew.typeFile = TYPE_DATA_NEW;
                        scrollViewLngNew.sourceFile = fileNewLocStrRes;
                        scrollViewLngNew.targetFile = fileStringsSource;
                        
                        [tabViewItemLngNew setView: scrollViewLngNew];
                        [scrollViewLngNew release];
                    }
                    [tabViewProjectLng addTabViewItem: tabViewItemLngNew];
                    [tabViewItemLngNew release];
                }
                
                sleep(1);
                
#pragma mark Create tab no translation
                
                {
                    // Show string resources wich need translate
                    NSTabViewItem* tabViewItemLngNoTrans = [[NSTabViewItem alloc] init];
                    [tabViewItemLngNoTrans setLabel: NSLocalizedString(@"no translation", @"no translation")];
                    {
                        NSString* fileNoTranslation = [NSString stringWithFormat: @"%@/%@_NO_TRANSLATION.txt", projectResultsDirectory, lng];
                        if ([[NSFileManager defaultManager] fileExistsAtPath: fileNoTranslation] == YES)
                        {
                            QOStringsTableView* scrollViewLngNoTrans = [[QOStringsTableView alloc] initWithFile: fileNoTranslation
                                                                                                       encoding: NSUTF16StringEncoding
                                                                                                    projectName: projectName
                                                                                                            lng: lng];
                            scrollViewLngNoTrans.typeFile = TYPE_DATA_NO_TRANSLATION;
                            scrollViewLngNoTrans.sourceFile = fileNoTranslation;
                            
                            [tabViewItemLngNoTrans setView: scrollViewLngNoTrans];
                            [scrollViewLngNoTrans release];
                        }
                    }
                    [tabViewProjectLng addTabViewItem: tabViewItemLngNoTrans];
                    [tabViewItemLngNoTrans release];
                }
                
                sleep(1);
                
                [tabViewItemLng setView: tabViewProjectLng];
                [tabViewProjectLng release];
                
                [tabViewProject addTabViewItem: tabViewItemLng];
                [tabViewItemLng release];
            }
            
        }
        
        [tabViewProject release];
        [tabViewItem release];
    }
    [tabViewItemMain release];
    [tabViewMain release];
    
    [appController.progressBar stopAnimation: self];
    [appController enableToolbar: YES];
    NSBeginAlertSheet(NSLocalizedString(@"Scan Succeeded", @"Scan Succeeded"), nil, nil, nil, MAINWINDOW, nil, nil, nil, nil,
                      NSLocalizedString(@"No issues", @"No issues"));
    
    [plistProjects release];
    [pool release];
}

#pragma mark OPEN project

- (NSString*) valueFromPlistForProject: (NSString*) aProjectName forOption: (NSString*)aOption forWindow: (NSWindow*) aWindow
{
    NSString* value = nil;
    NSDictionary* plistProjects = nil;

    if ([QOPlistProcessing getPlistProject: &plistProjects
                                    window: aWindow] == NO)
    {
        NSBeginAlertSheet(NSLocalizedString(@"Warning!", @"Warning!"), nil, nil, nil,
                          aWindow,
                          self,
                          @selector(alertDidEnd:returnCode:contextInfo:),
                          nil,
                          @"Error in settings",
                          NSLocalizedString(@"Please check settings about directory path to the projects.", @"Please check settings about directory path to the projects."));
        return value;
    }
    NSEnumerator* projectsPListEnumerator = [plistProjects objectEnumerator];
    NSDictionary* projectPListItem;

    while ((projectPListItem = [projectsPListEnumerator nextObject]))
    {
        NSString* projectName = [projectPListItem objectForKey: @"name"];
        if ([aProjectName isEqualToString: projectName] == YES)
        {
            value = [projectPListItem objectForKey: aOption];
            break;
        }
    }
    
    [plistProjects release];
    return  value;
}

- (void) openProjectModulesThread
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    NSString* workDir = [QOPlistProcessing workDirectory];
    workDir = [workDir stringByAppendingString: [NSString stringWithFormat: @"/%@", MODULES_TITLE]];

    if (![[NSFileManager defaultManager] fileExistsAtPath: workDir])
    {
        [appController enableToolbar: YES];
        NSBeginAlertSheet(NSLocalizedString(@"Data didn't found.", @"Data didn't found."), nil, nil, nil, MAINWINDOW, nil, nil, nil, nil,
                          NSLocalizedString(@"Please start to scan strings.", @"Please start to scan strings."));
        [pool release];
        return;
    }
    workDir = [workDir stringByAppendingString: @"/"];
    
    [appController enableToolbar: NO];
    [appController.progressBar startAnimation: self];
    
    NSTabView* tabView = appController.tabView;
    
    [self removeTabViewItemForName: MODULES_TITLE
                           tabView: tabView];
    
    NSTabViewItem* tabViewItemXcode = [[NSTabViewItem alloc] init];
    [tabViewItemXcode setLabel: MODULES_TITLE];
    [tabView addTabViewItem: tabViewItemXcode];
    
    NSTabView* tabViewXcode = [[NSTabView alloc] init];
    [tabViewXcode setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
    [tabViewItemXcode setView: tabViewXcode];
    
    NSArray* filelist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: workDir
                                                                            error: NULL];
    int fileLisCount = [filelist count];
    
    for (int fileListItemIndex = 0; fileListItemIndex < fileLisCount; fileListItemIndex++)
    {
        NSString* projectName = [filelist objectAtIndex: fileListItemIndex];
        NSString* routineLocalizedString = [self valueFromPlistForProject: projectName
                                                                forOption: @"RoutineLocalizedString"
                                                                forWindow: MAINWINDOW];
        NSString* currentDir = [workDir stringByAppendingString: projectName];
        
        if ([QOSharedLibrary isDirectory: currentDir])
        {
            NSTabViewItem* tabViewItemForXcode = [[NSTabViewItem alloc] init];
            [tabViewItemForXcode setLabel: projectName];
            
            NSTabView* tabViewProjectForXcode = [[NSTabView alloc] init];
            [tabViewProjectForXcode setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
            
            [tabViewItemForXcode setView: tabViewProjectForXcode];
            [tabViewXcode addTabViewItem: tabViewItemForXcode];
            [tabViewItemForXcode release];
            
            NSString* rootXcodeDirectory = [NSString stringWithFormat: @"%@/%@", [self rootWorkFolderForTabName: MODULES_TITLE withClean: NO], projectName];
            NSString* pathsOfXcodeproj = [NSString stringWithFormat: @"%@/%@/xcodeproj.txt", [self rootWorkFolderForTabName: STRINGS_TITLE withClean: NO], projectName];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath: pathsOfXcodeproj] == YES)
            {
                NSError* error = nil;
                NSString* contentOfFile = [NSString stringWithContentsOfFile: pathsOfXcodeproj
                                                                    encoding: NSUTF8StringEncoding
                                                                       error: &error];
                NSArray* srcLines = [contentOfFile componentsSeparatedByString: @"\n"];
                NSEnumerator* srcStream = [srcLines objectEnumerator];
                NSString* pathStr;
                
                while ((pathStr = [srcStream nextObject]) != nil)
                {
                    
                    if ([pathStr length] == 0)
                    {
                        continue;
                    }
                    
                    NSArray* lines = [pathStr componentsSeparatedByString: @":"];
                    NSString* xcodeProjName = [lines objectAtIndex: [lines count] - 1];
                    
                    lines = [xcodeProjName componentsSeparatedByString: @"."];
                    xcodeProjName = [lines objectAtIndex: 0];
                    
                    NSTabViewItem* tabViewItemXcodeProj = [[NSTabViewItem alloc] init];
                    [tabViewItemXcodeProj setLabel: xcodeProjName];
                    [tabViewProjectForXcode addTabViewItem: tabViewItemXcodeProj];
                    
                    NSTabView* tabViewXcodeProject = [[NSTabView alloc] init];
                    [tabViewXcodeProject setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
                    [tabViewItemXcodeProj setView: tabViewXcodeProject];
                    
                    {
                        NSTabViewItem* tabViewItemLocalizableStrings = [[NSTabViewItem alloc] init];
                        NSScrollView* scrollView = [[ NSScrollView alloc] initWithFrame: NSMakeRect(0.0f, 0.0f, 400.0f, 400.0f)];
                        [tabViewItemLocalizableStrings setView: scrollView];
                        [scrollView release];
                        [tabViewXcodeProject addTabViewItem: tabViewItemLocalizableStrings];
                        [tabViewItemLocalizableStrings release];
                        
                        sleep(1);
                    }
                    
                    {
                        NSScrollView* scrollView = [[ NSScrollView alloc] initWithFrame: NSMakeRect(0.0f, 0.0f, 400.0f, 400.0f)];
                        scrollView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
                        QOProjectTreeViewController* treeVC = [[QOProjectTreeViewController alloc] initWithNibName: @"ProjectTreeViewController"
                                                                                                            bundle: nil];
                        treeVC.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
                        [scrollView setDocumentView: treeVC.view];
                        treeVC.pathOfProject = pathStr;
                        treeVC.projectName = xcodeProjName;
                        treeVC.routineNSLocalizedString = routineLocalizedString;
                        treeVC.tabViewXcodeProject = tabViewXcodeProject;
                        treeVC.rootXcodeDirectory = rootXcodeDirectory;
                        [treeVC openBuild];
                        
                        NSTabViewItem* tabViewItemXcodeFiles = [[NSTabViewItem alloc] init];
                        [tabViewItemXcodeFiles setLabel: @"Sources Modules"];
                        [tabViewItemXcodeFiles setView: scrollView];
                        [tabViewXcodeProject addTabViewItem: tabViewItemXcodeFiles];
                        [scrollView release];
                        
                        [self addXcodeTabsForLngDistribution: tabViewXcodeProject
                                  localizableStringsFileName: treeVC.localizableStringsFileName
                                              workFolderPath: [treeVC workFolderPath]];
                        
                        [treeVC release];
                        [tabViewItemXcodeFiles release];
                        [tabViewItemXcodeProj release];
                        [tabViewXcodeProject release];
                    }
                    
                    sleep(1);
                }
            }
            
            [tabViewProjectForXcode release];
        }
    }
    [tabViewItemXcode release];
    [tabViewXcode release];
    
    [appController enableToolbar: YES];
    [appController.progressBar stopAnimation: self];
    NSBeginAlertSheet(NSLocalizedString(@"Open Succeeded", @"Open Succeeded"), nil, nil, nil, MAINWINDOW, nil, nil, nil, nil,
                      NSLocalizedString(@"No issues", @"No issues"));
    [pool release];
}


- (void) openStringsThread
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    NSString* workDir = [QOPlistProcessing workDirectory];
    workDir = [workDir stringByAppendingString: [NSString stringWithFormat: @"/%@", STRINGS_TITLE]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath: workDir])
    {
        [appController enableToolbar: YES];
        NSBeginAlertSheet(NSLocalizedString(@"Data didn't found.", @"Data didn't found."), nil, nil, nil, MAINWINDOW, nil, nil, nil, nil,
                          NSLocalizedString(@"Please start to scan strings.", @"Please start to scan strings."));
        [pool release];
        
        return;
    }
    workDir = [workDir stringByAppendingString: @"/"];
    
    [appController enableToolbar: NO];
    [appController.progressBar startAnimation: self];
    
    NSTabView* tabView = appController.tabView;
    [self removeTabViewItemForName: STRINGS_TITLE
                           tabView: tabView];
    
    NSTabViewItem* tabViewItemMain = [[NSTabViewItem alloc] init];
    [tabViewItemMain setLabel: STRINGS_TITLE];
    [tabView addTabViewItem: tabViewItemMain];
    
    NSTabView* tabViewMain = [[NSTabView alloc] init];
    [tabViewMain setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
    [tabViewItemMain setView: tabViewMain];
    
    NSArray* filelist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: workDir
                                                                            error: NULL];
    int fileLisCount = [filelist count];
    
    for (int fileListItemIndex = 0; fileListItemIndex < fileLisCount; fileListItemIndex++)
    {
        NSString* projectName = [filelist objectAtIndex: fileListItemIndex];
        NSString* currentDir = [workDir stringByAppendingString: projectName];
        
        if ([QOSharedLibrary isDirectory: currentDir] == YES)
        {
            NSTabViewItem* tabViewItem = [[NSTabViewItem alloc] init];
            [tabViewItem setLabel: projectName];
            
            NSTabView* tabViewProject = [[NSTabView alloc] init];
            [tabViewProject setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
            
            [tabViewItem setView: tabViewProject];
            [tabViewMain addTabViewItem: tabViewItem];
            
            NSTabViewItem* tabViewItemLocalizableStrings = [[NSTabViewItem alloc] init];
            [tabViewItemLocalizableStrings setLabel: @"Localizable.strings"];
            
            {
                NSScrollView* scrollView = [[ NSScrollView alloc] initWithFrame: NSMakeRect(0.0f, 0.0f, 400.0f, 400.0f)];
                [tabViewItemLocalizableStrings setView: scrollView];
                [scrollView release];
                [tabViewProject addTabViewItem: tabViewItemLocalizableStrings];
                [tabViewItemLocalizableStrings release];
            }
            
            sleep(1);
            
            {
                NSString* projectLocalizable_stringsPath = [currentDir stringByAppendingString: @"/Localizable.strings"];
                QOStringsTableView* scrollView = [[QOStringsTableView alloc] initWithFile: projectLocalizable_stringsPath
                                                                                 encoding: NSUTF16StringEncoding
                                                                              projectName: projectName
                                                                                      lng: @"en"];
                scrollView.typeFile = TYPE_DATA_MAIN;
                scrollView.sourceFile = projectLocalizable_stringsPath;
                
                [tabViewItemLocalizableStrings setView: scrollView];
                [scrollView release];
                
                [tabViewProject addTabViewItem: tabViewItemLocalizableStrings];
                [tabViewItemLocalizableStrings release];
            }
            
            sleep(1);
            
            NSArray* filelistlng = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: currentDir
                                                                                       error: NULL];
            int countlng = [filelistlng count];
            int j;

            for (j = 0; j < countlng; j++)
            {
                NSString* lng = [filelistlng objectAtIndex: j];
                
                NSTabView* tabViewProjectLng = [[NSTabView alloc] init];
                [tabViewProjectLng setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
                
                NSString* currentDirLng = [NSString stringWithFormat: @"%@/%@", currentDir, lng];
                if ([QOSharedLibrary isDirectory: currentDirLng] == YES)
                {
                    NSTabViewItem* tabViewItemLng = [[NSTabViewItem alloc] init];
                    [tabViewItemLng setLabel: lng];
                    
#pragma mark Creating tab ORG
                    
                    NSTabViewItem* tabViewItemLngOrg = [[NSTabViewItem alloc] init];
                    [tabViewItemLngOrg setLabel:  NSLocalizedString(@"org", @"org")];
                    
                    {
                        NSString* fileStringsDestonation = [NSString stringWithFormat: @"%@/Localizable.strings", currentDirLng];
                        QOStringsTableView* scrollViewLngOrg = [[QOStringsTableView alloc] initWithFile: fileStringsDestonation
                                                                                               encoding: NSUTF8StringEncoding
                                                                                            projectName: projectName
                                                                                                    lng: lng];
                        scrollViewLngOrg.typeFile = TYPE_DATA_ORG;
                        scrollViewLngOrg.sourceFile = fileStringsDestonation;
                        
                        [tabViewItemLngOrg setView: scrollViewLngOrg];
                        [scrollViewLngOrg release];
                    }
                    
                    sleep(1);
                    
                    [tabViewProjectLng addTabViewItem: tabViewItemLngOrg];
                    [tabViewItemLngOrg release];
                    
#pragma mark Creating tab NEW
                    
                    // New string resources for current project
                    NSTabViewItem* tabViewItemLngNew = [[NSTabViewItem alloc] init];
                    [tabViewItemLngNew setLabel: NSLocalizedString(@"new", @"new")];
                    {
                        NSString* fileNewLocStrRes = [NSString stringWithFormat: @"%@/%@.txt", currentDir, lng];
                        
                        NSString* fileWithPathFileStringsSource = [NSString stringWithFormat: @"%@/sourcepath.txt", currentDirLng];
                        NSError* error = nil;
                        NSString* fileStringsSource = [NSString stringWithContentsOfFile: fileWithPathFileStringsSource
                                                                                encoding: NSUTF16StringEncoding
                                                                                   error: &error];
                        
                        {
                            QOStringsTableView* scrollViewLngNew = [[QOStringsTableView alloc] initWithFile: fileNewLocStrRes
                                                                                                   encoding: NSUTF16StringEncoding
                                                                                                projectName: projectName
                                                                                                        lng: lng];
                            scrollViewLngNew.typeFile = TYPE_DATA_NEW;
                            scrollViewLngNew.sourceFile = fileNewLocStrRes;
                            scrollViewLngNew.targetFile = fileStringsSource;
                            
                            [tabViewItemLngNew setView: scrollViewLngNew];
                            [scrollViewLngNew release];
                        }
                        
                        sleep(1);
                        
                    }
                    [tabViewProjectLng addTabViewItem: tabViewItemLngNew];
                    [tabViewItemLngNew release];
                    
#pragma mark Creating tab no translation
                    
                    // Show string resources wich need translate
                    NSTabViewItem* tabViewItemLngNoTrans = [[NSTabViewItem alloc] init];
                    [tabViewItemLngNoTrans setLabel: NSLocalizedString(@"no translation", @"no translation")];
                    {
                        NSString* fileNoTranslation = [NSString stringWithFormat: @"%@/%@_NO_TRANSLATION.txt", currentDir, lng];

                        if ([[NSFileManager defaultManager] fileExistsAtPath: fileNoTranslation] == YES)
                        {
                            {
                                QOStringsTableView* scrollViewLngNoTrans = [[QOStringsTableView alloc] initWithFile: fileNoTranslation
                                                                                                           encoding: NSUTF16StringEncoding
                                                                                                        projectName: projectName
                                                                                                                lng: lng];
                                scrollViewLngNoTrans.typeFile = TYPE_DATA_NO_TRANSLATION;
                                scrollViewLngNoTrans.sourceFile = fileNoTranslation;
                                
                                [tabViewItemLngNoTrans setView: scrollViewLngNoTrans];
                                [scrollViewLngNoTrans release];
                            }
                            
                            sleep(1);
                            
                        }
                    }
                    [tabViewProjectLng addTabViewItem: tabViewItemLngNoTrans];
                    [tabViewItemLngNoTrans release];
                    
                    [tabViewItemLng setView: tabViewProjectLng];
                    [tabViewProjectLng release];
                    
                    [tabViewProject addTabViewItem: tabViewItemLng];
                    [tabViewItemLng release];
                    
                }
                else
                {
                    [tabViewProjectLng release];
                }
            }
            
            [tabViewProject release];
            [tabViewItem release];
        }
    }
    
    [tabViewItemMain release];
    [tabViewMain release];
    
    [appController enableToolbar: YES];
    [appController.progressBar stopAnimation: self];
    NSBeginAlertSheet(NSLocalizedString(@"Open Succeeded", @"Open Succeeded"), nil, nil, nil, MAINWINDOW, nil, nil, nil, nil,
                      NSLocalizedString(@"No issues", @"No issues"));
    [pool release];
}

- (void) startScanStrings
{
    [appController enableToolbar: NO];
    [scanQueue addOperationWithBlock: ^
     {
         [self scanStringsThread];
     }];
}

- (void) startScanModules
{
    [appController enableToolbar: NO];
    [scanQueue addOperationWithBlock: ^
     {
         [self scanModulesThread];
     }];
}

- (void) openProject
{
    [appController enableToolbar: NO];
    [scanQueue addOperationWithBlock: ^
     {
         [self openStringsThread];
     }];
}

- (void) openProjectModules
{
    [appController enableToolbar: NO];
    [scanQueue addOperationWithBlock: ^
     {
         [self openProjectModulesThread];
     }];
}

- (void) addXcodeTabsForLngDistribution: (NSTabView*) tabViewXcodeProject
             localizableStringsFileName: (NSString*) aLocalizableStringsFileName
                         workFolderPath: (NSString*) aWorkFolderPath
{
    NSString* workDir = [QOPlistProcessing workDirectory];
    workDir = [workDir stringByAppendingString: [NSString stringWithFormat: @"/%@", STRINGS_TITLE]];
    if ([[NSFileManager defaultManager] fileExistsAtPath: workDir] == NO)
    {
        [appController enableToolbar: YES];
        NSBeginAlertSheet(NSLocalizedString(@"Data didn't found.", @"Data didn't found."), nil, nil, nil, MAINWINDOW, nil, nil, nil, nil,
                          NSLocalizedString(@"Please start to scan strings.", @"Please start to scan strings."));
        return;
    }
    workDir = [workDir stringByAppendingString: @"/"];
    NSArray* filelist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: workDir
                                                                            error: NULL];
    int fileLisCount = [filelist count];

    for (int fileListItemIndex = 0; fileListItemIndex < fileLisCount; fileListItemIndex++)
    {
        NSString* projectName = [filelist objectAtIndex: fileListItemIndex];
        NSString* currentDir = [workDir stringByAppendingString: projectName];

        if ([QOSharedLibrary isDirectory: currentDir] == YES)
        {
            NSArray* filelistlng = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: currentDir
                                                                                       error: NULL];
            int countlng = [filelistlng count];

            for (int j = 0; j < countlng; j++)
            {
                NSString* lng = [filelistlng objectAtIndex: j];
                NSString* currentDirLng = [NSString stringWithFormat: @"%@/%@", currentDir, lng];

                if ([QOSharedLibrary isDirectory: currentDirLng] == YES)
                {
                    // New string resources for current project
                    NSTabViewItem* tabViewItemLngNew = [[NSTabViewItem alloc] init];
                    [tabViewItemLngNew setLabel: lng];
                    {
                        NSString* fileWithLngStrings = [NSString stringWithFormat: @"%@/%@.txt", currentDir, lng];
                        NSString* fileNewLocStrRes = [NSString stringWithFormat: @"%@/%@.txt", aWorkFolderPath, lng];
                        [QOSharedLibrary mergeLocStr: aLocalizableStringsFileName
                                         withLngFile: fileWithLngStrings
                                              toFile: fileNewLocStrRes];
                        
                        {
                            QOStringsTableView* scrollViewLngNew = [[QOStringsTableView alloc] initWithFile: fileNewLocStrRes
                                                                                                   encoding: NSUTF16StringEncoding
                                                                                                projectName: projectName
                                                                                                        lng: lng];
                            scrollViewLngNew.typeFile = TYPE_DATA_NEW;
                            scrollViewLngNew.sourceFile = fileNewLocStrRes;
                            scrollViewLngNew.targetFile = fileNewLocStrRes;
                            
                            [tabViewItemLngNew setView: scrollViewLngNew];
                            [scrollViewLngNew release];
                        }
                        
                        sleep(1);
                        
                    }
                    [tabViewXcodeProject addTabViewItem: tabViewItemLngNew];
                    [tabViewItemLngNew release];
                }                    
            }
        }
    }
}

@end
