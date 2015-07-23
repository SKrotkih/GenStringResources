//
//  QOModuleStrings.h
//  GenStringResources
//
//  Created by Sergey Krotkih on 22.05.11.
//  Copyright 2011 Quickoffice. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface QOModuleStrings : NSObject 
{
    NSArray* localizableStrings;
    NSString* moduleName;
}

@property (nonatomic, retain) NSString* moduleName;

+(QOModuleStrings*) createObjectWithContentFromArray: (NSArray*)aArrayOfContent atIndex: (int*)i;
-(id) initWithLocalizableStrings: (NSArray*) aLocalizableStrings inModule: (NSString*) aModuleName;
-(NSString*) contentOfOutlioneView;


@end
