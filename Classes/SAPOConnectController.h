//
//  SAPOConnectController.h
//  SAPOFotosApertureExportPlugin
//
//  Created by Pedro Gomes on 3/16/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <GTMOAuth/GTMOAuthAuthentication.h>

@class GTMOAuthSignIn;
@class GTMOAuthAuthentication;

@interface SAPOConnectController : NSObject 
{
	NSObject				*delegate;
	NSWindow				*modalWindow;
	GTMOAuthSignIn			*authSignIn;
}

@property (nonatomic, assign) NSObject *delegate;

- (void)authorize;
- (BOOL)authorizeFromKeychain;
- (BOOL)signOut;
- (void)setVerificationCode:(NSString *)verificationCode forAuth:(GTMOAuthAuthentication *)auth;

@end

@interface NSObject(SAPOConnectControllerDelegate)

- (void)authControllerDidStartAuth:(SAPOConnectController *)controller;
- (void)authControllerDidCancelAuth:(SAPOConnectController *)controller;
- (void)authController:(SAPOConnectController *)controller didFinishWithAuth:(GTMOAuthAuthentication *)auth;
- (void)authController:(SAPOConnectController *)controller didFailWithError:(NSError *)error;
- (void)authController:(SAPOConnectController *)controller didRequestVerificationCodeForAuth:(GTMOAuthAuthentication *)auth;

@end
