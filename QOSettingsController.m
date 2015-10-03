//  GenStringResources
//
//  QOSettingsController.m
//
//  Created by Sergey Krotkih on 23.02.11.
//  Copyright 2011 Quickoffice. All rights reserved.
//

#import "QOSettingsController.h"
#import "QOSharedLibrary.h"
#import "QOPlistProcessing.h"

@implementation QOSettingsController

@synthesize selectedProject;

// the keys to our array controller to be displayed in the table view,
#define KEY_FIRST	@"name"
#define KEY_LAST	@"RoutineLocalizedString"

#define SelectionIndexesContext @"SelectionIndexesContext"

- (void) awakeFromNib
{
	NSString* plistPath = [[NSBundle mainBundle] pathForResource: @"Projects" ofType: @"plist"];
	arrayControllerContent = [[NSArray arrayWithContentsOfFile: plistPath] mutableCopy];
	arrayContent = [[NSArray arrayWithContentsOfFile: plistPath] mutableCopy];
    
	[projectsTableView setSortDescriptors: [NSArray arrayWithObjects:   [[[NSSortDescriptor alloc] initWithKey: @"name" 
                                                                                                     ascending: YES] autorelease],
                                                                        nil]];
    
	[projectsListArrayController addObserver: self 
                                  forKeyPath: @"selectionIndexes" 
                                     options: NSKeyValueObservingOptionNew 
                                     context: SelectionIndexesContext];    
    
	if (arrayControllerContent != nil)
	{
		[projectsListArrayController addObjects: arrayControllerContent];
	}
	[projectsListArrayController setSelectionIndex: 0];
	[projectPropertiesDictionaryController bind: NSContentDictionaryBinding 
                                       toObject: self 
                                    withKeyPath: @"selectedProject" 
                                        options: nil];

	NSString* firstNameLocalizedKey = NSLocalizedString(@"name", @"");
	[projectPropertiesDictionaryController setLocalizedKeyDictionary: [NSDictionary dictionaryWithObjectsAndKeys: 
                                                firstNameLocalizedKey, KEY_FIRST,
                                                nil]];

	NSString* propertiesListPath = [[NSBundle mainBundle] pathForResource: @"Properties" 
                                                                   ofType: @"plist"];
	propertiesList = [[NSDictionary dictionaryWithContentsOfFile: propertiesListPath] retain];


    NSString* workDirectory = [QOPlistProcessing workDirectory];
    [resultDirTextField setStringValue: workDirectory]; 
}

- (void) dealloc
{
    self.selectedProject = nil;
	[projectsListArrayController removeObserver: self 
                                     forKeyPath: @"selectionIndexes"];
    [projectsListArrayController release];
    [arrayControllerContent release];
    [arrayContent release];

	[super dealloc];
}

- (NSArray* ) sortDesc
{
	return [projectsTableView sortDescriptors];
}

- (void) observeValueForKeyPath:(NSString*)keyPath ofObject: (id)object change: (NSDictionary*)change context: (void*)context
{
	if (context == SelectionIndexesContext)
	{
		if ([[object selectedObjects] count] > 0)
		{
			if ([[object selectedObjects] objectAtIndex: 0] != nil)
			{
				// update our current project and reflect the change to our dictionary controller
				[self setSelectedProject: [[object selectedObjects] objectAtIndex: 0]];
				[projectPropertiesDictionaryController bind: NSContentDictionaryBinding 
                                                   toObject: self 
                                                withKeyPath: @"selectedProject" 
                                                    options: nil];
			}
		}
	}
	else
	{
		[super observeValueForKeyPath: keyPath 
                             ofObject: object 
                               change: change 
                              context: context];
	}
}

- (void) savePlist
{
    NSString* plistPath = [[NSBundle mainBundle] pathForResource: @"Projects" 
                                                          ofType: @"plist"];
    [arrayContent writeToFile: plistPath atomically: YES];
}

- (IBAction) save: (id) sender
{
    [self savePlist];
}

- (void)alertDidEnd: (NSAlert*)alert returnCode: (NSInteger)returnCode contextInfo: (void*)contextInfo 
{
    if ([(NSString*)contextInfo isEqualToString: @"SettingsProjects"] == YES) 
    {
        if (returnCode == 1) 
        {
            [self savePlist];
        }
    }
    else if ([(NSString*)contextInfo isEqualToString: @"WorkDirectory"] == YES) 
    {
        if (returnCode == 1) 
        {
            [propertiesList setValue: [resultDirTextField stringValue] forKey: @"ResultDir"];
            NSString* propertiesListPath = [[NSBundle mainBundle] pathForResource: @"Properties" 
                                                                           ofType: @"plist"];
            [propertiesList writeToFile: propertiesListPath 
                             atomically: YES];
        }
    }

    [self close];    
}

- (BOOL)windowShouldClose:(id)sender
{
    NSString* plistPath = [[NSBundle mainBundle] pathForResource: @"Projects" 
                                                          ofType: @"plist"];
    if ([arrayContent isEqualToArray: [NSArray arrayWithContentsOfFile: plistPath]] == NO)
    {
        NSBeginAlertSheet(NSLocalizedString(@"Warning!", @"Warning!"), 
                          NSLocalizedString(@"Save data", @"Save data"), 
                          NSLocalizedString(@"Continue", @"Continue"), 
                          nil,
                          [self window], 
                          self, 
                          @selector(alertDidEnd:returnCode:contextInfo:),
                          nil,
                          @"SettingsProjects", 
                          NSLocalizedString(@"Settings data was changed, but didn't save.\nWould you like to save changes?", @"Settings data was changed, but didn't save.\nWould you like to save changes?"));
        return NO;
    }
    else if ([[resultDirTextField stringValue] isEqualToString: [propertiesList objectForKey: @"ResultDir"]] == NO)
    {
        NSBeginAlertSheet(NSLocalizedString(@"Warning!", @"Warning!"), 
                          NSLocalizedString(@"Save data", @"Save data"), 
                          NSLocalizedString(@"Continue", @"Continue"),  
                          nil,
                          [self window], 
                          self, 
                          @selector(alertDidEnd:returnCode:contextInfo:),
                          nil,
                          @"WorkDirectory",
                          NSLocalizedString(@"Work directory path was changed, but didn't save.\nWould you like to save the changes?", @"Work directory path was changed, but didn't save.\nWould you like to save the changes?"));
        return NO;
    }
    return YES;
}

-(void) windowWillClose: (NSNotification*) notification
{
    if ([[NSApplication sharedApplication] modalWindow] != nil)
    {
        [[NSApplication sharedApplication] stopModal];
    }
    [self autorelease];
}

- (BOOL) getSelectedProject: (NSDictionary**) aSelectedProject
{
    NSArray* selectionObjects = [projectsListArrayController selectedObjects];
    if (selectionObjects != nil && [selectionObjects count] == 1) 
    {
        NSString* id = [[selectionObjects objectAtIndex: 0] objectForKey: @"id"];
        if ([[idOfProject stringValue] isEqual: id]) 
        {
            NSEnumerator* arrayContentEnumerator = [arrayContent objectEnumerator];
            NSDictionary* projectAttributes;
            while ((projectAttributes = [arrayContentEnumerator nextObject])) 
            {
                if ([[projectAttributes objectForKey: @"id"] isEqual: id]) 
                {
                    *aSelectedProject = [projectAttributes retain];
                    return YES;
                }
            }            
        }
    }
    return NO;    
}

- (void)didChangeValueForKey: (NSString* )key
{
    NSDictionary* currProject;
    if ([self getSelectedProject: &currProject] == YES) 
    {
        [currProject setValue: [valueOfAttribute stringValue] 
                       forKey: [keyOfAttribute stringValue]];
        [currProject release];
        
        //[projectsListArrayController replaceValueAtIndex: index inPropertyWithKey: [keyOfAttribute stringValue] withValue: [valueOfAttribute stringValue]];
        
    }
}

- (IBAction)openDirectory: (id)sender 
{
    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
    [openPanel setTreatsFilePackagesAsDirectories: NO];
    [openPanel setAllowsMultipleSelection: NO];
    [openPanel setCanChooseDirectories: YES];
    [openPanel setCanChooseFiles: NO];
    [openPanel beginSheetModalForWindow: [self window] completionHandler: ^(NSInteger result) 
     {
         if (result == NSOKButton) 
         {
             [openPanel orderOut: self]; // close panel before we might present an error
             if ([sender tag] == 0) 
             {
                 [valueOfAttribute setStringValue: [[openPanel URL] absoluteString]];
             }
             else if ([sender tag] == 1)
             {
                 [resultDirTextField setStringValue: [[openPanel URL] absoluteString]];
             }
         }
     }];
}

-(NSInteger) nextId
{
    NSInteger nextId = 0;
    NSEnumerator* arrayContentEnumerator = [arrayContent objectEnumerator];
    NSDictionary* projectAttributes;
    while ((projectAttributes = [arrayContentEnumerator nextObject])) 
    {
        NSInteger currId = [[projectAttributes objectForKey: @"id"] intValue];
        if (currId > nextId) 
        {
            nextId = currId;
        }
    }            
    return nextId + 1;
}

- (IBAction) addProject: (id) sender
{
    NSArray* keys = [[NSArray alloc] initWithObjects: @"id", @"name", @"RoutineLocalizedString", @"RootPath", @"ResourcesPath", @"XIBsPath", @"listOfExtensions", @"enable", nil];
    NSArray* objs = [[NSArray alloc] initWithObjects: [NSString stringWithFormat: @"%ld", (long)[self nextId]], @"Project name", @"", @"", @"", @"", @"", @"1", nil];
    NSDictionary* dict = [[NSDictionary alloc] initWithObjects: objs 
                                                       forKeys: keys];
    [arrayContent addObject: dict];
    [projectsListArrayController addObject: dict];
    [keys release];
    [objs release];
    [dict release];
}

- (IBAction) deleteProject: (id) sender
{
    [arrayContent removeObject: selectedProject];  
    [projectsListArrayController removeObject: selectedProject];
}

@end
