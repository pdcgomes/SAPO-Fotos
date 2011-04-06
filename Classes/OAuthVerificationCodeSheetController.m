//
//  OAuthVerificationCodeSheetController.m
//  SAPOFotosApertureExportPlugin
//
//  Created by Pedro Gomes on 4/6/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "OAuthVerificationCodeSheetController.h"

@implementation OAuthVerificationCodeSheetController

@synthesize delegate;

#pragma mark -
#pragma mark Actions

- (IBAction)cancel:(id)sender
{
	if([self.delegate respondsToSelector:@selector(verificationCodeControllerDidCancel:)]) {
		[self.delegate verificationCodeControllerDidCancel:self];
	}
}

- (IBAction)verify:(id)sender
{
	if([self.delegate respondsToSelector:@selector(verificationCodeController:didFinishWithCode:)]) {
		NSString *verificationCode = [[verificationCodeTextField stringValue] copy];
		[self.delegate verificationCodeController:self didFinishWithCode:[verificationCode autorelease]];
	}
}

@end
