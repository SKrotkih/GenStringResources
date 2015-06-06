//  QOLocalizableStrings
//
//  QOStringsTableView.m
//
//  Created by Sergey Krotkih on 23.02.11.
//  Copyright 2011 Quickoffice. All rights reserved.
//

#import "QOStringsTableView.h"
#import "QOSharedLibrary.h"
#import "QOTranslateStrings.h"
#import "QOLocalizableStringsController.h"
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
        appController = [QOLocalizableStringsController appController];
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
        NSBeginAlertSheet(NSLocalizedString(@"Data saved successfully", @"Data saved successfully"), nil, nil, nil, MAINWINDOW, nil, nil, nil, nil, 
                          NSLocalizedString(@"Select NEW tab and choise 'Reload data' from context menu", @"Select NEW tab and choise 'Reload data' from context menu"));
    }
    else 
    {
        NSBeginAlertSheet(NSLocalizedString(@"Warning!", @"Warning!"), nil, nil, nil, MAINWINDOW, nil, nil, nil, nil, 
                          NSLocalizedString(@"Data didn't save!", @"Data didn't save!"));
    }
}

#pragma mark Context menu

-(void)setTypeFile: (TYPE_FILE)aTypeFile
{
    typeFile = aTypeFile;
    
    contextMenu = [[NSMenu alloc] initWithTitle :@"LocalizableStrings"];
    
    [contextMenu addItem: [[[NSMenuItem alloc] initWithTitle: NSLocalizedString(@"Save data to the temporary file", @"Save data to the temporary file") 
                                                      action: @selector(save:) 
                                               keyEquivalent: @""] autorelease]];        
    [contextMenu addItem: [[[NSMenuItem alloc] initWithTitle: NSLocalizedString(@"Reload data from temporary file", @"Reload data from temporary file") 
                                                      action: @selector(reloadData:) 
                                               keyEquivalent: @""] autorelease]];                
    [contextMenu addItem: [NSMenuItem separatorItem]];
    [contextMenu addItem: [[[NSMenuItem alloc] initWithTitle: NSLocalizedString(@"Save as file of the localizable.strings type", @"Save as file of the localizable.strings type") 
                                                      action: @selector(saveAsLocalizableStrings:) 
                                               keyEquivalent: @""] autorelease]];
    [contextMenu addItem: [[[NSMenuItem alloc] initWithTitle: NSLocalizedString(@"Save as file of the property list (plist) type", @"Save as file of the property list (plist) type") 
                                                      action: @selector(saveAsPlist:) 
                                               keyEquivalent: @""] autorelease]];
    [contextMenu addItem: [[[NSMenuItem alloc] initWithTitle: NSLocalizedString(@"Save as...", @"Save as...") 
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
        [contextMenu addItem: [[[NSMenuItem alloc] initWithTitle: NSLocalizedString(@"Load strings from a file of the plist type", @"Load strings from a file of the plist type") 
                                                          action: @selector(loadStringsFromPlist:) 
                                                   keyEquivalent: @""] autorelease]];        
        [contextMenu addItem: [[[NSMenuItem alloc] initWithTitle: NSLocalizedString(@"Load strings from a file of the localizable.strings type", @"Load strings from a file of the localizable.strings type") 
                                                          action: @selector(loadStringsFromLocalizableStrings:) 
                                                   keyEquivalent: @""] autorelease]];        
        [contextMenu addItem: [[[NSMenuItem alloc] initWithTitle: NSLocalizedString(@"Merge strings from a file of the localizable.strings format", @"Merge strings from a file of the localizable.strings format") 
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
    checkSimilarMenuItem = [[NSMenuItem alloc] initWithTitle: NSLocalizedString(@"Search similar strings", @"Search similar strings") 
                                                      action: @selector(searchSimilarStrings:) 
                                               keyEquivalent: @""];
    [contextMenu addItem: checkSimilarMenuItem];
    
    [tableView setMenu: contextMenu];    
}

@end
