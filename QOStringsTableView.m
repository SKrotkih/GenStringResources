//  GenStringResources
//
//  QOStringsTableView.m
//
//  Created by Sergey Krotkih on 23.02.11.
//  Copyright 2011 Quickoffice. All rights reserved.
//

#import "QOStringsTableView.h"
#import "QOSharedLibrary.h"
#import "QOTranslateStrings.h"
#import "GenStringResourcesController.h"
#import "QOCompareStrings.h"

@implementation QOStringsTableView

@synthesize typeFile;

-(id) initWithFile: (NSString*)aFileName encoding: (NSStringEncoding)enc projectName: (NSString*)aProjectName lng: (NSString*)aLng
{
    if ((self = [super initWithFile: aFileName
                           encoding: enc
                        projectName: aProjectName
                                lng: aLng]))
    {
        appController = [GenStringResourcesController appController];
    }

    return self;
}

-(void) dealloc
{
    [super dealloc];
}

#pragma mark handle menu items

-(void) saveTranslationData :(id) sender
{
    NSString* newStringsFileName = [sourceFile stringByReplacingOccurrencesOfString: @"_NO_TRANSLATION" withString: @""];    
    
    NSString* text = @"";
    [QOSharedLibrary saveDictionary: records 
                             toText: &text];    
    if ([QOSharedLibrary mergeTranslatedStringsToFileName: newStringsFileName 
                                                     data: text] == YES)
    {
        NSBeginAlertSheet(NSLocalizedString(@"Data were saved successfully", @"Data were saved successfully"), nil, nil, nil, MAINWINDOW, nil, nil, nil, nil, 
                          NSLocalizedString(@"Select NEW tab and choise 'Reload data' in context menu", @"Select NEW tab and choise 'Reload data' in context menu"));
    }
    else 
    {
        NSBeginAlertSheet(NSLocalizedString(@"Warning!", @"Warning!"), nil, nil, nil, MAINWINDOW, nil, nil, nil, nil, 
                          NSLocalizedString(@"Couldn't save data!", @"Couldn't save data!"));
    }
}

#pragma mark Context menu

-(void)setTypeFile: (TYPE_FILE)aTypeFile
{
    typeFile = aTypeFile;
    
    contextMenu = [[NSMenu alloc] initWithTitle :@"LocalizableStrings"];
    
    [contextMenu addItem: [[[NSMenuItem alloc] initWithTitle: NSLocalizedString(@"Save data to temporary file", @"Save data to temporary file") 
                                                      action: @selector(save:) 
                                               keyEquivalent: @""] autorelease]];        
    [contextMenu addItem: [[[NSMenuItem alloc] initWithTitle: NSLocalizedString(@"Start reloading data from the temporary file", @"Start reloading data from the temporary file") 
                                                      action: @selector(reloadData:) 
                                               keyEquivalent: @""] autorelease]];                
    [contextMenu addItem: [NSMenuItem separatorItem]];
    [contextMenu addItem: [[[NSMenuItem alloc] initWithTitle: NSLocalizedString(@"Save data to file as localizable.strings type", @"Save data to file as localizable.strings type") 
                                                      action: @selector(saveAsLocalizableStrings:) 
                                               keyEquivalent: @""] autorelease]];
    [contextMenu addItem: [[[NSMenuItem alloc] initWithTitle: NSLocalizedString(@"Save data to file as property list (plist) type", @"Save data to file as property list (plist) type") 
                                                      action: @selector(saveAsPlist:) 
                                               keyEquivalent: @""] autorelease]];
    [contextMenu addItem: [[[NSMenuItem alloc] initWithTitle: NSLocalizedString(@"Save data to file as ... type", @"Save data to file as ... type") 
                                                      action: @selector(saveAs:) 
                                               keyEquivalent: @""] autorelease]];            
    if (typeFile == TYPE_DATA_NO_TRANSLATION)
    {
        [contextMenu addItem: [NSMenuItem separatorItem]];
        [contextMenu addItem: [[[NSMenuItem alloc] initWithTitle: NSLocalizedString(@"Translate it!", @"Translate it!") 
                                                          action: @selector(translateIt:) 
                                                   keyEquivalent: @""] autorelease]];        
        [contextMenu addItem: [[[NSMenuItem alloc] initWithTitle: NSLocalizedString(@"Apply data (save translated data)", @"Apply data (save translated data)") 
                                                          action: @selector(saveTranslationData:) 
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
    if (typeFile == TYPE_DATA_NEW)
    {
        [contextMenu addItem: [NSMenuItem separatorItem]];
        [contextMenu addItem: [[[NSMenuItem alloc] initWithTitle: NSLocalizedString(@"Apply data (save the new strings resources to the project)", @"Apply data (save the new strings resources to the project)") 
                                                          action: @selector(saveLocalizableStrings:) 
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
