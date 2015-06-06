//  QOLocalizableStrings
//
//  QOSharedLibrary.h
//
//  Created by Sergey Krotkih on 13.02.11.
//  Copyright 2011 Quickoffice. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface QOSharedLibrary: NSObject 
{
    
}

+ (void) createNewEnglishResourceFromLocalicableStringsPath: (NSString*) path;
+ (BOOL) parseStringToKeyAndValue: (NSString*)astr getKey: (NSMutableString**)akey getValue: (NSMutableString**)avalue;
+ (void) createNewLocalizableStringsForLng: (NSString*)lng path: (NSString*) path;
+ (void) createDirectoryForFullFilePath: (NSString*) aFullPath;
+ (NSString*) noTranslationCreateFileForLngAndPath: (NSString*) alng path: (NSString*) path;
+ (void) orderingOnKeyStringsDataInFile: (NSString*) aFileName;
+ (BOOL) mergeTranslatedStringsToFileName: (NSString*) aFileName data: (NSString*) translatedStrings;
+ (void) saveLocalizableStrings: (NSString*) fileName content: (NSString*) aContent;
+ (BOOL) deleteFile: (NSString*) aFileName;
+ (void) createDirectory: (NSString*) path;
+ (void) addToDictionary: (NSMutableArray**) pDictionary forLng: (NSString*)aLng forProject: (NSString*)aProject fromFile: (NSString*) aFileName withEncoding: (NSStringEncoding) aEncoding;
+ (void) mergeDictionary: (NSMutableArray**) pDictionary fromFile: (NSString*) aFileName withEncoding: (NSStringEncoding) anEncoding;
+ (void) saveDictionary: (NSMutableArray*) recordsArray toFile: (NSString*) aFileName withEncoding: (NSStringEncoding) aEncoding;
+ (void) saveDictionary: (NSMutableArray*) recordsArray toText: (NSString**) pText;
+ (void) afterOpenFileDialogforWindow: (NSWindow* )window callSelector: (SEL)aSelector forObj: (id)aObj;
+ (void) convertText: (NSString*)aText forLng: (NSString*)aLng forProject: (NSString*)aProject toDictionary: (NSMutableArray**) pRecordsArray;
+ (void) afterSaveDialogforWindow: (NSWindow *)window callSelector: (SEL)aSelector forObj: (id)aObj;
+ (void) afterSaveToDirectoryDialogforWindow: (NSWindow* )window callSelector: (SEL)aSelector forObj: (id)aObj;
+ (BOOL)isDirectory: (NSString*)path;
+ (NSMutableDictionary*) dictionaryFromLocalizedStringText: (NSString*) text;
+ (void) mergeLocStr: aLocalizableStringsFileName withLngFile: fileWithLngStrings toFile: fileNewLocStrRes;

@end
