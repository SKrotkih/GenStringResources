//  GenStringResources
//
//  QOTranslateStrings.h
//
//  Created by Sergey Krotkih on 05.03.11.
//  Copyright 2011 Quickoffice. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface QOTranslateStrings : NSObject 
{
    NSWindow* parentWindow;
}

-(QOTranslateStrings*) initWithWindow: (NSWindow*) aWindow;
-(NSString*) translateLocalizableStrings: (NSString*) aStrings targetLanguage: (NSString*) atargetLanguage;
-(NSString*) translatedString: (NSString*) string sourceLanguage: (NSString*) sourceLanguageIdentifier targetLanguage: (NSString*)sourceLanguageIdentifier;
-(void) translateArrayOfDictionarys: (NSMutableArray*)aArray targetLanguage: (NSString*)atargetLanguage;

@end
