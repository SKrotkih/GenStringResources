//  GenStringResources
//
//  CopyingModulesWindowController.m
//
//  Created by Sergey Krotkih on 23.02.11.
//  Copyright 2011 Quickoffice. All rights reserved.
//

#import "CopyingModulesWindowController.h"
#import "QOSharedLibrary.h"
#import "QOPlistProcessing.h"

static NSUInteger deletedModulesCount;
static NSString* const MODULES_TITLE = @"Modules";

@implementation CopyingModulesWindowController

@synthesize title;

- (id) initWithModulesTreeAray: (NSArray*) aModulesTree
                     operation: (OperationOnModules) aOperationOnModules
                         title: (NSString*) aTitle
{
    if ((self = [super initWithWindowNibName: @"CopyingModulesWindowController"]))
	{
        modulesTree = aModulesTree;
        operationOnModules = aOperationOnModules;
        self.title = aTitle;
	}
	
	return self;
}

- (void) awakeFromNib
{
    self.window.title = title;
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

    if ((operationOnModules == COPY) || (operationOnModules == FOR_DELETE))
    {
        [sourcePath setEnabled: YES];
        [destinatePath setEnabled: YES];
        [sourcePathButton setEnabled: YES];
        [destPathButton setEnabled: YES];
    }
    else if (operationOnModules == PREPARE)
    {
        [sourcePath setEnabled: NO];
        [sourcePathButton setEnabled: NO];
        [destinatePath setEnabled: YES];
        [destPathButton setEnabled: YES];
    }

    NSString* srcPath = [defaults objectForKey: @"SourcePathXcodeProjectForCopyModules"];
    
    if ((srcPath == nil) || ([srcPath length] == 0))
    {
        srcPath = @"/Users/oldman/Development/IOS_ML_DEV/";
    }
    
    NSString* dstPath = [defaults objectForKey: @"DestinationPathXcodeProjectForCopyModules"];

    if ((dstPath == nil) || ([dstPath length] == 0))
    {
        dstPath = @"/Users/oldman/Development/IOS_ML_DEV_TEST/";
    }
    
    [sourcePath setStringValue: srcPath];
    [destinatePath setStringValue: dstPath];
}

- (void) dealloc
{
    self.title = nil;

	[super dealloc];
}

- (BOOL) windowShouldClose: (id) sender
{
    [[NSApplication sharedApplication] stopModal];
    
    return YES;
}

- (IBAction) openDirectory: (id) sender
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
             
             NSString* path = [openPanel filename];
             
             if (![path hasSuffix: @"/"])
             {
                 path = [NSString stringWithFormat: @"%@/", path];
             }

             if ([sender tag] == 0)
             {
                 [sourcePath setStringValue: path];
             }
             else if ([sender tag] == 1)
             {
                 [destinatePath setStringValue: path];
             }
         }
     }];
}

- (void) deleteAllModulesInDirectory: (NSString*) aDir
{
    NSArray* exts = [@"c,cpp,cc,m,mm,C,Cpp,CPP,M,MM" componentsSeparatedByString: @","];
    NSArray* filelist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: aDir
                                                                            error: NULL];
    
    for (NSString* fileName in filelist)
    {
        NSString* currentDirectoryItem = [NSString stringWithFormat: @"%@/%@", aDir, fileName];
        
        if ([QOSharedLibrary isDirectory: currentDirectoryItem])
        {
            [self deleteAllModulesInDirectory: currentDirectoryItem];
        }
        else
        {
            NSString* fileExt = [currentDirectoryItem pathExtension];
            
            for (NSString* ext in exts)
            {
                if ([ext isEqualToString: fileExt])
                {
                    [QOSharedLibrary deleteFile: currentDirectoryItem];
                    deletedModulesCount++;

                    break;
                }
            }
        }
    }
}


- (void) scanSrcFolderForDeletedFiles: (NSString*) dstPath resultData: (NSMutableString**) pResultData
{
    NSArray* filelist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: dstPath
                                                                            error: NULL];
    
    for (NSString* fileName in filelist)
    {
        NSString* currentDirectoryItem = [NSString stringWithFormat: @"%@/%@", dstPath, fileName];
        
        if ([QOSharedLibrary isDirectory: currentDirectoryItem])
        {
            [self scanSrcFolderForDeletedFiles: currentDirectoryItem resultData: pResultData];
        }
        else
        {
            NSArray* exts = [@"c,cpp,cc,m,mm,C,Cpp,CPP,M,MM" componentsSeparatedByString: @","];
            
            NSString* fileExt = [currentDirectoryItem pathExtension];
            
            for (NSString* ext in exts)
            {
                if ([ext isEqualToString: fileExt])
                {
                    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
                    NSString* srcRepoPath = [defaults objectForKey: @"SourcePathXcodeProjectForCopyModules"];
                    NSString* dstRepoPath = [defaults objectForKey: @"DestinationPathXcodeProjectForCopyModules"];
                    
                    NSString* dstFullFileName = [currentDirectoryItem stringByReplacingOccurrencesOfString: srcRepoPath
                                                                                                withString: dstRepoPath];
                    
                    if (![[NSFileManager defaultManager] fileExistsAtPath: dstFullFileName])
                    {
                        [(NSMutableString*)*pResultData appendFormat: @"%@\n", dstFullFileName];
                    }
                    
                    break;
                }
            }
        }
    }
}

- (void) scanDestFolderForDeletedFiles: (NSString*) dstPath resultData: (NSMutableString**) pResultData
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* srcRepoPath = [defaults objectForKey: @"SourcePathXcodeProjectForCopyModules"];
    NSString* dstRepoPath = [defaults objectForKey: @"DestinationPathXcodeProjectForCopyModules"];
    
    NSArray* filelist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: dstPath
                                                                            error: NULL];
    
    for (NSString* fileName in filelist)
    {
        NSString* currentDirectoryItem = [NSString stringWithFormat: @"%@%@", dstPath, fileName];
        
        if ([QOSharedLibrary isDirectory: currentDirectoryItem])
        {
            NSString* inSrcRepoPath = [currentDirectoryItem stringByReplacingOccurrencesOfString: dstRepoPath
                                                                                      withString: srcRepoPath];
            [self scanSrcFolderForDeletedFiles: inSrcRepoPath resultData: pResultData];
        }
    }
}

- (IBAction) runProcess: (id) sender
{
    [progressIndicator setHidden: NO];
    [progressIndicator startAnimation: self];
    
    NSString* srcPath = sourcePath.stringValue;
    
    if (![srcPath hasSuffix: @"/"])
    {
        srcPath = [NSString stringWithFormat: @"%@/", srcPath];
    }
    
    NSString* dstPath = destinatePath.stringValue;
    
    if (![dstPath hasSuffix: @"/"])
    {
        dstPath = [NSString stringWithFormat: @"%@/", dstPath];
    }
    
    NSLog(@"\n%@;\n%@\n", srcPath, dstPath);
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: srcPath forKey: @"SourcePathXcodeProjectForCopyModules"];
    [defaults setObject: dstPath forKey: @"DestinationPathXcodeProjectForCopyModules"];
    
    if (operationOnModules == PREPARE)
    {
        deletedModulesCount = 0;
        [self deleteAllModulesInDirectory: dstPath];
        NSLog(@"Deleted %li files.", deletedModulesCount);
        
        [[NSApplication sharedApplication] stopModal];        
    }
    else if (operationOnModules == FOR_DELETE)
    {
        NSMutableString* resultData = [NSMutableString string];
        
        [self scanDestFolderForDeletedFiles: dstPath resultData: &resultData];
        
        NSString* fileName = [QOPlistProcessing workDirectory];
        fileName = [fileName stringByAppendingString: [NSString stringWithFormat: @"/%@/UnecessaryFiles.txt", MODULES_TITLE]];
        
        NSError* error = nil;
        [resultData writeToFile: fileName
                     atomically: YES
                       encoding: NSUTF16StringEncoding
                          error: &error];
        
        [[NSApplication sharedApplication] stopModal];
        
        NSBeginAlertSheet(@"Operation was completed!", nil, nil, nil, MAINWINDOW, nil, nil, nil, nil,
                          @"List of unnecessary files was saved to %@.", fileName);
        
    }
    else
    {
        NSFileManager* fileManager = [NSFileManager defaultManager];
        
        NSInteger errorsCount = 0;
        NSInteger filesToCopyCount = 0;
        NSInteger filesAlreadyExistsCount = 0;
        
        NSEnumerator* srcStream = [modulesTree objectEnumerator];
        NSString* src;

        while ((src = [srcStream nextObject]) != nil)
        {
            NSString* srcFullPath = [src description];
            
            if ([srcFullPath length] == 0)
            {
                continue;
            }
            
            NSString* dstFullPath = [srcFullPath stringByReplacingOccurrencesOfString: srcPath
                                                                           withString: dstPath];
            
            if ((dstFullPath == nil) || ([dstFullPath length] == 0) || [fileManager fileExistsAtPath: dstFullPath])
            {
                if ([fileManager fileExistsAtPath: dstFullPath])
                {
                    filesAlreadyExistsCount++;
                }
                
                continue;
            }
            
            if ([fileManager fileExistsAtPath: srcPath])
            {
                [QOSharedLibrary createDirectoryForFullFilePath: dstFullPath];
                
                NSError* error = nil;
                
                if ([fileManager copyItemAtPath: srcFullPath
                                         toPath: dstFullPath
                                          error: &error])
                {
                    filesToCopyCount++;
                }
                else
                {
                    errorsCount++;
                    NSLog(@"\nError copying: %@", [error localizedDescription]);
                }
            }
            else
            {
                errorsCount++;
                NSLog(@"\nFile: %@ doesn't exist!", srcPath);
            }
        }
        
        [[NSApplication sharedApplication] stopModal];
        
        if (errorsCount > 0)
        {
            NSBeginAlertSheet(@"Warning!", nil, nil, nil, MAINWINDOW, nil, nil, nil, nil,
                              @"While processing found %i errors! Was copied %i files. Already existed %i.", errorsCount, filesToCopyCount, filesAlreadyExistsCount);
        }
        else
        {
            NSBeginAlertSheet(@"Operation has been finished successful!", nil, nil, nil, MAINWINDOW, nil, nil, nil, nil,
                              @"%i files was copied. Already existed %i.", filesToCopyCount, filesAlreadyExistsCount);
        }
    }
}

@end
