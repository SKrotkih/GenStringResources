//
//  QOxcodeprojOutlineView.m
//  GenStringResources
//
//  Created by Sergey Krotkih on 22.05.11.
//  Copyright 2011 Quickoffice. All rights reserved.
//

#import "QOxcodeprojOutlineView.h"

@implementation QOxcodeprojOutlineView

@synthesize parentViewController;

- (void)awakeFromNib
{
   
}

- (void) dealloc
{
    
	[super dealloc];
}

- (IBAction) runBuild: (id) sender
{
	if ([parentViewController respondsToSelector: @selector(runBuild)])
    {
		[parentViewController performSelector: @selector(runBuild)];
    }
}

- (IBAction) openBuild: (id) sender
{
	if ([parentViewController respondsToSelector: @selector(openBuild)]) 
    {
		[parentViewController performSelector: @selector(openBuild)];
    }
}

- (IBAction) saveListModulesToFile: (id) sender
{
	if ([parentViewController respondsToSelector: @selector(saveListModulesToFile)]) 
    {
		[parentViewController performSelector: @selector(saveListModulesToFile)];
    }
}

- (IBAction) parseBuildResult: (id)sender
{
	if ([parentViewController respondsToSelector: @selector(parseBuildResult)]) 
    {
		[parentViewController performSelector: @selector(parseBuildResult)];
    }
}

- (IBAction) copyModulesToOtherFolder: (id)sender
{
	if ([parentViewController respondsToSelector: @selector(copyModulesToOtherFolder)])
    {
		[parentViewController performSelector: @selector(copyModulesToOtherFolder)];
    }
}

- (IBAction) prepareCopyModulesToOtherFolder: (id)sender
{
	if ([parentViewController respondsToSelector: @selector(prepareCopyModulesToOtherFolder)])
    {
		[parentViewController performSelector: @selector(prepareCopyModulesToOtherFolder)];
    }
}

- (IBAction) getListFilesForDeleteInOtherFolder: (id)sender
{
	if ([parentViewController respondsToSelector: @selector(getListFilesForDeleteInOtherFolder)])
    {
		[parentViewController performSelector: @selector(getListFilesForDeleteInOtherFolder)];
    }
}

- (IBAction)performClick:(id)sender
{
    NSLog(@"%d", 0);
}

@end
