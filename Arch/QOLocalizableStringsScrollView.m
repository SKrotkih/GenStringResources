//  QOLocalizableStrings
//
//  QOLocalizableStringsScrollView.m
//
//  Created by Sergey Krotkih on 23.02.11.
//  Copyright 2011 Quickoffice. All rights reserved.
//

#import "QOLocalizableStringsScrollView.h"
#import "QOSharedLibrary.h"
#import "QOTranslateStrings.h"
#import "QOLocalizableStringsController.h"

@implementation QOLocalizableStringsScrollView

@synthesize parentController;
@synthesize typeFile;
@synthesize sourceFile;
@synthesize targetFile;
@synthesize targetLanguage;
@synthesize projectName;

-(QOLocalizableStringsScrollView*) initWithFile: (NSString*)aFileName encoding: (NSStringEncoding)enc
{
    if ((self = [super init]) != nil)
    {
        NSError *error = nil;
        NSString *text = [NSString stringWithContentsOfFile: aFileName encoding: enc error: &error];
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
    }
    
    return self;
}

-(void) dealloc
{
    [textView release];
    [sourceFile release];
    [targetFile release];
    
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
        NSError *error;
        NSArray *lines = [[NSString stringWithContentsOfFile: sourceFile 
                                                    encoding: NSUTF16StringEncoding 
                                                       error: &error] componentsSeparatedByString: @"\n"];
        NSEnumerator *linesStream = [lines objectEnumerator];    
        NSString *resStr = @"";
        NSString *str;
        while(str = [linesStream nextObject]) 
        {
            resStr = [resStr stringByAppendingString: [NSString stringWithFormat: @"%@\n", str]]; 
        }
        
        [textView setString: resStr];
    }
    else 
    {
        NSBeginAlertSheet(@"Warning!", nil, nil, nil, parentController.window, nil, nil, nil, nil, 
                          @"File %@ isn't exist!", sourceFile);
    }
}

-(void) saveContentToFile: (NSString*)fileName
{
    NSError *error = nil;
    [[textView string] writeToFile: fileName atomically: YES encoding: NSUTF16StringEncoding error: &error];    
}

-(void) save: (id) sender
{
    [self saveContentToFile: sourceFile];
}

-(void) saveAs :(id) sender
{
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel setTreatsFilePackagesAsDirectories: NO];
    [savePanel beginSheetModalForWindow: parentController.window completionHandler: ^(NSInteger result) 
     {
         if (result == NSOKButton) 
         {
             [savePanel orderOut: self];
             [self saveContentToFile: [savePanel filename]];
         }
     }];
}

-(void) saveTranslationData :(id) sender
{
    NSString *newStringsFileName = [sourceFile stringByReplacingOccurrencesOfString: @"_NO_TRANSLATION" withString: @""];    
    if ([QOSharedLibrary mergeTranslatedStringsToFileName: newStringsFileName data: [textView string]] == YES)
    {
        NSBeginAlertSheet(@"Data saved successfully", nil, nil, nil, parentController.window, nil, nil, nil, nil, 
                          @"Select NEW tab and choise 'Reload data' from context menu");
    }
    else 
    {
        NSBeginAlertSheet(@"Warning!", nil, nil, nil, parentController.window, nil, nil, nil, nil, 
                          @"Data didn't save!");
    }
}

-(void) saveLocalizableStrings :(id) sender
{
    [QOSharedLibrary saveLocalizableStrings: targetFile content: [textView string]];
    NSBeginAlertSheet(@"Data saved successfully", nil, nil, nil, parentController.window, nil, nil, nil, nil, 
                      @"New localizable.strings saved to the project");
}

-(void) translateItThread
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; 
    [parentController.progressBar startAnimation: parentController];
    QOTranslateStrings *translateResourcesController = [[QOTranslateStrings alloc] initWithWindow: parentController.window];
    NSString *result = [translateResourcesController translateLocalizableStrings: [textView string] 
                                                                  targetLanguage: targetLanguage];
    [textView setString: result];
    NSBeginAlertSheet(@"Translate Succeeded", nil, nil, nil, parentController.window, nil, nil, nil, nil, 
                      @"No issues");
    [parentController.progressBar stopAnimation: parentController];
    [pool release];
}

-(void) translateIt: (id) sender
{
    NSThread *thread = [[NSThread alloc] initWithTarget: self
                                               selector: @selector(translateItThread)
                                                 object: nil];
    [thread start];
}

#pragma mark NSTextViewDelegate Protocol methods

// http://internet.newspoint.info/mac-os-x-perelator
- (NSMenu *)textView: (NSTextView *)view menu: (NSMenu *)menu forEvent: (NSEvent *)event atIndex: (NSUInteger)charIndex
{
    NSAssert(view == textView, @"textView");
    
    [menu addItem: [NSMenuItem separatorItem]];
    if (typeFile == TYPE_DATA_NO_TRANSLATION)
    {
        [[menu addItemWithTitle: @"Save the translations" 
                         action: @selector(saveTranslationData:) 
                  keyEquivalent: @"savetranslations"] setTarget: self];

        [[menu addItemWithTitle: @"Translate it!" 
                         action: @selector(translateIt:) 
                  keyEquivalent: @"translateit"] setTarget: self];
    }
    if (typeFile == TYPE_DATA_NEW)
    {
        [[menu addItemWithTitle: @"Save the new localizable.strings resources to the project" 
                         action: @selector(saveLocalizableStrings:) 
                  keyEquivalent: @"saveLocalizableStrings"] setTarget: self];
    }
    if (typeFile == TYPE_DATA_MAIN)
    {
        [[menu addItemWithTitle: [NSString stringWithFormat: @"Start to scan \"%@\"", projectName] 
                         action: @selector(startScanStringResourcesForCurrentProject:) 
                  keyEquivalent: @"startscan"] setTarget:self];        
    }
    [[menu addItemWithTitle: @"Save" 
                     action: @selector(save:) 
              keyEquivalent: @"save"] setTarget:self];

    [[menu addItemWithTitle: @"Save as..." 
                     action: @selector(saveAs:) 
              keyEquivalent: @"saveas"] setTarget:self];        

    [[menu addItemWithTitle: @"Reload data" 
                     action: @selector(reloadData:) 
              keyEquivalent: @"reloaddata"] setTarget:self];
    
    return menu;
}

-(void) startScanStringResourcesForCurrentProject: (id) sender
{
    
}

@end
