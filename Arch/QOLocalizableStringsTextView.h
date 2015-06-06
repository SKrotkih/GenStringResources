//  QOLocalizableStrings
//
//  QOLocalizableStringsTextView.h
//
//  Created by Sergey Krotkih on 23.02.11.
//  Copyright 2011 Quickoffice. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum  
{
    TYPE_DATA_MAIN,
    TYPE_DATA_ORG,
    TYPE_DATA_NEW,
    TYPE_DATA_NO_TRANSLATION
} TYPE_FILE;


@class QOLocalizableStringsController;

@interface QOLocalizableStringsTextView : NSScrollView  <NSTextViewDelegate>
{
    QOLocalizableStringsController* appController;
    NSTextView* textView;    
    NSString* projectName;
    TYPE_FILE typeFile;
    NSString* targetLanguage;
    NSString* sourceFile;
    NSString* targetFile;
    NSThread* thread;
}

@property(readwrite, nonatomic, assign) TYPE_FILE typeFile;
@property(readwrite, nonatomic, copy) NSString* sourceFile;
@property(readwrite, nonatomic, copy) NSString* targetFile;
@property(readwrite, nonatomic, copy) NSString* targetLanguage;
@property(readwrite, nonatomic, copy) NSString* projectName;

-(QOLocalizableStringsTextView*) initWithFile: (NSString*)aFileName encoding: (NSStringEncoding)enc;

@end
