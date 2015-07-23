//  GenStringResources
//
//  QOPlistProcessing.m
//
//  Created by Sergey Krotkih on 08.03.11.
//  Copyright 2011 Quickoffice. All rights reserved.
//

#import "QOPlistProcessing.h"
#import "QOSharedLibrary.h"

@implementation QOPlistProcessing

+(NSString*) workDirectory
{
	NSString* propertiesListPath = [[NSBundle mainBundle] pathForResource: @"Properties" 
                                                                   ofType: @"plist"];
	NSDictionary* propertiesList = [NSDictionary dictionaryWithContentsOfFile: propertiesListPath];
    
    NSMutableString* workDirectory = [[NSMutableString alloc] initWithString: [propertiesList objectForKey: @"ResultDir"]];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath: workDirectory] == NO) 
    {
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
        [workDirectory setString: [NSString stringWithFormat: @"%@/LocalizableStrings", [paths objectAtIndex: 0]]];
        [QOSharedLibrary createDirectory: workDirectory];
    }
    
    return [workDirectory autorelease];
}

+(BOOL) getPlistProject: (NSDictionary** )plistProjects window: (NSWindow*) parentWindow
{
    NSString* rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
    NSString* plistPath = [rootPath stringByAppendingPathComponent: @"Projects.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath: plistPath]) 
    {
        plistPath = [[NSBundle mainBundle] pathForResource: @"Projects" 
                                                    ofType: @"plist"];
    }
    NSData* plistXML = [[NSFileManager defaultManager] contentsAtPath: plistPath];
    NSString* errorDesc = nil;
    NSPropertyListFormat format;
    *plistProjects = [(NSDictionary* )[NSPropertyListSerialization propertyListFromData: plistXML
                                                                       mutabilityOption: NSPropertyListMutableContainersAndLeaves
                                                                                 format: &format
                                                                       errorDescription: &errorDesc] retain];
    if (*plistProjects == nil)
    {
        NSLog(@"Error open Projects.plist: %@, format: %lu", errorDesc, format);
        return NO;
    }
    
    BOOL plistIsOK = YES;
    NSEnumerator* pListEnumerator = [*plistProjects objectEnumerator];
    NSDictionary* pListItem;
    while (plistIsOK == YES && (pListItem = [pListEnumerator nextObject])) 
    {
        NSString* projectPath = [[pListItem objectForKey: @"RootPath"] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        BOOL enable = [[pListItem objectForKey: @"enable"] boolValue];
        if ([projectPath isEqualToString: @""] == NO && enable == YES) 
        {
            plistIsOK = [[NSFileManager defaultManager] fileExistsAtPath: projectPath];
        }
    } 
    if (plistIsOK == NO) 
    {
        [*plistProjects release];

        return NO;
    }

    return YES;
}

@end
