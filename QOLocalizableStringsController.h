//  QOLocalizableStrings
//
//  QOLocalizableStringsController.h
//
//  Created by Sergey Krotkih on 13.02.11.
//  Copyright 2011 Quickoffice. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface QOLocalizableStringsController : NSObject
{
    IBOutlet NSProgressIndicator* progressBar;
    IBOutlet NSTabView* tabView;
    IBOutlet NSWindow* mainWindow;
    BOOL isEnableToolBar;
}

+ (QOLocalizableStringsController*) appController;

- (void) enableToolbar: (BOOL)enable;
- (IBAction) settings: (id) sender;
- (IBAction) help: (id)sender;
- (IBAction) startScanLocalizableStrings: (id) sender;
- (IBAction) open: (id) sender;
- (IBAction) startScanProjectModules: (id) sender;
- (IBAction) openProjectModules: (id) sender;
- (IBAction) startScanXIBStrings: (id) sender;
- (IBAction) openXIBs: (id) sender;
- (IBAction) showSummary: (id) sender;
- (IBAction) applySummary: (id) sender;

@property(nonatomic, retain) NSProgressIndicator* progressBar;
@property(nonatomic, retain, readonly) NSWindow* window;
@property(nonatomic, retain) NSTabView* tabView;

-(BOOL) isTabExists: (NSString*)tabViewItemTitle;

@end
