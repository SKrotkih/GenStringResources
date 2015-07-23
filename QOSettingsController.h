//  GenStringResources
//
//  QOSettingsController.h
//
//  Created by Sergey Krotkih on 23.02.11.
//  Copyright 2011 Quickoffice. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface QOSettingsController : NSWindowController <NSApplicationDelegate>
{
	IBOutlet NSTableView* projectsTableView;
	IBOutlet NSDictionaryController* projectPropertiesDictionaryController;
	IBOutlet NSArrayController* projectsListArrayController;
	IBOutlet NSTextField* valueOfAttribute;
	IBOutlet NSTextField* keyOfAttribute;
	IBOutlet NSTextField* idOfProject;
    IBOutlet NSTextField* resultDirTextField;
	
    NSDictionary* selectedProject;
    NSMutableArray* arrayControllerContent;
    NSMutableArray* arrayContent;
    NSDictionary* propertiesList;
    NSString* resultDir;
    NSURLConnection* uploadConnection;
}

@property (retain) NSDictionary* selectedProject;

- (NSArray* ) sortDesc;
- (IBAction) save: (id) sender;
- (IBAction) addProject: (id) sender;
- (IBAction) deleteProject: (id) sender;
- (IBAction) openDirectory: (id)sender;

@end
