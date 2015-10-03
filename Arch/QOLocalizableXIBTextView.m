//  GenStringResources
//
//  QOLocalizableXIBTextView.m
//
//  Created by Sergey Krotkih on 07.03.11.
//  Copyright 2011 Quickoffice. All rights reserved.
//

#import "QOLocalizableXIBTextView.h"
#import "QOSharedLibrary.h"
#import "QOTranslateStrings.h"
#import "GenStringResourcesController.h"

@implementation QOLocalizableXIBTextView

@synthesize appController;
@synthesize typeFile;
@synthesize sourceFile;
@synthesize targetFile;
@synthesize targetLanguage;
@synthesize projectName;

-(QOLocalizableXIBTextView*) initWithFile: (NSString*)aFileName encoding: (NSStringEncoding)enc
{
    if ((self = [super init]) != nil)
    {
        NSError* error = nil;
        NSString* text = [NSString stringWithContentsOfFile: aFileName encoding: enc error: &error];
        if (text != nil) 
        {
            [self setHasVerticalScroller: YES];
            [self setHasHorizontalScroller: YES];
            
            textView = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, 1.0e7, 1.0e7)];
            [textView setMaxSize: NSMakeSize(1.0e7, 1.0e7)];
            [textView setSelectable: YES];
            [textView setEditable: YES];
            [textView setRichText: YES];
            [textView setImportsGraphics: YES];
            [textView setUsesFontPanel: YES];
            [textView setUsesRuler: YES];
            [textView setAllowsUndo: YES];
            [textView setDelegate: self];
            [textView setString: text];
            
            [self setDocumentView: textView];
        }
        
        sourceFile = nil;
        targetFile = nil;
        appController = [GenStringResourcesController appController];
    }
    
    return self;
}

-(void) dealloc
{
    [textView release];
    [sourceFile release];
    [targetFile release];
    [thread release];
    
    [super dealloc];
}

#pragma mark Handle of TextView context menu  items

-(void) reloadData: (id) sender
{
    if (sourceFile == nil) 
    {
        return;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath: sourceFile] == YES) 
    {
        NSError* error;
        NSArray* lines = [[NSString stringWithContentsOfFile: sourceFile 
                                                    encoding: NSUTF16StringEncoding 
                                                       error: &error] componentsSeparatedByString: @"\n"];
        NSEnumerator* linesStream = [lines objectEnumerator];    
        NSString* resStr = @"";
        NSString* str;
        while ((str = [linesStream nextObject]) != nil)
        {
            resStr = [resStr stringByAppendingString: [NSString stringWithFormat: @"%@\n", str]]; 
        }
        
        [textView setString: resStr];
    }
    else 
    {
        NSBeginAlertSheet(@"Warning!", nil, nil, nil, MAINWINDOW, nil, nil, nil, nil, 
                          @"File '%@' not found!", sourceFile);
    }
}

-(void) saveContentToFile: (NSString*)fileName
{
    NSError* error = nil;
    [[textView string] writeToFile: fileName atomically: YES encoding: NSUTF16StringEncoding error: &error];    
}

-(void) save: (id) sender
{
    [self saveContentToFile: sourceFile];
}

-(void) saveAs :(id) sender
{
    NSSavePanel* savePanel = [NSSavePanel savePanel];
    [savePanel setTreatsFilePackagesAsDirectories: NO];
    [savePanel beginSheetModalForWindow: MAINWINDOW completionHandler: ^(NSInteger result) 
     {
         if (result == NSOKButton) 
         {
             [savePanel orderOut: self];
             [self saveContentToFile: [[savePanel URL] absoluteString]];
         }
     }];
}

-(void) saveTranslationData :(id) sender
{
    NSString* newStringsFileName = [sourceFile stringByReplacingOccurrencesOfString: @"_NO_TRANSLATION" 
                                                                         withString: @""];    
    if ([QOSharedLibrary mergeTranslatedStringsToFileName: newStringsFileName 
                                                     data: [textView string]] == YES)
    {
        NSBeginAlertSheet(@"Data were saved successfully", nil, nil, nil, MAINWINDOW, nil, nil, nil, nil, 
                          @"Select NEW tab and choise 'Reload data' in context menu");
    }
    else 
    {
        NSBeginAlertSheet(@"Warning!", nil, nil, nil, MAINWINDOW, nil, nil, nil, nil, 
                          @"Couldn't save data!");
    }
}

-(void) runImportStrings: (NSString*) aStrings toXibFile: (NSString*) aXibFile parentWindow: (NSWindow*) aParentWindow
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
            NSBeginAlertSheet(@"Error", nil, nil, nil, aParentWindow, nil, nil, nil, nil, 
                              @"Couldn't execute the command. Return code is %d", result);
        }
    }
    else 
    {
        NSBeginAlertSheet(@"Warning!", nil, nil, nil, MAINWINDOW, nil, nil, nil, nil, 
                          @"Couldn't save data!");
    }
}

-(void) splitString: (NSString*) src xibFileName: (NSString**) pXibFileName string: (NSString**) pString
{
    NSArray* arr = [src componentsSeparatedByString: @"^"];
    *pXibFileName = [arr objectAtIndex: 0];
    *pString = [arr objectAtIndex: 1];    
}
    
-(void) saveLocalizableStringsToXibThread
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init]; 
    [appController.progressBar startAnimation: appController];

    NSArray* srcLines = [[textView string] componentsSeparatedByString: @"\n"];
    NSEnumerator* srcStream = [srcLines objectEnumerator];    
    NSString* line;
    NSMutableArray* array = [[NSMutableArray alloc] init];
    while ((line = [srcStream nextObject]) != nil)
    {
        if (([line length] > 0) && [[line substringToIndex: 1] isEqualToString: @"/"] )
        {
            line = [line stringByReplacingOccurrencesOfString: @"/*" withString: @""];    
            line = [line stringByReplacingOccurrencesOfString: @"*/" withString: @""];    
            NSArray* xib_id = [line componentsSeparatedByString: @":"];
            line = [srcStream nextObject]; 
            line = [line stringByReplacingOccurrencesOfString: @";" withString: @""];
            NSArray* key_value = [line componentsSeparatedByString: @" = "];
            NSString* object = [NSString stringWithFormat: @"%@ = %@;\n", [xib_id objectAtIndex: 1], [key_value objectAtIndex: 1]];
            [array addObject: [NSString stringWithFormat: @"%@^%@", [xib_id objectAtIndex: 0], object]];
        }
    }
    if ([array count] > 0) 
    {
        NSArray* sortedArray = [array sortedArrayUsingSelector: @selector(compare:)];
        NSString* text = @"";
        NSString* oldXibFileName;
        NSString* oldObject;        
        [self splitString: [sortedArray objectAtIndex: 0] 
              xibFileName: &oldXibFileName 
                   string: &oldObject];
        for (int i = 0; i < [sortedArray count]; i++)
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
                [self runImportStrings: text 
                             toXibFile: oldXibFileName 
                          parentWindow: MAINWINDOW];
                
                text = [NSString stringWithString: currObject]; 
                oldXibFileName = [NSString stringWithString: currXibFileName];
            }
        }
        [self runImportStrings: text 
                     toXibFile: oldXibFileName 
                  parentWindow: MAINWINDOW];
    }
    [array release];
    
    NSBeginAlertSheet(@"Data were saved successfully", nil, nil, nil, MAINWINDOW, nil, nil, nil, nil, 
                      @"New strings saved to the XIB files of the project");
    [appController.progressBar stopAnimation: appController];
    [pool release];
}

-(void) saveLocalizableStringsToXib :(id) sender
{
    if (thread != nil) 
    {
        [thread cancel];
        [thread release];
    }
    thread = [[NSThread alloc] initWithTarget: self
                                               selector: @selector(saveLocalizableStringsToXibThread)
                                                 object: nil];
    [thread start];
}    

-(void) translateItThread
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init]; 
    [appController.progressBar startAnimation: appController];
    QOTranslateStrings* translateResourcesController = [[QOTranslateStrings alloc] initWithWindow: MAINWINDOW];
    NSString* result = [translateResourcesController translateLocalizableStrings: [textView string] 
                                                                  targetLanguage: targetLanguage];
    [translateResourcesController release];
    [textView setString: result];
    NSBeginAlertSheet(@"The operation of translation of the string resources has finished successfully", nil, nil, nil, MAINWINDOW, nil, nil, nil, nil, 
                      @"No issues");
    [appController.progressBar stopAnimation: appController];
    [pool release];
}

-(void) translateIt: (id) sender
{
    if (thread != nil) 
    {
        [thread cancel];
        [thread release];
    }
    thread = [[NSThread alloc] initWithTarget: self
                                               selector: @selector(translateItThread)
                                                 object: nil];
    [thread start];
}

#pragma mark NSTextViewDelegate Protocol methods

// http://internet.newspoint.info/mac-os-x-perelator
- (NSMenu* )textView: (NSTextView* )view menu: (NSMenu* )menu forEvent: (NSEvent* )event atIndex: (NSUInteger)charIndex
{
    NSAssert(view == textView, @"textView");
    
    [menu addItem: [NSMenuItem separatorItem]];
    if (typeFile == TYPE_DATA_NEW)
    {
        [[menu addItemWithTitle: @"Translate it!" 
                         action: @selector(translateIt:) 
                  keyEquivalent: @"translateit"] setTarget: self];
        
        [[menu addItemWithTitle: @"Save the new strings to the XIB files of the project" 
                         action: @selector(saveLocalizableStringsToXib:) 
                  keyEquivalent: @"saveLocalizableStringsToXib"] setTarget: self];
    }
    if (typeFile == TYPE_DATA_MAIN)
    {
        [[menu addItemWithTitle: [NSString stringWithFormat: @"Start to scan '%@'", projectName] 
                         action: @selector(startScanStringResourcesForCurrentProject:) 
                  keyEquivalent: @"startscan"] setTarget:self];        
    }
    [[menu addItemWithTitle: @"Save data" 
                     action: @selector(save:) 
              keyEquivalent: @"Save data"] setTarget:self];
    
    [[menu addItemWithTitle: @"Save data to file as ... type" 
                     action: @selector(saveAs:) 
              keyEquivalent: @"saveas"] setTarget:self];        
    
    [[menu addItemWithTitle: @"Reload data" 
                     action: @selector(reloadData:) 
              keyEquivalent: @"reloaddata"] setTarget:self];
    
    return menu;
}

@end
