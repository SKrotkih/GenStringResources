//  GenStringResources
//
//  QOSharedLibrary.m
//
//  Created by Sergey Krotkih on 13.02.11.
//  Copyright 2011 Quickoffice. All rights reserved.
//

#import "QOSharedLibrary.h"

@interface NSMutableDictionary (WithResourcesStringsLng)
+(NSMutableDictionary*) dictionaryWithLocalizedStringsText: (NSString*) text;
@end

@implementation NSMutableDictionary (WithResourcesStringLng)

+(NSMutableDictionary*) dictionaryWithLocalizedStringsText: (NSString*) text
{
    NSArray* lines = [text componentsSeparatedByString: @"\n"];
    NSEnumerator* linesStream = [lines objectEnumerator];    
    
    NSString* comment = @"";
    NSString* line;
    
    NSMutableDictionary* lngDictionary = [[NSMutableDictionary alloc] init];
    NSMutableArray* arrayOfcomments = [[NSMutableArray alloc] init];
    while(line = [linesStream nextObject]) 
    {
        NSMutableString* key;
        NSMutableString* value;
        if ([QOSharedLibrary parseStringToKeyAndValue: line 
                                               getKey: &key 
                                             getValue: &value] == YES) 
        {
            NSString* currkey = [NSString stringWithFormat: @"%@ = %@", key, value];
            NSString* currvalue = [lngDictionary objectForKey: currkey];
            if (currvalue == nil) 
            {
                [lngDictionary setObject: comment forKey: currkey];
            }
            else
            {
                currvalue = [currvalue stringByAppendingString: comment];
                [lngDictionary setObject: currvalue forKey: currkey];                
            }

            comment = @"";
            [arrayOfcomments removeAllObjects];            
        }
        else if ([line length] > 0) 
        {
            if ([arrayOfcomments indexOfObject: line] == NSNotFound)
            {
                [arrayOfcomments addObject: line];
                comment = [comment stringByAppendingString: line]; 
                comment = [comment stringByAppendingString: @"\n"];
            }
        }
    }

    return [lngDictionary retain];
}

@end

@implementation QOSharedLibrary


+ (BOOL) deleteFile: (NSString*) aFileName
{
    if ([[NSFileManager defaultManager] fileExistsAtPath: aFileName] == YES)
    {
        return [[NSFileManager defaultManager] removeItemAtPath: aFileName error: NULL];
    }
    
    return YES;
}

+ (void) createDirectory: (NSString*) path
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath: path] == NO)
    {
        [fileManager createDirectoryAtPath : path 
                withIntermediateDirectories: YES 
                                 attributes: nil 
                                      error: nil];    
    }
}

+(BOOL) isDirectory: (NSString*)path
{
    NSDictionary* attribs = [[NSFileManager defaultManager] attributesOfItemAtPath: path 
                                                                             error: NULL];
    NSString* fileType = [attribs objectForKey: NSFileType];
    return [fileType isEqual: NSFileTypeDirectory];
}

+ (NSMutableDictionary*) dictionaryFromLocalizedStringText: (NSString*) text
{
    return [NSMutableDictionary dictionaryWithLocalizedStringsText: text];
}    

+ (void) orderingOnKeyStringsDataInFile: (NSString*) aFileName
{
    NSError* error;
    NSString* text = [NSString stringWithContentsOfFile: aFileName 
                                               encoding: NSUTF16StringEncoding 
                                                  error: &error];
    NSMutableDictionary* lngDictionary = [NSMutableDictionary dictionaryWithLocalizedStringsText: text];
    NSArray* arrSort = [[lngDictionary allKeys] sortedArrayUsingSelector: @selector(compare:)];
    
    NSString* sortedText = @"";    
    for(NSString* key in arrSort)
    {
        sortedText = [sortedText stringByAppendingString: [lngDictionary objectForKey: key]];
        sortedText = [sortedText stringByAppendingString: key]; 
        sortedText = [sortedText stringByAppendingString: @"\n\n"];        
    }
    
    error = nil;
    [sortedText writeToFile: aFileName 
                 atomically: YES 
                   encoding: NSUTF16StringEncoding 
                      error: &error];	    
}

+ (void) createDirectoryForFullFilePath: (NSString*) aFullPath
{
    NSArray* pathComponents = [aFullPath pathComponents];
    
    NSMutableString* dstDirectory = [NSMutableString stringWithString: @""];
    
    NSUInteger i0 = 0;
    
    if ([(NSString*)[pathComponents objectAtIndex: 0] isEqualToString: @"/"])
    {
        i0 = 1;
    }
    
    for (NSUInteger i = i0; i < [pathComponents count] - 1; i++)
    {
        [dstDirectory appendString: [NSString stringWithFormat: @"/%@", [pathComponents objectAtIndex: i]]];
    }
    
    [QOSharedLibrary createDirectory: dstDirectory];
}

+ (BOOL) parseStringToKeyAndValue: (NSString*) aStr getKey: (NSMutableString**) aKey getValue: (NSMutableString**) aValue
{
    if (([aStr length] > 0) && [[aStr substringToIndex: 1] isEqualToString: @"\""] )
    {
        aStr =[aStr stringByReplacingOccurrencesOfString: @"\"=\"" 
                                              withString: @"\" = \""];
        aStr =[aStr stringByReplacingOccurrencesOfString: @"\" =\"" 
                                              withString: @"\" = \""];
        aStr =[aStr stringByReplacingOccurrencesOfString: @"\"= \"" 
                                              withString: @"\" = \""];
        NSArray* key_value = [aStr componentsSeparatedByString: @" = "];
        if (2 == [key_value count]) 
        {
            *aKey = [[NSString stringWithString: [key_value objectAtIndex: 0]] mutableCopy];
            *aValue = [[NSString stringWithString: [key_value objectAtIndex: 1]] mutableCopy];
            return YES;
        }
    }
    
    return NO;
}

+ (void) createNewEnglishResourceFromLocalicableStringsPath: (NSString*) path
{
         // Create dictionary of origial english strings
         NSMutableDictionary* lngDictionary = [[NSMutableDictionary alloc] init];
         
         NSString* lngFilePath = [NSString stringWithFormat:@"%@/en/Localizable.strings", path];
         NSError* error = nil;
         NSString* components = [NSString stringWithContentsOfFile: lngFilePath
                                                          encoding: NSUTF8StringEncoding
                                                             error: &error];
         NSArray* engLines = [components componentsSeparatedByString: @"\n"];
         
         NSEnumerator* enenum = [engLines objectEnumerator];
         NSString* str;
         while(str = [enenum nextObject])
         {
             NSMutableString* key;
             NSMutableString* value;
             if (YES == [QOSharedLibrary parseStringToKeyAndValue: str
                                                           getKey: &key
                                                         getValue: &value])
             {
                 [lngDictionary setObject:value forKey:key];
             }
         }
         
         // Etalon
         NSString* srcFilePath = [NSString stringWithFormat: @"%@/Localizable.strings", path];
         NSArray* srcLines = [[NSString stringWithContentsOfFile: srcFilePath
                                                        encoding: NSUTF16StringEncoding
                                                           error: &error] componentsSeparatedByString: @"\n"];
         
         NSEnumerator* ennse = [srcLines objectEnumerator];
         NSString* text = @"";
         NSString* srcStr;
         while(srcStr = [ennse nextObject])
         {
             NSMutableString* key;
             NSMutableString* value;
             if (YES == [QOSharedLibrary parseStringToKeyAndValue: srcStr
                                                           getKey: &key
                                                         getValue: &value])
             {
                 text = [text stringByAppendingString: key];
                 text = [text stringByAppendingString: @" = "];
                 
                 NSString* englishOrgValue = [lngDictionary objectForKey: key];
                 if (nil == englishOrgValue)
                 {
                     text = [text stringByAppendingString: key];
                     text = [text stringByAppendingString: @";\n"];
                 }
                 else
                 {
                     text = [text stringByAppendingString: englishOrgValue];
                     text = [text stringByAppendingString: @"\n"];
                 }
             }
             else
             {
                 text = [text stringByAppendingString: srcStr];
                 text = [text stringByAppendingString: @"\n"];
             }
         }
         [lngDictionary release];
         NSString* enFilePath = [NSString stringWithFormat:@"%@%@", path, @"/en.txt"];
         [text writeToFile: enFilePath 
                atomically: YES 
                  encoding: NSUTF16StringEncoding 
                     error: &error];	    
}

+ (void) createNewLocalizableStringsForLng: (NSString*)lng path: (NSString*) path
{
         NSError* error;
         
         NSString* lngFilePath = [NSString stringWithFormat: @"%@/%@/Localizable.strings", path, lng];
         error = nil;
         NSString* components = [NSString stringWithContentsOfFile: lngFilePath
                                                          encoding: NSUTF8StringEncoding
                                                             error: &error];
         if (components == nil)
         {
             components = [NSString stringWithContentsOfFile: lngFilePath
                                                    encoding: NSUnicodeStringEncoding
                                                       error: &error];
         }
         NSArray* lngLines = [components componentsSeparatedByString:@"\n"];
         
         // Etalon
         NSString* srcFilePath = [NSString stringWithFormat: @"%@/Localizable.strings", path];
         NSArray* engLines = [[NSString stringWithContentsOfFile: srcFilePath
                                                        encoding: NSUTF16StringEncoding
                                                           error: &error] componentsSeparatedByString: @"\n"];
         
         NSString* text = @"";
         NSEnumerator* engStream = [engLines objectEnumerator];
         NSString* engStr;
         while (engStr = [engStream nextObject])
         {
             NSMutableString* keyEng;
             NSMutableString* v;
             if (YES == [QOSharedLibrary parseStringToKeyAndValue: engStr
                                                           getKey: &keyEng
                                                         getValue: &v])
             {
                 NSEnumerator* lngStream = [lngLines objectEnumerator];
                 NSString* lngString = @"\"NO TRANSLATION\";";
                 NSString* lngStr;
                 while(lngStr = [lngStream nextObject])
                 {
                     NSMutableString* keyLng;
                     NSMutableString* valueLng;
                     if (YES == [QOSharedLibrary parseStringToKeyAndValue: lngStr
                                                                   getKey: &keyLng
                                                                 getValue: &valueLng])
                     {
                         if ([keyLng isEqualToString: keyEng])
                         {
                             lngString = [NSString stringWithString:valueLng];
                             break;
                         }
                     }
                 }
                 text = [text stringByAppendingString: keyEng];
                 text = [text stringByAppendingString: @" = "];
                 text = [text stringByAppendingString: lngString];
                 text = [text stringByAppendingString: @"\n"];
             }
             else
             {
                 // save comments
                 text = [text stringByAppendingString: engStr];
                 text = [text stringByAppendingString: @"\n"];
             }
         }
         
         NSString* lngDestFilePath = [NSString stringWithFormat: @"%@/%@.txt", path, lng];
         [text writeToFile: lngDestFilePath 
                atomically: YES  
                  encoding: NSUTF16StringEncoding 
                     error: &error];
}

+ (NSString*) noTranslationCreateFileForLngAndPath: (NSString*)alng path: (NSString*) path
{
    NSString* filePath = [NSString stringWithFormat:@"%@/%@.txt", path, alng];
    NSError* error;

    NSString* context = [NSString stringWithContentsOfFile: filePath 
                                                  encoding: NSUTF16StringEncoding 
                                                     error: &error];
    NSArray* lngLines = [context componentsSeparatedByString: @"\n"];
    NSEnumerator* lngStream = [lngLines objectEnumerator];    
    
    NSInteger cntLines = 0; 
    NSInteger cntNoTranslationLines = 0; 
    NSString* noTranslationStr = @"";
    
    NSString* str;
    NSString* commentBeforeString = @"";
    while(str = [lngStream nextObject]) 
    {
        NSMutableString* key;
        NSMutableString* value;
        if (YES == [QOSharedLibrary parseStringToKeyAndValue: str 
                                                            getKey: &key 
                                                          getValue: &value]) 
        {
            cntLines++;
            if ([value rangeOfString: @"TRANSLAT"].location != NSNotFound)
            {
                cntNoTranslationLines++; 
                noTranslationStr = [noTranslationStr stringByAppendingString: commentBeforeString]; 
                noTranslationStr = [noTranslationStr stringByAppendingString: @"\n"];
                noTranslationStr = [noTranslationStr stringByAppendingString: [NSString stringWithFormat: @"%@ = \"\";\n\n", key]]; 
            } 
            commentBeforeString = @"";
        }
        else 
        {
            commentBeforeString = [commentBeforeString stringByAppendingString: str]; 
        }

    }
    
    if ([noTranslationStr length] > 0) 
    {
        NSString* noTranslationFilePath = [NSString stringWithFormat:@"%@/%@_NO_TRANSLATION.txt", path, alng];
        [noTranslationStr writeToFile: noTranslationFilePath 
                           atomically: YES 
                             encoding: NSUTF16StringEncoding 
                                error: &error];	    
    }
    
    return [NSString stringWithFormat:@"%ld [%ld]", cntLines, cntNoTranslationLines];
}

+(void) saveLocalizableStrings: (NSString*)aFileName content: (NSString*) aContent
{
         if ([[NSFileManager defaultManager] fileExistsAtPath: aFileName] == YES)
         {
             NSError* error = nil;
             if ([[NSFileManager defaultManager] removeItemAtPath: aFileName error: &error] == NO)
             {
                 NSLog(@"Error while removing file %@", aFileName);
                 return;
             }
         }
         
         [[NSFileManager defaultManager] createFileAtPath: aFileName contents: nil attributes: nil];
         NSFileHandle* outputHandle = [NSFileHandle fileHandleForWritingAtPath: aFileName];
         [outputHandle seekToEndOfFile];
         
         NSArray* srcLines = [aContent componentsSeparatedByString: @"\n"];
         NSEnumerator* srcStream = [srcLines objectEnumerator];
         NSString* line;
         while (line = [srcStream nextObject])
         {
             [outputHandle writeData: [line dataUsingEncoding: NSUTF8StringEncoding]];    // NSUnicodeStringEncoding
             line = @"\n";
             [outputHandle writeData: [line dataUsingEncoding: NSUTF8StringEncoding]];
         }
}

+(BOOL) mergeTranslatedStringsToFileName: (NSString*) aFileName data: (NSString*) translatedStrings
{
    if ([[NSFileManager defaultManager] fileExistsAtPath: aFileName] == NO) 
    {
        return NO;
    }
    
    NSError* error = nil;
    NSString* contentOfFile = [NSString stringWithContentsOfFile: aFileName 
                                                        encoding: NSUTF16StringEncoding 
                                                           error: &error];
    NSArray* srcLines = [contentOfFile componentsSeparatedByString: @"\n"];
    NSEnumerator* srcStream = [srcLines objectEnumerator];    

    NSArray* translatedLines = [translatedStrings componentsSeparatedByString: @"\n"];    
    
    NSString* engStr;
    NSString* text = @"";
    NSInteger mergedCount = 0;
    while (engStr = [srcStream nextObject]) 
    {

        NSMutableString* keyEng;
        NSMutableString* v;
        if ([QOSharedLibrary parseStringToKeyAndValue: engStr 
                                               getKey: &keyEng 
                                             getValue: &v] == YES) 
        {
            NSEnumerator* translatedStream = [translatedLines objectEnumerator];    
            NSString* lngStr;
            BOOL keyFound = NO;
            while(lngStr = [translatedStream nextObject]) 
            {
                NSMutableString* keyLng;
                NSMutableString* valueLng;
                if (YES == [QOSharedLibrary parseStringToKeyAndValue: lngStr 
                                                              getKey: &keyLng 
                                                            getValue: &valueLng]) 
                {
                    if ([keyLng isEqualToString: keyEng] && [valueLng length] > 2)
                    {
                        text = [text stringByAppendingString: keyEng]; 
                        text = [text stringByAppendingString: @" = "]; 
                        text = [text stringByAppendingString: valueLng];                             
                        text = [text stringByAppendingString: @"\n"];
                        keyFound = YES;
                        mergedCount++;
                        break;
                    }    
                }
            }
            if (keyFound == NO) 
            {
                text = [text stringByAppendingString: engStr];                             
                text = [text stringByAppendingString: @"\n"];
            }
        }
        else 
        {
            // save comments
            text = [text stringByAppendingString: engStr]; 
            text = [text stringByAppendingString: @"\n"];         
        }
    }
    if (mergedCount > 0) 
    {
        error = nil;
        [text writeToFile: aFileName 
               atomically: YES 
                 encoding: NSUTF16StringEncoding 
                    error: &error];
        if (error == 0) 
        {
            return YES;
        }
    }
    return NO;    
}

+(void) convertText: (NSString*)aText forLng: (NSString*)aLng forProject: (NSString*)aProject toDictionary: (NSMutableArray**) pRecordsArray
{
    NSArray* lines = [aText componentsSeparatedByString: @"\n"];
    NSEnumerator* linesStream = [lines objectEnumerator];    
    NSString* text = @"";
    NSString* line;
    while(line = [linesStream nextObject]) 
    {
        NSMutableString* key;
        NSMutableString* value;
        if ([QOSharedLibrary parseStringToKeyAndValue: line 
                                               getKey: &key 
                                             getValue: &value] == YES) 
        {
            NSString* key_ =    [[NSString stringWithString: key] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];            
            NSString* value_ =  [[NSString stringWithString: value] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];

            if ([[key_ substringWithRange: NSMakeRange(0, 1)] isEqualToString: @"\""]) 
            {
                key_ = [key_ substringFromIndex: 1];
            }
            if ([[key_ substringWithRange: NSMakeRange([key_ length] - 1, 1)] isEqualToString: @"\""]) 
            {
                key_ = [key_ substringToIndex: [key_ length] - 1];
            }
            if ([[value_ substringWithRange: NSMakeRange(0, 1)] isEqualToString: @"\""]) 
            {
                value_ = [value_ substringFromIndex: 1];
            }
            if ([[value_ substringWithRange: NSMakeRange([value_ length] - 1, 1)] isEqualToString: @";"]) 
            {
                value_ = [value_ substringToIndex: [value_ length] - 1];
            }
            if ([[value_ substringWithRange: NSMakeRange([value_ length] - 1, 1)] isEqualToString: @"\""]) 
            {
                value_ = [value_ substringToIndex: [value_ length] - 1];
            }
            
            NSArray* keys = [NSArray arrayWithObjects: @"lng", @"key", @"value", @"comment", @"project", nil];
            NSArray* objects = [NSArray arrayWithObjects: aLng, key_, value_, text, aProject, nil];
            NSMutableDictionary* dictionary = [NSMutableDictionary dictionaryWithObjects: objects forKeys: keys];
            [*pRecordsArray addObject: dictionary];
            text = @"";
        }
        else 
        {
            NSString* comment = [[text stringByAppendingString: line] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([comment length] > 0) 
            {
                text = comment; 
                text = [text stringByAppendingString: @";"]; 
            }
        }
    }
}

+(void) addToDictionary: (NSMutableArray**) pDictionary forLng: (NSString*)aLng forProject: (NSString*)aProject fromFile: (NSString*) aFileName withEncoding: (NSStringEncoding) aEncoding
{
    NSError* error;
    NSString* text = [NSString stringWithContentsOfFile: aFileName 
                                               encoding: aEncoding 
                                                  error: &error]; 
    [QOSharedLibrary convertText: text 
                          forLng: aLng 
                      forProject: aProject 
                    toDictionary: pDictionary];
}

+(void) mergeDictionary: (NSMutableArray**) pDictionary fromFile: (NSString*) aFileName withEncoding: (NSStringEncoding) anEncoding
{
    NSError* error;
    NSString* text = [NSString stringWithContentsOfFile: aFileName 
                                               encoding: anEncoding 
                                                  error: &error];
    NSMutableArray* arr = [[NSMutableArray alloc] init];
    [QOSharedLibrary convertText: text 
                          forLng: @""
                      forProject: @"" 
                    toDictionary: &arr];
    NSEnumerator* dictStream = [arr objectEnumerator];    
    NSDictionary* dict;
    while(dict = [dictStream nextObject]) 
    {
        NSString* key = [dict objectForKey: @"key"];
        NSString* value = [dict objectForKey: @"value"];
        NSEnumerator* dictOrgStream = [*pDictionary objectEnumerator];    
        NSMutableDictionary* dictOrg;
        while(dictOrg = [dictOrgStream nextObject]) 
        {
            if ([[dictOrg objectForKey: @"key"] isEqualToString: key]) 
            {
                [dictOrg setObject: value forKey: @"value"];
            }
        }            
    }
    [arr release];
}

+ (void) saveDictionary: (NSMutableArray*) recordsArray toText: (NSString**) pText
{
    *pText = @"";
    NSEnumerator* dictsStream = [recordsArray objectEnumerator];    
    NSDictionary* currDict;
    while((currDict = [dictsStream nextObject]) != nil) 
    {
        NSString* comment =[currDict objectForKey: @"comment"];
        comment =[comment stringByReplacingOccurrencesOfString: @";" 
                                           withString: @""];
        comment =[comment stringByReplacingOccurrencesOfString: @"*//*" 
                                           withString: @"*/\n/*"];
        NSArray* arrComments = [comment componentsSeparatedByString: @"\n"];
        NSMutableArray* comments = [[NSMutableArray alloc] init]; 
        NSMutableString* outputComment = [[NSMutableString alloc] init];
        for (NSString* currComment in arrComments) 
        {
            BOOL exist = NO;
            for (NSString* str in comments)
            {
                if ([str isEqualToString: currComment] == YES) 
                {
                    exist = YES;
                    break;
                }
            }

            if (exist == NO) 
            {
                [comments addObject: currComment];
                [outputComment appendFormat: @"%@\n", currComment];
            }
            
        }
        if ([outputComment length] == 0)
        {
            [outputComment appendFormat: @"%@\n", comment];
        }

        *pText = [*pText stringByAppendingString: [NSString stringWithFormat: @"\n%@\"%@\" = \"%@\";\n", outputComment, [currDict objectForKey: @"key"], [currDict objectForKey: @"value"]]];         

        [comments release];
        [outputComment release];
    }
}    

+(void) saveDictionary: (NSMutableArray*) recordsArray toFile: (NSString*) aFileName withEncoding: (NSStringEncoding) aEncoding
{
    NSString* text = @""; 
    [QOSharedLibrary saveDictionary: recordsArray 
                             toText: &text];
    NSError* error = nil;
    [text writeToFile: aFileName 
           atomically: YES 
             encoding: aEncoding 
                error: &error];    
}

+(void) afterSaveDialogforWindow: (NSWindow* )window callSelector: (SEL)aSelector forObj: (id)aObj 
{
    NSSavePanel* savePanel = [NSSavePanel savePanel];
    [savePanel setTreatsFilePackagesAsDirectories: NO];
    [savePanel beginSheetModalForWindow: window completionHandler: ^(NSInteger result) 
     {
         if (result == NSOKButton) 
         {
             [savePanel orderOut: self];
             [aObj performSelector: aSelector withObject: [[savePanel URL] absoluteString] afterDelay:0.0];
         }
     }];
}


+(void) afterSaveToDirectoryDialogforWindow: (NSWindow* )window callSelector: (SEL)aSelector forObj: (id)aObj 
{
    NSSavePanel* savePanel = [NSSavePanel savePanel];
    [savePanel setTreatsFilePackagesAsDirectories: YES];
    [savePanel beginSheetModalForWindow: window completionHandler: ^(NSInteger result) 
     {
         if (result == NSOKButton) 
         {
             [savePanel orderOut: self];
             [aObj performSelector: aSelector withObject: [[savePanel URL] absoluteString] afterDelay:0.0];
         }
     }];
}


+(void) afterOpenFileDialogforWindow: (NSWindow* )window callSelector: (SEL)aSelector forObj: (id)aObj 
{
    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
    [openPanel setTreatsFilePackagesAsDirectories: NO];
    [openPanel beginSheetModalForWindow: window completionHandler: ^(NSInteger result) 
     {
         if (result == NSOKButton) 
         {
             [openPanel orderOut: self];
             [aObj performSelector: aSelector withObject: [[openPanel URL] absoluteString] afterDelay:0.0];
         }
     }];
}

+ (void) mergeLocStr: aLocalizableStringsFileName 
         withLngFile: fileWithLngStrings 
              toFile: fileNewLocStrRes
{
    NSError* error;
    error = nil;
    NSString* mainContent = [NSString stringWithContentsOfFile: aLocalizableStringsFileName 
                                                     encoding: NSUTF8StringEncoding 
                                                        error: &error];
    if (mainContent == nil)
    {
        mainContent = [NSString stringWithContentsOfFile: aLocalizableStringsFileName 
                                               encoding: NSUnicodeStringEncoding 
                                                  error: &error];        
    }
    NSArray* mainLines = [mainContent componentsSeparatedByString:@"\n"];
    
    // Etalon 
    NSArray* lngLines = [[NSString stringWithContentsOfFile: fileWithLngStrings 
                                                   encoding: NSUTF16StringEncoding 
                                                      error: &error] componentsSeparatedByString: @"\n"];
    
    NSString* text = @"";
    NSEnumerator* mainStream = [mainLines objectEnumerator];    
    NSString* mainStr;
    while (mainStr = [mainStream nextObject]) 
    {
        NSMutableString* keyMain;
        NSMutableString* v;
        if (YES == [QOSharedLibrary parseStringToKeyAndValue: mainStr 
                                                      getKey: &keyMain 
                                                    getValue: &v]) 
        {
            NSEnumerator* lngStream = [lngLines objectEnumerator];    
            NSString* lngString = @"\"NO TRANSLATION\";";
            NSString* lngStr;
            while(lngStr = [lngStream nextObject]) 
            {
                NSMutableString* keyLng;
                NSMutableString* valueLng;
                if (YES == [QOSharedLibrary parseStringToKeyAndValue: lngStr 
                                                              getKey: &keyLng 
                                                            getValue: &valueLng]) 
                {
                    if ([keyLng isEqualToString: keyMain])
                    {
                        lngString = [NSString stringWithString:valueLng];
                        break;
                    }    
                }
            }
            text = [text stringByAppendingString: keyMain]; 
            text = [text stringByAppendingString: @" = "]; 
            text = [text stringByAppendingString: lngString];                             
            text = [text stringByAppendingString: @"\n"];
        }
        else 
        {
            // save comments
            text = [text stringByAppendingString: mainStr]; 
            text = [text stringByAppendingString: @"\n"];         
        }
    }
    
    [text writeToFile: fileNewLocStrRes 
           atomically: YES  
             encoding: NSUTF16StringEncoding 
                error: &error];
}

@end
