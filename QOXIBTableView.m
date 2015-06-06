//  QOLocalizableStrings
//
//  QOXIBTableView.m
//
//  Created by Sergey Krotkih on 07.03.11.
//  Copyright 2011 Quickoffice. All rights reserved.
//

#import "QOXIBTableView.h"
#import "QOSharedLibrary.h"
#import "QOTranslateStrings.h"
#import "QOLocalizableStringsController.h"

@implementation QOXIBTableView

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
    [thread retain];
    
    [super dealloc];
}

#pragma mark Handel context menu items
#pragma mark Apply data

-(BOOL) saveStrings: (NSString*) aStrings toXibFile: (NSString*) aXibFile toDirectory: (NSString*) directoryName
{
    NSString* targetFileName = [NSString stringWithFormat: @"%@/%@.strings", directoryName, aXibFile];
    NSString* workPath = [sourceFile stringByReplacingOccurrencesOfString: [sourceFile lastPathComponent] withString: @""];
    NSString* sourceFileName = [NSString stringWithFormat: @"%@%@.strings", workPath, aXibFile];
    NSError* error = nil;
    [[NSFileManager defaultManager] copyItemAtPath: sourceFileName 
                                            toPath: targetFileName 
                                             error: &error]; 
    if ([QOSharedLibrary mergeTranslatedStringsToFileName: targetFileName 
                                                     data: aStrings] == NO)
    {
        NSLog(@"!Error to save to %@", targetFileName);
        return NO;
    }
    return YES;
}

-(void) splitString: (NSString*) src xibFileName: (NSString**) pXibFileName string: (NSString**) pString
{
    NSArray* arr = [src componentsSeparatedByString: @"^"];
    *pXibFileName = [arr objectAtIndex: 0];
    *pString = [arr objectAtIndex: 1];    
}

-(BOOL) runImportStrings: (NSString*) aStrings toXibFile: (NSString*) aXibFile parentWindow: (NSWindow*) aParentWindow
{
    NSString* workPath = [sourceFile stringByReplacingOccurrencesOfString: [sourceFile lastPathComponent] withString: @""];
    NSString* stringsFile = [NSString stringWithFormat: @"%@%@.strings", workPath, aXibFile];
    if ([QOSharedLibrary mergeTranslatedStringsToFileName: stringsFile data: aStrings] == YES)
    {
        NSString* xibFile = [NSString stringWithFormat: @"%@/%@", targetFile, aXibFile];
        
        NSString* command = [NSString stringWithFormat: @"ibtool --import-strings-file %@ %@ --write %@", stringsFile, xibFile, xibFile];
        
        const char* cString = [command UTF8String];
        int result = system(cString);    
        
        if (result != 0) 
        {
            NSBeginAlertSheet(NSLocalizedString(@"Error", @"Error"), nil, nil, nil, aParentWindow, nil, nil, nil, nil, 
                              NSLocalizedString(@"Can't execute command. Return code is %d", @"Can't execute command. Return code is %d"), result);
            return NO;
        }
    }
    else 
    {
        NSBeginAlertSheet(NSLocalizedString(@"Warning!", @"Warning!"), nil, nil, nil, MAINWINDOW, nil, nil, nil, nil, 
                          NSLocalizedString(@"Data didn't save! May be list for save is empty.", @"Data didn't save! May be list for save is empty."));
        return NO;
    }
    return YES;
}

#pragma mark Save data

-(void) saveLocalizableStringsToXibWithDirectory: (NSString*) directoryName
{
    NSMutableArray* array = [[NSMutableArray alloc] init];
    for (int i = 0; i < [records count]; i++)
    {
        NSDictionary* currDict = [records objectAtIndex: i]; 
        NSString* value = [[currDict objectForKey: @"value"] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([value length] > 0) 
        {
            NSString* comment = [currDict objectForKey: @"comment"];
            comment = [comment stringByReplacingOccurrencesOfString: @"/*" withString: @""];    
            comment = [comment stringByReplacingOccurrencesOfString: @"*/" withString: @""];
            
            NSArray* lines_comment = [comment componentsSeparatedByString: @";"];
            if ([lines_comment count] > 0) 
            {
                for (int j = 0; j < [lines_comment count]; j++)
                {
                    NSString* currComment = [lines_comment objectAtIndex: j];
                    NSArray* xib_id = [currComment componentsSeparatedByString: @":"];
                    if ([xib_id count] == 2) 
                    {
                        NSString* object = [NSString stringWithFormat: @"%@ = \"%@\";\n", [xib_id objectAtIndex: 1], value];
                        [array addObject: [NSString stringWithFormat: @"%@^%@", [xib_id objectAtIndex: 0], object]];
                    }
                }
            }
            else 
            {
                NSArray* xib_id = [comment componentsSeparatedByString: @":"];
                if ([xib_id count] == 2) 
                {
                    NSString* object = [NSString stringWithFormat: @"%@ = \"%@\";\n", [xib_id objectAtIndex: 1], value];
                    [array addObject: [NSString stringWithFormat: @"%@^%@", [xib_id objectAtIndex: 0], object]];
                }
            }
        }
    }
    if ([array count] > 0) 
    {
        NSArray* sortedArray = [array sortedArrayUsingSelector: @selector(compare:)];
        NSString* oldXibFileName;
        NSString* oldObject;        
        int i = 0;
        int errorsCount = 0;
        [self splitString: [sortedArray objectAtIndex: i] 
              xibFileName: &oldXibFileName 
                   string: &oldObject];
        NSString* text = @"";
        while (i < [sortedArray count] && errorsCount == 0)
        {
            NSString* currXibFileName;
            NSString* currObject;        
            [self splitString: [sortedArray objectAtIndex: i] 
                  xibFileName: &currXibFileName 
                       string: &currObject];
            if ([oldXibFileName isEqualToString: currXibFileName]) 
            {
                text = [text stringByAppendingString: currObject]; 
            }
            else
            {
                if (directoryName == nil) 
                {
                    if ([self runImportStrings: text 
                                     toXibFile: oldXibFileName 
                                  parentWindow: MAINWINDOW] == NO)
                    {
                        errorsCount++;
                    }
                }
                else 
                {
                    if ([self saveStrings: text
                                toXibFile: oldXibFileName
                              toDirectory: directoryName] == NO)
                    {
                        errorsCount++;
                    }
                }
                
                text = [NSString stringWithString: currObject]; 
                oldXibFileName = [NSString stringWithString: currXibFileName];
            }
            i++;
        }
        if (errorsCount == 0) 
        {
            if (directoryName == nil) 
            {
                if ([self runImportStrings: text 
                                 toXibFile: oldXibFileName 
                              parentWindow: MAINWINDOW] == YES)
                {
                    NSBeginAlertSheet(NSLocalizedString(@"Data saved successfully", @"Data saved successfully"), nil, nil, nil, MAINWINDOW, nil, nil, nil, nil, 
                                      [NSString stringWithFormat: NSLocalizedString(@"New strings saved to the project '%@'", @"New strings saved to the project '%@'"), projectName]);
                }
            }
            else 
            {
                if ([self saveStrings: text
                            toXibFile: oldXibFileName
                          toDirectory: directoryName] == YES)
                {
                    NSBeginAlertSheet(NSLocalizedString(@"Data saved successfully", @"Data saved successfully"), nil, nil, nil, MAINWINDOW, nil, nil, nil, nil, 
                                      [NSString stringWithFormat: NSLocalizedString(@"Data saved to the directory '%@'", @"Data saved to the directory '%@'"), directoryName]);
                }
            }
        }
    }
    else 
    {
        NSBeginAlertSheet(NSLocalizedString(@"Data didn't save!", @"Data didn't save"), nil, nil, nil, MAINWINDOW, nil, nil, nil, nil, 
                          NSLocalizedString(@"The data lists for import to the XIBs are empty!", @"The data lists for import to the XIBs are empty!"));
    }
    [array release];
}

-(void) saveLocalizableStringsToXibThread
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init]; 
    [appController.progressBar startAnimation: appController];
    
    [self saveLocalizableStringsToXibWithDirectory: nil];

    [appController.progressBar stopAnimation: appController];
    [pool release];
}

-(void) saveLocalizableStringsToXib :(id) sender
{
    thread = [[NSThread alloc] initWithTarget: self
                                               selector: @selector(saveLocalizableStringsToXibThread)
                                                 object: nil];
    [thread start];
}    

#pragma mark save as ibtool format

-(void) saveAsIbToolFormatToDirectoryThread: (NSString*)directoryName
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init]; 
    [appController.progressBar startAnimation: appController];
    
    [self saveLocalizableStringsToXibWithDirectory: directoryName];    

    [appController.progressBar stopAnimation: appController];
    [pool release];
}

-(void) saveAsIbToolFormatToDirectory: (NSString*) directoryName
{
    [QOSharedLibrary createDirectory: directoryName];
    if ([[NSFileManager defaultManager] fileExistsAtPath: directoryName] == NO) 
    {
        NSBeginAlertSheet(NSLocalizedString(@"Data didn't save!", @"Data didn't save!"), nil, nil, nil, MAINWINDOW, nil, nil, nil, nil, 
                          [NSString stringWithFormat: NSLocalizedString(@"Directory '%@' doesn't exist!", @"Directory '%@' doesn't exist!"), directoryName]);
        return;
    }

    if (thread != nil) 
    {
        [thread cancel];
        [thread release];
    }
    
    thread = [[NSThread alloc] initWithTarget: self
                                     selector: @selector(saveAsIbToolFormatToDirectoryThread:)
                                       object: directoryName];

    [thread start];
}

-(void) saveAsIbToolFormat: (id) sender
{
    [QOSharedLibrary afterSaveToDirectoryDialogforWindow: MAINWINDOW 
                                            callSelector: @selector(saveAsIbToolFormatToDirectory:) 
                                                  forObj: self]; 
}

#pragma mark -
#pragma mark context menu

-(void)setTypeFile: (TYPE_FILE)aTypeFile
{
    typeFile = aTypeFile;
    contextMenu = [[NSMenu alloc] initWithTitle :@"LocalizableXIBs"];
    [contextMenu addItem: [[[NSMenuItem alloc] initWithTitle: NSLocalizedString(@"Save data to the temporary file", @"Save data to the temporary file") 
                                                      action: @selector(save:) 
                                               keyEquivalent: @""] autorelease]];        
    [contextMenu addItem: [[[NSMenuItem alloc] initWithTitle: NSLocalizedString(@"Reload data from the temporary file", @"Reload data from the temporary file") 
                                                      action: @selector(reloadData:) 
                                               keyEquivalent: @""] autorelease]];                
    [contextMenu addItem: [NSMenuItem separatorItem]];
    [contextMenu addItem: [[[NSMenuItem alloc] initWithTitle: NSLocalizedString(@"Save as file of the property list (plist) type", @"Save as file of the property list (plist) type") 
                                                      action: @selector(saveAsPlist:) 
                                               keyEquivalent: @""] autorelease]];
    [contextMenu addItem: [[[NSMenuItem alloc] initWithTitle: NSLocalizedString(@"Save as file of the localizable.strings type", @"Save as file of the localizable.strings type") 
                                                      action: @selector(saveAsLocalizableStrings:) 
                                               keyEquivalent: @""] autorelease]];
    [contextMenu addItem: [[[NSMenuItem alloc] initWithTitle: NSLocalizedString(@"Save as file of the ibtool format type", @"Save as file of the ibtool format type") 
                                                      action: @selector(saveAsIbToolFormat:) 
                                               keyEquivalent: @""] autorelease]];
    [contextMenu addItem: [[[NSMenuItem alloc] initWithTitle: NSLocalizedString(@"Save as...", @"Save as...") 
                                                      action: @selector(saveAs:) 
                                               keyEquivalent: @""] autorelease]];            

    if (typeFile == TYPE_DATA_NEW)
    {
        [contextMenu addItem: [NSMenuItem separatorItem]];
        [contextMenu addItem: [[[NSMenuItem alloc] initWithTitle: NSLocalizedString(@"Translate it!", @"Translate it!") 
                                                          action: @selector(translateIt:) 
                                                   keyEquivalent: @""] autorelease]];        
        [contextMenu addItem: [[[NSMenuItem alloc] initWithTitle: [NSString stringWithFormat: NSLocalizedString(@"Apply data (save the new strings to the project '%@')", @"Apply data (save the new strings to the project '%@')"), projectName] 
                                                          action: @selector(saveLocalizableStringsToXib:) 
                                                   keyEquivalent: @""] autorelease]];        
    }
    
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
    
    [contextMenu addItem: [NSMenuItem separatorItem]];
    checkSimilarMenuItem = [[NSMenuItem alloc] initWithTitle: NSLocalizedString(@"Search similar strings", @"Search similar strings") 
                                                      action: @selector(searchSimilarStrings:) 
                                               keyEquivalent: @""];
    [contextMenu addItem: checkSimilarMenuItem];
    
    [tableView setMenu: contextMenu];    
}

@end
