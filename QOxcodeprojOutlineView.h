//
//  QOxcodeprojOutlineView.h
//  GenStringResources
//
//  Created by Sergey Krotkih on 22.05.11.
//  Copyright 2011 Quickoffice. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface QOxcodeprojOutlineView : NSOutlineView 
{
    id parentViewController;
}

@property(nonatomic, retain) id parentViewController;

- (IBAction) runBuild: (id) sender;
- (IBAction) openBuild: (id) sender;
- (IBAction) saveListModulesToFile: (id) sender;
- (IBAction) performClick: (id)sender;
- (IBAction) parseBuildResult: (id)sender;
- (IBAction) copyModulesToOtherFolder: (id)sender;
- (IBAction) prepareCopyModulesToOtherFolder: (id)sender;
- (IBAction) getListFilesForDeleteInOtherFolder: (id)sender;

@end
