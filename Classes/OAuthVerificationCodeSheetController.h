//
//  OAuthVerificationCodeSheetController.h
//  SAPOFotosApertureExportPlugin
//
//  Created by Pedro Gomes on 4/6/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface OAuthVerificationCodeSheetController : NSWindowController 
{
	IBOutlet NSTextField	*verificationCodeTextField;
	NSObject				*delegate;
}

@property (nonatomic, assign) NSObject *delegate;

- (IBAction)cancel:(id)sender;
- (IBAction)verify:(id)sender;

@end

@interface NSObject(OAuthVerificationCodeSheetControllerDelegate)

- (void)verificationCodeController:(OAuthVerificationCodeSheetController *)controller didFinishWithCode:(NSString *)verificationCode;
- (void)verificationCodeControllerDidCancel:(OAuthVerificationCodeSheetController *)controller;

@end
