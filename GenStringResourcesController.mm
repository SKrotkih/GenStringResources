//  GenStringResources
//
//  GenStringResourcesController.mm
//
//  Created by Sergey Krotkih on 13.02.11.
//  Copyright 2011 Quickoffice. All rights reserved.
//

#import "GenStringResourcesController.h"
#include <stdio.h>
#import <Foundation/Foundation.h>
#import "QOSettingsController.h"
#import "GenStringResources.h"
#import "QOXIBTableView.h"
#import "QOLocalizableXIBStrings.h"
#import "QOSummaryStrings.h"
#import "QOProjectTreeViewController.h"

@implementation GenStringResourcesController

@synthesize progressBar;
@synthesize window = mainWindow;
@synthesize tabView;

static GenStringResourcesController* _appController = nil;

+ (GenStringResourcesController*) appController
{
	return _appController;
}

- (GenStringResourcesController*)init
{
	if ((self = [super init]))
	{	
        isEnableToolBar = YES;

        _appController = self;
	}
	
	return self;
}

- (void) dealloc
{
    [super dealloc];
}

#pragma mark NSToolbarItemValidation and NSMenuItemValidation Protocol implements

-(BOOL) enableToolBarItemTag: (NSInteger)tag
{
    if (tag == 10 || tag == 11) 
    {
        return isEnableToolBar;
    }
    if (tag == 12)   // Apply all summary data
    {
        if (isEnableToolBar) 
        {
            if ([self isTabExists: @"Summary"] == YES ) 
            {
                return YES;
            }
            else 
            {
                return NO;
            }
        }
        else 
        {
            return isEnableToolBar;
        }
    }
    
    return YES;
}

-(BOOL)validateToolbarItem: (NSToolbarItem* )toolbarItem
{
    return [self enableToolBarItemTag: [toolbarItem tag]];
}

-(BOOL)validateMenuItem: (NSMenuItem* )menuItem
{
    return [self enableToolBarItemTag: [menuItem tag]];
}

#pragma mark -

-(void) enableToolbar: (BOOL)enable
{
    isEnableToolBar = enable;
}

-(BOOL) isTabExists: (NSString*)tabViewItemTitle
{
    int tabViewCount = [tabView numberOfTabViewItems];
    int tabViewItemIndex = 0;
    BOOL isTabExists = NO;
    while (tabViewItemIndex < tabViewCount)
    {
        NSTabViewItem* tabViewItem = [tabView tabViewItemAtIndex: tabViewItemIndex]; 
        if ([[tabViewItem label] isEqualToString: tabViewItemTitle] == YES) 
        {
            isTabExists = YES;
        }
        tabViewItemIndex++;
    }
    return isTabExists;
}

#pragma mark Handle main menu items

- (IBAction) settings: (id) sender
{
    QOSettingsController* settings = [[QOSettingsController alloc] initWithWindowNibName: @"SettingsWindow"];
    [settings showWindow: self];
    [[NSApplication sharedApplication] runModalForWindow: [settings window]];
    [settings release];
}

- (IBAction) help: (id)sender
{
    NSString* helpPath = [[NSBundle mainBundle] pathForResource: @"ReadMe" 
                                                         ofType: @"rtf"];
	[[NSWorkspace sharedWorkspace] openFile: helpPath];
}

- (IBAction) startScanLocalizableStrings: (id) sender
{
    GenStringResources* localizableStrings = [GenStringResources sharedLocalizableStrings];
    [localizableStrings startScanStrings];
}

- (IBAction) open: (id) sender
{
    GenStringResources* localizableStrings = [GenStringResources sharedLocalizableStrings];
    [localizableStrings openProject];
}

- (IBAction) startScanProjectModules: (id) sender
{
    GenStringResources* localizableStrings = [GenStringResources sharedLocalizableStrings];
    [localizableStrings startScanModules];
}

- (IBAction) openProjectModules: (id) sender
{
    GenStringResources* localizableStrings = [GenStringResources sharedLocalizableStrings];
    [localizableStrings openProjectModules];
}

- (IBAction) startScanXIBStrings: (id) sender
{
    QOLocalizableXIBStrings* localizableXIBStrings = [QOLocalizableXIBStrings sharedLocalizableXIBStrings];
    [localizableXIBStrings startScan];
}

- (IBAction) openXIBs: (id) sender
{
    QOLocalizableXIBStrings* localizableXIBStrings = [QOLocalizableXIBStrings sharedLocalizableXIBStrings];
    [localizableXIBStrings openProject];
}

- (IBAction) showSummary: (id) sender
{
    QOSummaryStrings* summaryStrings = [QOSummaryStrings sharedSummaryStrings];
    [summaryStrings startScan];
}

- (IBAction) applySummary: (id) sender
{

}

@end
