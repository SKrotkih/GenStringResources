//  GenStringResources
//
//  GenStringResourcesTableView.m
//
//  Created by Sergey Krotkih on 23.02.11.
//  Copyright 2011 Quickoffice. All rights reserved.
//

#import "GenStringResourcesTableView.h"
#import "QOSharedLibrary.h"
#import "QOTranslateStrings.h"
#import "GenStringResourcesController.h"
#import "QOCompareStrings.h"

@implementation GenStringResourcesTableView

@synthesize appController;
@synthesize sourceFile;
@synthesize targetFile;
@synthesize records;
@synthesize tableView;

- (id) initWithFile: (NSString*) aFileName encoding: (NSStringEncoding) enc projectName: (NSString*) aProjectName lng: (NSString*) aLng
{
    if ((self = [super init]))
    {
        appController = [GenStringResourcesController appController];
        [self setHasVerticalScroller: YES];
        [self setHasHorizontalScroller: YES];
        [self setAutohidesScrollers: YES];
        [self setBorderType: NSBezelBorder];
        
        NSError* error = nil;
        NSString* text = [NSString stringWithContentsOfFile: aFileName encoding: enc error: &error];

        if (text != nil && [text length] > 0)
        {
            projectName = [aProjectName copy];
            targetLanguage = [aLng copy];
            
            records = [[NSMutableArray alloc] init];
            [QOSharedLibrary addToDictionary: &records
                                      forLng: aLng 
                                  forProject: projectName
                                    fromFile: aFileName  
                                withEncoding: enc];
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
                                        nil];
            [tableView setSortDescriptors: sortDescriptors];
            [tableView setTarget: self];
            
            NSTableColumn* theColumn = [[[NSTableColumn alloc] initWithIdentifier: @"key"] autorelease];
            [theColumn.headerCell setStringValue: NSLocalizedString(@"String in English",  @"English string column name")]; 
            [theColumn setSortDescriptorPrototype: [[[NSSortDescriptor alloc] initWithKey: @"key" 
                                                                                ascending: YES] autorelease]];
            [theColumn setWidth: 150];
            [theColumn setMinWidth: 100];
            [tableView addTableColumn: theColumn];
            
            theColumn = [[[NSTableColumn alloc] initWithIdentifier: @"value"] autorelease];
            [theColumn.headerCell setStringValue: NSLocalizedString(@"Translation", @"Translation")]; 
            [theColumn setSortDescriptorPrototype: [[[NSSortDescriptor alloc] initWithKey: @"value" 
                                                                                ascending: YES] autorelease]];
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
            
            [self setDocumentView: tableView];
        }
        
        sourceFile = nil;
        targetFile = nil;
        similarStrings = [[NSMutableArray alloc] init];
        isShowSimilarStrings = NO;
    }
    
    return self;
}

-(void) dealloc
{
    [tableView release];
    [sourceFile release];
    [targetFile release];
    [similarStrings release];
    [repeatedStrings release];
    [checkSimilarMenuItem release];
    [thread release];
    
    [super dealloc];
}

#pragma mark implementation of the NSTableViewDataSource NSTableViewDelegate protocols

- (CGFloat) tableView: (NSTableView*) tableView heightOfRow: (NSInteger) row
{
    return 18;
}

- (NSInteger) numberOfRowsInTableView: (NSTableView* ) aTableView
{
    return [records count];
}

- (id) tableView: (NSTableView*) aTableView objectValueForTableColumn: (NSTableColumn* ) aTableColumn row: (NSInteger) rowIndex
{
    NSDictionary* theRecord;
    id theValue;
    
    NSParameterAssert(rowIndex >= 0 && rowIndex < [records count]);

    theRecord = [records objectAtIndex: rowIndex];
    theValue = [theRecord objectForKey: [aTableColumn identifier]];

    return theValue;
}

- (NSCell*) tableView: (NSTableView*) tableView dataCellForTableColumn: (NSTableColumn*) tableColumn row: (NSInteger) rowIndex
{
    NSDictionary* theRecord;
    id thekey, theValue;
    
    theRecord = [records objectAtIndex: rowIndex];
    thekey = [theRecord objectForKey: @"key"];
    theValue = [theRecord objectForKey: @"value"];
    NSTextFieldCell* cell = [tableColumn dataCell];
    
    if ([theValue rangeOfString: @"TRANSLAT"].location != NSNotFound)
    {
        [cell setTextColor: [NSColor redColor]];
    }
    else if ([repeatedStrings indexOfObject: [theRecord objectForKey: @"key"]] != NSNotFound)
    {
        [cell setTextColor: [NSColor blueColor]];
    }
    else if (isShowSimilarStrings == YES && [similarStrings count] > 0)
    {
        for (NSDictionary* currDict in similarStrings)
        {
            if ([[currDict objectForKey: @"key"] isEqualToString: thekey] == YES)
            {
                [cell setTextColor: [currDict objectForKey: @"color"]];
                break;
            }
        }
    }
    else
    {
        [cell setTextColor: [NSColor blackColor]];
    }
    
    return cell;
}

- (void)tableView:(NSTableView* )aTableView setObjectValue: (id)anObject forTableColumn: (NSTableColumn* )aTableColumn row: (NSInteger)rowIndex
{
    NSString* columnName = [aTableColumn identifier];

    if ([columnName isEqualToString: @"key"] == NO)
    {
        NSMutableDictionary*  dict = [records objectAtIndex: rowIndex];
        [dict setObject: anObject forKey: columnName];
    }
    [tableView reloadData];
}

- (void)tableView:(NSTableView* )aTableView sortDescriptorsDidChange: (NSArray* )oldDescriptors
{
    [records sortUsingDescriptors: [tableView sortDescriptors]];
    [tableView reloadData];
}

- (BOOL) tableView: (NSTableView*) aTableView shouldSelectRow: (NSInteger) rowIndex
{
    if (isShowSimilarStrings == YES)
    {
        NSString* currKey = [[records objectAtIndex: rowIndex] objectForKey: @"key"];
        [similarStrings removeAllObjects];
        NSEnumerator* dictsStream = [records objectEnumerator];    
        NSDictionary* currDict;

        while ((currDict = [dictsStream nextObject]) != nil)
        {
            NSString* key = [currDict objectForKey: @"key"];
            CGFloat distance = [QOCompareStrings distanceSimilarStrings: key secondStr: currKey];
            NSColor* color = [NSColor colorWithCalibratedRed: 0.0 green: 0.0 blue: 0.0 alpha: (1.0/distance)];
            NSArray* keys = [[NSArray alloc] initWithObjects: @"key", @"color", nil];
            NSArray* objs = [[NSArray alloc] initWithObjects: key, color, nil];
            NSDictionary* dict = [[NSDictionary alloc] initWithObjects: objs 
                                                               forKeys: keys];
            [objs release];
            [keys release];
            [similarStrings addObject: dict];
            [dict release];
        }
        [tableView reloadData];
    }
    
    return YES;
}

#pragma mark handle context menu

-(void) saveContentToFile: (NSString*)fileName
{
    [QOSharedLibrary saveDictionary: records
                             toFile: fileName 
                       withEncoding: NSUTF16StringEncoding];
}

// Save data to the temporary file
-(void) save: (id) sender
{
    [self saveContentToFile: sourceFile];
}

#pragma mark saveAs

-(void) saveAsToFile: (NSString*) fileName
{
    [self saveContentToFile: fileName];
}

-(void) saveAs :(id) sender
{
    [QOSharedLibrary afterSaveDialogforWindow: MAINWINDOW 
                                 callSelector: @selector(saveAsToFile:) 
                                       forObj: self]; 
}

#pragma mark saveAsLocalizableStrings

-(void) saveAsLocalizableStringsToFile: (NSString*) fileName
{
    [self saveContentToFile: [NSString stringWithFormat: @"%@.strings", fileName]];
}

-(void) saveAsLocalizableStrings: (id) sender
{
    [QOSharedLibrary afterSaveDialogforWindow: MAINWINDOW 
                                 callSelector: @selector(saveAsLocalizableStringsToFile:) 
                                       forObj: self]; 
}

#pragma mark saveAsPlist

-(void) saveAsPlistToFile: (NSString*) fileName
{
    [records writeToFile: [NSString stringWithFormat: @"%@.plist", fileName] 
              atomically: YES];
}

-(void) saveAsPlist: (id)sender
{
    [QOSharedLibrary afterSaveDialogforWindow: MAINWINDOW 
                                 callSelector: @selector(saveAsPlistToFile:) 
                                       forObj: self]; 
}

-(void) saveLocalizableStrings :(id) sender
{
    NSString* text = @"";
    [QOSharedLibrary saveDictionary: records toText: &text];    
    [QOSharedLibrary saveLocalizableStrings: targetFile content: text];
    NSBeginAlertSheet(NSLocalizedString(@"Data were saved successfully", @"Data were saved successfully"), nil, nil, nil, MAINWINDOW, nil, nil, nil, nil, 
                      NSLocalizedString(@"The new localizable.strings file was saved", @"The new localizable.strings file was saved"));
}

#pragma mark Load string from file

-(void) loadStringsFromPlistFile: (NSString*) fileName
{
    [records removeAllObjects];
    NSMutableArray* arr = [[NSMutableArray alloc] initWithContentsOfFile: fileName];
    [records addObjectsFromArray: arr];
    [arr release];
    [tableView reloadData];    
}

-(void) loadStringsFromPlist: (id) sender
{
    [QOSharedLibrary afterOpenFileDialogforWindow: MAINWINDOW 
                                     callSelector: @selector(loadStringsFromPlistFile:) 
                                           forObj: self]; 
}

-(void) loadStringsFromLocalizableStringsFile: (NSString*) fileName
{
    if ([[NSFileManager defaultManager] fileExistsAtPath: fileName] == YES) 
    {
        [records removeAllObjects];
        [QOSharedLibrary addToDictionary: &records
                                  forLng: @"" 
                              forProject: projectName
                                fromFile: fileName
                            withEncoding: NSUTF16StringEncoding];
        [tableView reloadData];
    }
    else 
    {
        NSBeginAlertSheet(NSLocalizedString(@"Warning!", @"Warning!"), nil, nil, nil, MAINWINDOW, nil, nil, nil, nil, 
                          NSLocalizedString(@"File '%@' not found!", @"File '%@' not found!"), fileName);
    }
}

-(void) loadStringsFromLocalizableStrings: (id) sender
{
    [QOSharedLibrary afterOpenFileDialogforWindow: MAINWINDOW 
                                     callSelector: @selector(loadStringsFromLocalizableStringsFile:) 
                                           forObj: self]; 
}

#pragma mark Merge strings from file

-(void) mergeStringsFromFile: (NSString*) fileName
{
    if ([[NSFileManager defaultManager] fileExistsAtPath: fileName] == YES) 
    {
        [QOSharedLibrary mergeDictionary: &records
                                fromFile: fileName
                            withEncoding: NSUTF16StringEncoding];
        [tableView reloadData];
    }
    else 
    {
        NSBeginAlertSheet(NSLocalizedString(@"Warning!", @"Warning!"), nil, nil, nil, MAINWINDOW, nil, nil, nil, nil, 
                          NSLocalizedString(@"File '%@' not found!", @"File '%@' not found!"), fileName);
    }
}

-(void) mergeStrings: (id) sender
{
    [QOSharedLibrary afterOpenFileDialogforWindow: MAINWINDOW 
                                     callSelector: @selector(mergeStringsFromFile:) 
                                           forObj: self]; 
}

#pragma mark ReLoad string from temporary file

-(void) reloadData: (id) sender
{
    if (sourceFile == nil) 
    {
        return;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath: sourceFile] == YES) 
    {
        [records removeAllObjects];
        [QOSharedLibrary addToDictionary: &records
                                  forLng: @"" 
                              forProject: projectName
                                fromFile: sourceFile
                            withEncoding: NSUTF16StringEncoding];
        [tableView reloadData];
    }
    else 
    {
        NSBeginAlertSheet(NSLocalizedString(@"Warning!", @"Warning!"), nil, nil, nil, MAINWINDOW, nil, nil, nil, nil, 
                          NSLocalizedString(@"File '%@' not found!", @"File '%@' not found!"), sourceFile);
    }
}

#pragma mark Translate strings

-(void) translateItThread
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init]; 
    [appController.progressBar startAnimation: appController];
    QOTranslateStrings* translateResourcesController = [[QOTranslateStrings alloc] initWithWindow: MAINWINDOW];
    NSString* text = @""; 
    [QOSharedLibrary saveDictionary: records toText: &text];
    NSString* result = [translateResourcesController translateLocalizableStrings: text 
                                                                  targetLanguage: targetLanguage];
    [translateResourcesController release];
    [records removeAllObjects];
    [QOSharedLibrary convertText: result 
                          forLng: targetLanguage 
                      forProject: projectName 
                    toDictionary: &records];
    [tableView reloadData];
    
    NSBeginAlertSheet(NSLocalizedString(@"The operation of translation of the string resources has finished successfully", @"The operation of translation of the string resources has finished successfully"), nil, nil, nil, MAINWINDOW, nil, nil, nil, nil, 
                      NSLocalizedString(@"No issues", @"No issues"));
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

#pragma mark -
#pragma mark Similar strings

-(void) searchSimilarStrings: (id) sender
{
    isShowSimilarStrings = (isShowSimilarStrings) == YES ? NO : YES;
    [checkSimilarMenuItem setState: ((isShowSimilarStrings) == YES ? NSOnState : NSOffState)]; 
}

#pragma mark -

@end
