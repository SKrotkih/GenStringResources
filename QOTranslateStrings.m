//  QOLocalizableStrings
//
//  QOTranslateStrings.m
//
//  Created by Sergey Krotkih on 05.03.11.
//  Copyright 2011 Quickoffice. All rights reserved.
//

#import "QOTranslateStrings.h"
#import "QOSharedLibrary.h"

@implementation QOTranslateStrings

-(QOTranslateStrings*) initWithWindow: (NSWindow*)aWindow
{
    if ((self = [super init]) != nil)
    {
        parentWindow = [aWindow retain];
    }

    return self;
}

-(void) dealloc
{
    [parentWindow release];
    
    [super dealloc];
}

/*
 Google Translator Toolkit Data API:
 http://code.google.com/apis/gtt/docs/1.0/reference.html#gtt:sourceLanguage

 Developer's guide
 http://code.google.com/apis/gtt/docs/1.0/developers_guide_protocol.html
 
 Language's type:
 http://www.iana.org/assignments/language-subtag-registry
 
 
 Login: sergey.krotkih@gmail.com Passw: ...
 https://www.google.com/accounts/Login
 */

-(NSString*) currentLanguageIdentifier
{
    static NSString* currentLanguage = nil;
    if (currentLanguage == nil) 
    {
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        NSArray* languages = [defaults objectForKey: @"AppleLanguages"];
        currentLanguage = [[languages objectAtIndex: 0] retain];
    }

    return currentLanguage;
}

// http://blog.jayway.com/2010/01/11/google-translate-and-iphone-apps/
-(NSString*) translatedString: (NSString*) string sourceLanguage: (NSString*) sourceLanguageIdentifier targetLanguage: (NSString*)targetLanguageIdentifier
{
    static NSString* queryURL = @"http://ajax.googleapis.com/ajax/services/language/translate?v=1.0&q=%@&langpair=%@%%7C%@";

    if (string == nil) 
    {
        return string;
    }
    if (sourceLanguageIdentifier == nil) 
    {
        sourceLanguageIdentifier = @"en";
    }
    if (targetLanguageIdentifier == nil) 
    {
        targetLanguageIdentifier = [self currentLanguageIdentifier];
    }
    if ([sourceLanguageIdentifier isEqualToString: targetLanguageIdentifier]) 
    {
        return string;
    }
    
    NSString* escapedString = [string stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    NSString* query = [NSString stringWithFormat: queryURL,
                       escapedString, 
                       sourceLanguageIdentifier, 
                       targetLanguageIdentifier];
    NSString* response = [NSString stringWithContentsOfURL: [NSURL URLWithString: query]
                                                  encoding: NSUTF8StringEncoding 
                                                     error: NULL];
    if (response == nil) 
    {
        return string;
    }
    NSScanner* scanner = [NSScanner scannerWithString:response];
    if (![scanner scanUpToString:@"\"translatedText\":\"" intoString:NULL]) 
    {
        return string;
    }
    if (![scanner scanString:@"\"translatedText\":\"" intoString: NULL]) 
    {
        return string;
    }
    NSString* result = nil;
    if (![scanner scanUpToString:@"\"}" intoString: &result]) 
    {
        return string;
    }
    return result;
}

-(NSString*) translateLocalizableStrings: (NSString*)aStrings targetLanguage: (NSString*)atargetLanguage
{
    NSArray* srcLines = [aStrings componentsSeparatedByString: @"\n"];
    NSEnumerator* srcStream = [srcLines objectEnumerator];    
    NSString* currStr;
    NSMutableString* text = [[NSMutableString alloc] initWithString: @""];
    while ((currStr = [srcStream nextObject]) != nil) 
    {
        NSMutableString* key;
        NSMutableString* value;
        if (([QOSharedLibrary parseStringToKeyAndValue: currStr 
                                                     getKey: &key 
                                                   getValue: &value] == YES) && ([value length] == 3))
        {
            NSString* strKey = key;
            strKey = [strKey stringByReplacingOccurrencesOfString: @"\""
                                                       withString: @""];
            
            NSString* translateString = [self translatedString: strKey 
                                                sourceLanguage: @"en" 
                                                targetLanguage: atargetLanguage]; 
            [text appendString: key]; 
            [text appendString: @" = \""]; 
            [text appendString: translateString];                             
            [text appendString: @"\";\n"];
        }
        else 
        {
            [text appendString: currStr]; 
            [text appendString: @"\n"];         
        }
    }
    
    return [text autorelease]; 
}

-(void) translateArrayOfDictionarys: (NSMutableArray*)aArray targetLanguage: (NSString*)atargetLanguage
{
    if (aArray == nil && [aArray count] == 0) 
    {
        return;
    }
    for (int i = 0; i < [aArray count]; i++)
    {
        NSMutableDictionary* dict = [aArray objectAtIndex: i];
        NSString* translatedString = [self translatedString: [dict objectForKey: @"key"]
                                             sourceLanguage: @"en" 
                                             targetLanguage: atargetLanguage]; 

        [dict setObject: translatedString forKey: @"value"];
    }
}

@end
