//  QOLocalizableStrings
//
//  CopyingModulesWindowController.h
//
//  Created by Sergey Krotkih on 14.12.12.
//  Copyright 2012 Quickoffice. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum
{
    COPY,
    PREPARE,
    FOR_DELETE
} OperationOnModules;

@interface CopyingModulesWindowController : NSWindowController <NSApplicationDelegate>
{
    OperationOnModules operationOnModules;
    NSString* title;
    NSString* userInfo;
	NSArray* modulesTree;
	IBOutlet NSTextField* sourcePath;
	IBOutlet NSTextField* destinatePath;
    IBOutlet NSProgressIndicator* progressIndicator;
 	IBOutlet NSButton* sourcePathButton;
 	IBOutlet NSButton* destPathButton;
}

- (id) initWithModulesTreeAray: (NSArray*) aModulesTree
                     operation: (OperationOnModules) aOperationOnModules
                         title: (NSString*) aTitle;

@property (nonatomic, readwrite, copy) NSString* title;
@property (nonatomic, readwrite, copy) NSString* userInfo;

- (IBAction) runProcess: (id) sender;
- (IBAction) openDirectory: (id) sender;

@end
