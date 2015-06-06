//  QOLocalizableStrings
//
//  QOPlistProcessing.h
//
//  Created by Sergey Krotkih on 08.03.11.
//  Copyright 2011 Quickoffice. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface QOPlistProcessing : NSObject 
{

}

+(NSString*) workDirectory;
+(BOOL) getPlistProject: (NSDictionary **)plistProjects window: (NSWindow*) parentWindow;

@end
