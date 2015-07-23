//  GenStringResources
//
//  QOCompareStrings.h
//
//  Created by Sergey Krotkih on 27.03.11.
//  Copyright 2011 Quickoffice. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface QOCompareStrings: NSObject 
{
    
}

+ (int) distanceSimilarStrings: (NSString*) str1 secondStr: (NSString*) str2;

@end