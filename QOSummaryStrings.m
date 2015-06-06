//  QOLocalizableStrings
//
//  QOSummaryStrings.m
//
//  Created by Sergey Krotkih on 3/14/11.
//  Copyright 2011 Quickoffice. All rights reserved.
//

#import "QOSummaryStrings.h"
#import "QOLocalizableStringsController.h"
#import "QOSummaryTableView.h"
#import "QOPlistProcessing.h"
#import "QOSettingsController.h"
#import "QOSharedLibrary.h"

static NSString* const SUMMARY_DICTIONARY = @"Summary";
static NSString* const CURRENT_DICTIONARY = @"Current dictionary";
static NSString* const NO_TRANSLATION_DICTIONARY = @"For translate";
static NSString* const ACTUAL_DICTIONARY = @"Actual dictionary";

@implementation QOSummaryStrings

@synthesize appController;

+ (QOSummaryStrings* ) sharedSummaryStrings
{
	static QOSummaryStrings* _sharedSummaryStrings = nil;
	
	if (_sharedSummaryStrings == nil)
	{
		_sharedSummaryStrings = [[QOSummaryStrings alloc] init];
        _sharedSummaryStrings.appController = [QOLocalizableStringsController appController];
	}
	
	return _sharedSummaryStrings;
}

- (void) dealloc
{
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

-(void) outputSummaryDictionary: (NSMutableArray*)records forArrayWithLngs: (NSMutableArray*)lngs toTabView: (NSTabView*)aTabView type: (TYPE_FILE)aType
{
    NSEnumerator* lngStream = [lngs objectEnumerator];    
    NSString* lng;
    while ((lng = [lngStream nextObject]) != nil)
    {
        QOSummaryTableView* scrollView = [[QOSummaryTableView alloc] initWithDictionary: records 
                                                                                    lng: lng];
        scrollView.typeFile = aType;
        
        NSTabViewItem* tabViewItemLng = [[NSTabViewItem alloc] init];
        [tabViewItemLng setLabel: lng];
        
        [tabViewItemLng setView: scrollView];
        [scrollView release];
        
        [aTabView addTabViewItem: tabViewItemLng];
        [tabViewItemLng release];
    }
}

- (void) scanThread
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
    [self removeTabViewItemForName: SUMMARY_DICTIONARY
                           tabView: tabView];
    
    NSTabViewItem* tabViewItemMain = [[NSTabViewItem alloc] init];
    [tabViewItemMain setLabel: SUMMARY_DICTIONARY];
    [tabView addTabViewItem: tabViewItemMain];
    
    NSTabView* tabViewMain = [[NSTabView alloc] init];
    [tabViewMain setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
    [tabViewItemMain setView: tabViewMain];
    [tabViewItemMain release];

#pragma mark create CURRENT DICTIONARY
    
    NSTabViewItem* tabViewItemCurrent = [[NSTabViewItem alloc] init];
    [tabViewItemCurrent setLabel: CURRENT_DICTIONARY];
    [tabViewMain addTabViewItem: tabViewItemCurrent];
    
    NSTabView* tabViewCurrent = [[NSTabView alloc] init];
    [tabViewCurrent setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
    [tabViewItemCurrent setView: tabViewCurrent];
    [tabViewItemCurrent release];
    
    NSMutableArray* records = [[NSMutableArray alloc] init];
    NSMutableArray* lngs = [[NSMutableArray alloc] init];
    
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

        NSString* projectsResPath = [NSString stringWithFormat: @"%@/", [projectPListItem objectForKey: @"ResourcesPath"]];
        NSArray* filelist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: projectsResPath 
                                                                                error: NULL];
        int lengthFileList = [filelist count];
        for (int i = 0; i < lengthFileList; i++)
        {
            
            NSString* currentDir = [filelist objectAtIndex: i];
            NSString* fullPathOfCurrentDir = [NSString stringWithFormat: @"%@/%@", projectsResPath, currentDir];
            
            
            if ([QOSharedLibrary isDirectory: fullPathOfCurrentDir] == YES && 
                [currentDir hasSuffix: @".lproj"] == YES) 
            {
                NSString* fileStrings = [NSString stringWithFormat: @"%@/Localizable.strings", fullPathOfCurrentDir];
                NSRange rng = [currentDir rangeOfString: @"."];
                NSString* lng = [currentDir substringToIndex: rng.location];
                if ([lngs indexOfObject: lng] == NSNotFound) 
                {
                    [lngs addObject: lng];                
                }
                [QOSharedLibrary addToDictionary: &records 
                                          forLng: lng 
                                      forProject: projectName 
                                        fromFile: fileStrings 
                                    withEncoding: NSUTF8StringEncoding];
            }
        }
    }        
    [self outputSummaryDictionary: records forArrayWithLngs: lngs toTabView: tabViewCurrent type: TYPE_DICTIONARY_CURRENT];
    [tabViewCurrent release];

#pragma mark create "NO TRANSLATE" dictionary     

    NSTabViewItem* tabViewItemNoTranslate = [[NSTabViewItem alloc] init];
    [tabViewItemNoTranslate setLabel: NO_TRANSLATION_DICTIONARY];
    [tabViewMain addTabViewItem: tabViewItemNoTranslate];
    
    NSTabView* tabViewNoTranslate = [[NSTabView alloc] init];
    [tabViewNoTranslate setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
    [tabViewItemNoTranslate setView: tabViewNoTranslate];
    [tabViewItemNoTranslate release];
    
    [records removeAllObjects];
    [lngs removeAllObjects];
    NSString* workDirectory = [QOPlistProcessing workDirectory];
    NSString* stringsDirectory = [NSString stringWithFormat: @"%@/Strings", workDirectory];
    
    NSArray* filelist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: stringsDirectory
                                                                            error: NULL];
    int lengthFileList = [filelist count];
    for (int i = 0; i < lengthFileList; i++)
    {
        NSString* projectName = [filelist objectAtIndex: i];
        NSString* fullPathOfCurrentDir = [NSString stringWithFormat: @"%@/%@", stringsDirectory, projectName];

        if ([QOSharedLibrary isDirectory: fullPathOfCurrentDir] == YES) 
        {
            NSArray* filelistProject = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: fullPathOfCurrentDir
                                                                                           error: NULL];
            int lengthFileListProjecty = [filelistProject count];
            for (int j = 0; j < lengthFileListProjecty; j++)
            {
                NSString* notranslateFileName = [filelistProject objectAtIndex: j];
                if ([notranslateFileName rangeOfString: @"TRANSLAT"].location != NSNotFound)
                {
                    NSString* fileStrings = [NSString stringWithFormat: @"%@/%@", fullPathOfCurrentDir, notranslateFileName];
                    NSString* lng = [notranslateFileName stringByReplacingOccurrencesOfString: @"_NO_TRANSLATION.txt" 
                                                                                   withString: @""];    
                    if ([lngs indexOfObject: lng] == NSNotFound) 
                    {
                        [lngs addObject: lng];                
                    }
                    [QOSharedLibrary addToDictionary: &records
                                              forLng: lng 
                                          forProject: projectName 
                                            fromFile: fileStrings
                                        withEncoding: NSUTF16StringEncoding];
                }
            }
        }
    }
    
#pragma mark add data from XIBs

    NSString* rootXIBsDirectory = [NSString stringWithFormat: @"%@/XIBs", workDirectory];
    
    NSArray* xibsfilelist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: rootXIBsDirectory
                                                                                error: NULL];
    int lengthXibsFileList = [xibsfilelist count];
    // XIBs/...
    for (int i = 0; i < lengthXibsFileList; i++)
    {
        NSString* projectName = [xibsfilelist objectAtIndex: i];
        NSString* fullPathOfProjectDir = [NSString stringWithFormat: @"%@/%@", rootXIBsDirectory, projectName];
        if ([QOSharedLibrary isDirectory: fullPathOfProjectDir] == YES) 
        {
            NSArray* projectFileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: fullPathOfProjectDir
                                                                                           error: NULL];
            int lengthOfprojectFileList = [projectFileList count];
            // XIBs/Quickfiles_iPad/...
            for (int j = 0; j < lengthOfprojectFileList; j++)
            {
                NSString* lngDirName = [projectFileList objectAtIndex: j];
                NSString* fullPathLngDirectory = [NSString stringWithFormat: @"%@/%@", fullPathOfProjectDir, lngDirName];
                if ([QOSharedLibrary isDirectory: fullPathLngDirectory] == YES && [lngDirName rangeOfString: @".lproj"].location != NSNotFound)
                {
                    NSString* lng = [lngDirName stringByReplacingOccurrencesOfString: @".lproj" 
                                                                               withString: @""];
                    if ([lng isEqualToString: @"en"] == YES) 
                    {
                        continue;
                    }
                    NSArray* filelistXIBs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: fullPathLngDirectory
                                                                                                error: NULL];
                    int lengthOffilelistXIBs = [filelistXIBs count];
                    // XIBs/Quickfiles_iPad/de.lproj/...
                    for (int k = 0; k < lengthOffilelistXIBs; k++)
                    {
                        NSString* xibFileName = [filelistXIBs objectAtIndex: k];
                        if ([xibFileName rangeOfString: @"Localizable.strings"].location != NSNotFound)
                        {
                            NSString* fileStrings = [NSString stringWithFormat: @"%@/%@", fullPathLngDirectory, xibFileName];
                            if ([lngs indexOfObject: lng] == NSNotFound) 
                            {
                                [lngs addObject: lng];                
                            }
                            [QOSharedLibrary addToDictionary: &records
                                                      forLng: lng 
                                                  forProject: [NSString stringWithFormat: @"%@ (XIB)", projectName]
                                                    fromFile: fileStrings
                                                withEncoding: NSUTF16StringEncoding];
                        }
                    }                    
                }
            }
        }
    }
    [self outputSummaryDictionary: records forArrayWithLngs: lngs toTabView: tabViewNoTranslate type: TYPE_NO_TRANSLATION];
    [tabViewNoTranslate release];
    
#pragma mark create ACTUAL DUICTIONARY     
    
    NSTabViewItem* tabViewItemActual = [[NSTabViewItem alloc] init];
    [tabViewItemActual setLabel: ACTUAL_DICTIONARY];
    [tabViewMain addTabViewItem: tabViewItemActual];
    
    NSTabView* tabViewActual = [[NSTabView alloc] init];
    [tabViewActual setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
    [tabViewItemActual setView: tabViewActual];
    [tabViewItemActual release];
    
    [records removeAllObjects];
    [lngs removeAllObjects];
    
    filelist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: stringsDirectory
                                                                   error: NULL];
    lengthFileList = [filelist count];
    for (int i = 0; i < lengthFileList; i++)
    {
        NSString* projectName = [filelist objectAtIndex: i];
        NSString* fullPathOfCurrentDir = [NSString stringWithFormat: @"%@/%@", stringsDirectory, projectName];
        if ([QOSharedLibrary isDirectory: fullPathOfCurrentDir] == YES) 
        {
            NSArray* filelistProject = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: fullPathOfCurrentDir
                                                                                           error: NULL];
            int lengthFileListProjecty = [filelistProject count];
            for (int j = 0; j < lengthFileListProjecty; j++)
            {
                NSString* notranslateFileName = [filelistProject objectAtIndex: j];
                if ([notranslateFileName rangeOfString: @"TRANSLAT"].location == NSNotFound &&
                    [notranslateFileName rangeOfString: @".txt"].location != NSNotFound)
                {
                    NSString* fileStrings = [NSString stringWithFormat: @"%@/%@", fullPathOfCurrentDir, notranslateFileName];
                    NSString* lng = [notranslateFileName stringByReplacingOccurrencesOfString: @".txt" 
                                                                                   withString: @""];    
                    if ([lngs indexOfObject: lng] == NSNotFound) 
                    {
                        [lngs addObject: lng];                
                    }
                    [QOSharedLibrary addToDictionary: &records
                                              forLng: lng 
                                          forProject: projectName
                                            fromFile: fileStrings 
                                        withEncoding: NSUTF16StringEncoding];
                }
            }
        }
    }
    [self outputSummaryDictionary: records forArrayWithLngs: lngs toTabView: tabViewActual type: TYPE_DICTIONARY_ACTUAL];
    [lngs release];
    [records release];
    [tabViewActual release];
    
    [appController.progressBar stopAnimation: self];
    [appController enableToolbar: YES];
    NSBeginAlertSheet(NSLocalizedString(@"Scan Succeeded", @"Scan Succeeded"), nil, nil, nil, MAINWINDOW, nil, nil, nil, nil, 
                      NSLocalizedString(@"No issues", @"No issues"));
    [plistProjects release];
    [tabViewMain release];
    [pool release];
}

#pragma mark -

- (void) startScan
{
    [appController enableToolbar: NO];
    thread = [[NSThread alloc] initWithTarget: self
                                               selector: @selector(scanThread)
                                                 object: nil];
    [thread start];
}

@end
