//
//  QOModuleStrings.m
//  GenStringResources
//
//  Created by Sergey Krotkih on 22.05.11.
//  Copyright 2011 Quickoffice. All rights reserved.
//

#import "QOModuleStrings.h"

@implementation QOModuleStrings

@synthesize moduleName;

-(id) initWithLocalizableStrings: (NSArray*) aLocalizableStrings inModule: (NSString*) aModuleName
{
	self = [super init];
	if( self )
	{
        localizableStrings = [aLocalizableStrings retain];
        self.moduleName = aModuleName;
	}
	
	return self;
}

+(QOModuleStrings*) createObjectWithContentFromArray: (NSArray*)aArrayOfContent atIndex: (int*)pI
{
    if (*pI < [aArrayOfContent count]) 
    {
        NSString* aMmoduleName = [aArrayOfContent objectAtIndex: *pI];
        NSMutableArray* aLocalizableStrings = [[NSMutableArray alloc] init];
        while (++(*pI) < [aArrayOfContent count]) 
        {
            NSString* str = [aArrayOfContent objectAtIndex: *pI];
            if ([str length] > 0 && [[str substringToIndex: 1] isEqualToString: @"#"]) 
            {
                str = [str substringFromIndex: 1];
                [aLocalizableStrings addObject: str]; 
            }
            else 
            {
                break;
            }
        }
        
        QOModuleStrings* object = [[QOModuleStrings alloc] initWithLocalizableStrings: aLocalizableStrings inModule: aMmoduleName];
        [aLocalizableStrings release];

        return [object autorelease];
    }
    else 
    {
        return nil;
    }
}

-(void) dealloc
{
    [localizableStrings release];
    moduleName = nil;
    
    [super dealloc];
}

-(NSString*) description
{
	return moduleName;
}

-(int) count
{
	return [localizableStrings count];
}

-(id) objectAtIndex: (int) n
{
    return [localizableStrings objectAtIndex: n];
}

-(NSString*) contentOfOutlioneView
{
    NSString* content = [NSString stringWithFormat: @"%@\n", moduleName];
    for (int i = 0; i < [localizableStrings count]; i++) 
    {
        content = [content stringByAppendingString: @"#"];
        content = [content stringByAppendingString: [localizableStrings objectAtIndex: i]];
        content = [content stringByAppendingString: @"\n"];
    }    
    return content;
}

@end
