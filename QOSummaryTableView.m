//  GenStringResources
//
//  QOSummaryTableView.m
//
//  Created by Sergey Krotkih on 3/14/11.
//  Copyright 2011 Quickoffice. All rights reserved.
//

#import "QOSummaryTableView.h"
#import "GenStringResourcesController.h"
#import "QOTranslateStrings.h"
#import "QOSummaryStrings.h"
#import "QOSharedLibrary.h"
#import "QOPlistProcessing.h"

@implementation QOSummaryTableView

@synthesize typeFile;

- (id) initWithDictionary: (NSMutableArray*) aRecords lng: (NSString*)aLng
{
	if ((self = [super init]))
	{	
        appController = [GenStringResourcesController appController];
        [self setHasVerticalScroller: YES];
        [self setHasHorizontalScroller: YES];

        targetLanguage = [NSString stringWithString: aLng];
        
        NSMutableArray* lngrecords = [[NSMutableArray alloc] init];
        NSEnumerator* srcStream = [aRecords objectEnumerator];    
        NSDictionary* dict;
        while ((dict = [srcStream nextObject]) != nil)
        {
            if ([[dict objectForKey: @"lng"] isEqualToString: targetLanguage]) 
            {
                [lngrecords addObject: dict];
            }
        }
        
        NSString* text;
        [QOSharedLibrary saveDictionary: lngrecords toText: &text];
        NSMutableDictionary* lngDictionary = [QOSharedLibrary dictionaryFromLocalizedStringText: text];
        NSArray* arrSort = [[lngDictionary allKeys] sortedArrayUsingSelector: @selector(compare:)];
        
        records = [[NSMutableArray alloc] init];
        int i = 0;
        while (i < [arrSort count])
        {
            NSString* pair = [arrSort objectAtIndex: i];
            NSArray* arrpair = [pair componentsSeparatedByString: @" = "];
            NSString* key = [[arrpair objectAtIndex: 0] substringFromIndex: 1];
            NSString* value = [[arrpair objectAtIndex: 1] substringFromIndex: 1];
            key = [key substringToIndex: [key length] - 1];
            value = [value substringToIndex:  [value length] - 2];
            NSString* comment = @""; 
            NSString* project = @""; 
            NSEnumerator* srcStream = [lngrecords objectEnumerator];    
            NSDictionary* dict;
            while ((dict = [srcStream nextObject]) != nil) 
            {
                NSString* key2 = [dict objectForKey: @"key"];
                NSString* value2 = [dict objectForKey: @"value"];
                if ([key2 isEqualToString: key] && [value2 isEqualToString: value]) 
                {
                    comment = [comment stringByAppendingString: [dict objectForKey: @"comment"]]; 
                    project = [project stringByAppendingString: [dict objectForKey: @"project"]]; 
                    project = [project stringByAppendingString: @";"]; 
                }
            }
            NSArray* keys = [NSArray arrayWithObjects: @"lng", @"key", @"value", @"comment", @"project", nil];
            NSArray* objects = [NSArray arrayWithObjects: targetLanguage, key, value, comment, project, nil];
            NSMutableDictionary* dictionary = [NSMutableDictionary dictionaryWithObjects: objects forKeys: keys];
            [records addObject: dictionary];
            while (i < [arrSort count] && [pair isEqualToString: [arrSort objectAtIndex: i]])
            {
                i++;
            }
        }
        [lngrecords release];
        repeatedStrings = [[NSMutableArray alloc] init];
        if ([records count] > 0) 
        {
            NSMutableString* oldKey = [[NSMutableString alloc] initWithString: @""];
            for (int i = 0; i < [records count]; i++)
            {
                NSDictionary* currDict = [records objectAtIndex: i];
                NSString* currKey = [currDict objectForKey: @"key"];
                if ([oldKey isEqualToString: currKey] == YES)
                {
                    [repeatedStrings addObject: currKey];
                    [oldKey setString: currKey];
                }
            }
            [oldKey release];
        }
        
        tableView = [[NSTableView alloc] init];    
        [tableView setDelegate: self];
        [tableView setDataSource: self];                
        [tableView setRowHeight: 18];

        NSArray* sortDescriptors = [NSArray arrayWithObjects: 
                                    [[[NSSortDescriptor alloc] initWithKey: @"key" 
                                                                 ascending: YES] autorelease], 
                                    [[[NSSortDescriptor alloc] initWithKey: @"value" 
                                                                 ascending: YES] autorelease], 
                                    [[[NSSortDescriptor alloc] initWithKey: @"comment" 
                                                                 ascending: YES] autorelease], 
                                    [[[NSSortDescriptor alloc] initWithKey: @"project" 
                                                                 ascending: YES] autorelease], 
                                    nil];
        [tableView setSortDescriptors: sortDescriptors];
        [tableView setTarget: self];
        
        NSTableColumn* theColumn = [[[NSTableColumn alloc] initWithIdentifier: @"key"] autorelease];
        [theColumn.headerCell setStringValue: NSLocalizedString(@"String in English", @"String in English")]; 
        [theColumn setSortDescriptorPrototype: [[[NSSortDescriptor alloc] initWithKey: @"key" 
                                                                            ascending: YES] autorelease]];
        [theColumn setWidth: 150];
        [theColumn setMinWidth: 100];
        [tableView addTableColumn: theColumn];

        theColumn = [[[NSTableColumn alloc] initWithIdentifier: @"value"] autorelease];
        [theColumn.headerCell setStringValue: NSLocalizedString(@"Translation", @"Translation")]; 
        [theColumn setSortDescriptorPrototype: [[[NSSortDescriptor alloc] initWithKey: @"value" ascending: YES] autorelease]];
        [theColumn setWidth: 200];
        [theColumn setMinWidth: 100];
        [tableView addTableColumn: theColumn];        
        
        theColumn = [[[NSTableColumn alloc] initWithIdentifier: @"comment"] autorelease];
        [theColumn.headerCell setStringValue: NSLocalizedString(@"Comment", @"Comment")]; 
        [theColumn setSortDescriptorPrototype: [[[NSSortDescriptor alloc] initWithKey: @"comment" 
                                                                            ascending: YES] autorelease]];
        [theColumn setWidth: 200];
        [theColumn setMinWidth: 100];
        [tableView addTableColumn: theColumn];        
        
        theColumn = [[[NSTableColumn alloc] initWithIdentifier: @"project"] autorelease];
        [theColumn.headerCell setStringValue: NSLocalizedString(@"Project", @"Project")]; 
        [theColumn setSortDescriptorPrototype: [[[NSSortDescriptor alloc] initWithKey: @"project" 
                                                                            ascending: YES] autorelease]];
        [theColumn setWidth: 100];
        [theColumn setMinWidth: 100];
        [tableView addTableColumn: theColumn];        
        
        [self setDocumentView: tableView];
        [tableView reloadData]; 
        
        sourceFile = nil;
        targetFile = nil;
        similarStrings = [[NSMutableArray alloc] init];
        isShowSimilarStrings = NO;
        
    }
	
	return self;
}

- (void) dealloc
{
    [repeatedStrings release];
    [tableView release];
    [thread release];
    
    [super dealloc];
}

#pragma mark handle menu items
#pragma mark Apply data

-(void) applyData: (id) sender
{
    NSEnumerator* dictsStream = [records objectEnumerator];    
    NSDictionary* currDict;
    NSMutableArray* projectNameArray = [[NSMutableArray alloc] init];
    
    while ((currDict = [dictsStream nextObject]) != nil)
    {
        NSArray* projects = [[currDict objectForKey: @"project"] componentsSeparatedByString: @";"];
        for (int i = 0; i < [projects count]; i++)
        {
            NSString* project = [[projects objectAtIndex: i] stringByReplacingOccurrencesOfString: @" " 
                                                                                       withString: @""];    
            if ([project length] > 0) 
            {
                if ([projectNameArray indexOfObject: project] == NSNotFound) 
                {
                    [projectNameArray addObject: project];
                }
            }
        }
    }

    NSString* workDirectory = [QOPlistProcessing workDirectory];
    NSEnumerator* projectNameStream = [projectNameArray objectEnumerator];    
    NSString* currProjectName;
    while ((currProjectName = [projectNameStream nextObject]) != nil)
    {
        NSEnumerator* dictsStream = [records objectEnumerator];    
        NSDictionary* currDict;
        NSString* text = @""; 
        while ((currDict = [dictsStream nextObject]) != nil)
        {
            NSArray* projects = [[currDict objectForKey: @"project"] componentsSeparatedByString: @";"];
            for (int i = 0; i < [projects count]; i++)
            {
                NSString* project = [[projects objectAtIndex: i] stringByReplacingOccurrencesOfString: @" " 
                                                                                           withString: @""];    
                if ([project isEqualToString: currProjectName] == YES) 
                {
                    NSString* value = [[currDict objectForKey: @"value"] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    if ([value isEqualToString: @""] == NO) 
                    {
                        text = [text stringByAppendingFormat: @"\"%@\" = \"%@\";\n", [currDict objectForKey: @"key"], value];
                    }
                }
            }
        }
        NSString* fileStrings;
        if ([currProjectName rangeOfString: @"(XIB)"].location == NSNotFound)
        {
            fileStrings = [NSString stringWithFormat: @"%@/Strings/%@/%@_NO_TRANSLATION.txt", workDirectory, currProjectName, targetLanguage];
        }
        else 
        {
            currProjectName = [currProjectName stringByReplacingOccurrencesOfString: @"(XIB)" 
                                                                         withString: @""];    
            fileStrings = [NSString stringWithFormat: @"%@/XIBs/%@/%@.lproj/Localizable.strings", workDirectory, currProjectName, targetLanguage];
        }
        [QOSharedLibrary mergeTranslatedStringsToFileName: fileStrings data: text];
                     
    }
    [projectNameArray release];
    NSBeginAlertSheet(NSLocalizedString(@"Data were applyed.", @"Data were applyed."), nil, nil, nil, MAINWINDOW, nil, nil, nil, nil, 
                      NSLocalizedString(@"You may move string or XIBs to the 'no translate' position and then start 'Reload data'.", @"You may move string or XIBs to the 'no translate' position and then start 'Reload data'."));
}

#pragma mark -
#pragma mark Translate strings

-(void) translateItThread
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init]; 
    [appController.progressBar startAnimation: appController];
    QOTranslateStrings* translateResourcesController = [[QOTranslateStrings alloc] initWithWindow: MAINWINDOW];
    [translateResourcesController translateArrayOfDictionarys: records 
                                               targetLanguage: targetLanguage];
    [translateResourcesController release];
    NSBeginAlertSheet(NSLocalizedString(@"The operation of translation of the string resources has finished successfully", @"The operation of translation of the string resources has finished successfully"), nil, nil, nil, MAINWINDOW, nil, nil, nil, nil, 
                      NSLocalizedString(@"No issues", @"No issues"));
    [tableView reloadData];
    [appController.progressBar stopAnimation: appController];
    [pool release];
}

-(void) translateIt: (id) sender
{
    thread = [[NSThread alloc] initWithTarget: self
                                               selector: @selector(translateItThread)
                                                 object: nil];
    [thread start];
}

#pragma mark context menu

-(void)setTypeFile: (TYPE_FILE)aTypeFile
{
    typeFile = aTypeFile;
    contextMenu = [[NSMenu alloc] initWithTitle: @"SummaryTableView"];
    
    [contextMenu addItem: [[[NSMenuItem alloc] initWithTitle: NSLocalizedString(@"Save data to file as property list (plist) type", @"Save data to file as property list (plist) type") 
                                                      action: @selector(saveAsPlist:) 
                                               keyEquivalent: @""] autorelease]];
    [contextMenu addItem: [[[NSMenuItem alloc] initWithTitle: NSLocalizedString(@"Save data to file as localizable.strings type", @"Save data to file as localizable.strings type") 
                                                      action: @selector(saveAsLocalizableStrings:) 
                                               keyEquivalent: @""] autorelease]];
    if (typeFile == TYPE_NO_TRANSLATION)
    {
        [contextMenu addItem: [NSMenuItem separatorItem]];
        [contextMenu addItem: [[[NSMenuItem alloc] initWithTitle: NSLocalizedString(@"Translate it!", @"Translate it!") 
                                                          action: @selector(translateIt:) 
                                                   keyEquivalent: @""] autorelease]];
        [contextMenu addItem: [[[NSMenuItem alloc] initWithTitle: NSLocalizedString(@"Apply data (save data to the strings and XIB tabs)", @"Apply data (save data to the strings and XIB tabs)") 
                                                          action: @selector(applyData:) 
                                                   keyEquivalent: @""] autorelease]];        
        [contextMenu addItem: [NSMenuItem separatorItem]];
        [contextMenu addItem: [[[NSMenuItem alloc] initWithTitle: NSLocalizedString(@"Load string resources from the plist file", @"Load string resources from the plist file") 
                                                          action: @selector(loadStringsFromPlist:) 
                                                   keyEquivalent: @""] autorelease]];        
        [contextMenu addItem: [[[NSMenuItem alloc] initWithTitle: NSLocalizedString(@"Load string resources from the localizable.strings file", @"Load string resources from the localizable.strings file") 
                                                          action: @selector(loadStringsFromLocalizableStrings:) 
                                                   keyEquivalent: @""] autorelease]];        
        [contextMenu addItem: [[[NSMenuItem alloc] initWithTitle: NSLocalizedString(@"Merge string resources from the localizable.strings file", @"Merge string resources from the localizable.strings file") 
                                                          action: @selector(mergeStrings:) 
                                                   keyEquivalent: @""] autorelease]];        
    } 
    [contextMenu addItem: [NSMenuItem separatorItem]];
    checkSimilarMenuItem = [[NSMenuItem alloc] initWithTitle: NSLocalizedString(@"Start looking for the similar strings", @"Start looking for the similar strings") 
                                                      action: @selector(searchSimilarStrings:) 
                                               keyEquivalent: @""];
    [contextMenu addItem: checkSimilarMenuItem];
    
    [tableView setMenu: contextMenu];    
}

@end
