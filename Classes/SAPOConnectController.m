//
//  SAPOConnectController.m
//  SAPOFotosApertureExportPlugin
//
//  Created by Pedro Gomes on 3/16/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import <GTMOAuth/GTMOAuthSignIn.h>
#import <GTMOAuth/GTMOAuthWindowController.h>
#import "SAPOConnectController.h"

NSString *const SAPOConnectConsumerKey	= @"S1PvgeLQhyumTz9MOwIHBGJQvLhgCRbpzdTNnlYr_UcA";
NSString *const SAPOConnectPrivateKey	= @"T6r0EDXI9JvlmYaxehzZuVGHiAqft2O3w";

NSString *const SAPOConnectRequestTokenURL	= @"https://id.sapo.pt/oauth/request_token";
NSString *const SAPOConnectAccessTokenURL	= @"https://id.sapo.pt/oauth/access_token";
NSString *const SAPOConnectAuthorizationURL	= @"https://id.sapo.pt/oauth/authorize";
NSString *const SAPOConnectAuthenticateURL	= @"https://id.sapo.pt/oauth/authenticate";
NSString *const SAPOConnectCallbackURL		= @"http://fotos.sapo.pt/";
//NSString *const SAPOConnectCallbackURL		= @"oob";

NSString *const SAPOConnectServiceProvider	= @"SAPO Connect";
NSString *const kKeychainServiceName		= @"SAPO Fotos iPhoto Export Plugin";

@interface SAPOConnectController(Private)

- (GTMOAuthAuthentication *)sapoConnectAuthentication;
- (void)performSignIn;

@end

@implementation SAPOConnectController

@synthesize delegate;

#pragma mark -
#pragma mark Public class methods

#pragma mark -
#pragma mark Dealloc and Initialization

- (void)dealloc
{
	[modalWindow release];
	[authSignIn release];
	[super dealloc];
}

#pragma mark -
#pragma mark Actions

- (IBAction)authorize
{
	[self performSignIn];
}

- (BOOL)authorizeFromKeychain
{
	GTMOAuthAuthentication *auth = [self sapoConnectAuthentication];
	if([GTMOAuthWindowController authorizeFromKeychainForName:kKeychainServiceName authentication:auth] &&
	   [auth canAuthorize]) {
		if([self.delegate respondsToSelector:@selector(authController:didFinishWithAuth:)]) {
			[self.delegate authController:self didFinishWithAuth:auth];
		}
		return YES;
	}
	return NO;
}

- (BOOL)signOut
{
	return [GTMOAuthWindowController removeParamsFromKeychainForName:kKeychainServiceName];
}

- (void)setVerificationCode:(NSString *)verificationCode forAuth:(GTMOAuthAuthentication *)auth
{
	[auth setVerifier:verificationCode];
	[auth setCallback:SAPOConnectCallbackURL];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:SAPOConnectCallbackURL]];
	if([authSignIn requestRedirectedToRequest:request]) {
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]]; // let the network code run
	}
	[request release];
}
	
#pragma mark -
#pragma mark Private Methods

- (GTMOAuthAuthentication *)sapoConnectAuthentication
{
	GTMOAuthAuthentication *auth = [[GTMOAuthAuthentication alloc] initWithSignatureMethod:kGTMOAuthSignatureMethodHMAC_SHA1
																			   consumerKey:SAPOConnectConsumerKey 
																				privateKey:SAPOConnectPrivateKey];
	[auth setServiceProvider:SAPOConnectServiceProvider];
	[auth setCallback:@"oob"];
	[auth setShouldUseParamsToAuthorize:YES];
	
	return [auth autorelease];
}

- (void)performSignIn
{
	if([self.delegate respondsToSelector:@selector(authControllerDidStartAuth:)]) {
		[self.delegate authControllerDidStartAuth:self];
	}
	
	GTMOAuthAuthentication *auth = [self sapoConnectAuthentication];
	if([GTMOAuthWindowController authorizeFromKeychainForName:kKeychainServiceName authentication:auth] &&
	   [auth canAuthorize]) {
		if([self.delegate respondsToSelector:@selector(authController:didFinishWithAuth:)]) {
			[self.delegate authController:self didFinishWithAuth:auth];
		}
	}
	else {
		GTMOAuthAuthentication *auth = [self sapoConnectAuthentication];
		[auth setScope:@"http://fotos.sapo.pt/"];
		authSignIn = [[GTMOAuthSignIn alloc] initWithAuthentication:auth 
													requestTokenURL:[NSURL URLWithString:SAPOConnectRequestTokenURL] 
												  authorizeTokenURL:[NSURL URLWithString:SAPOConnectAuthorizationURL] 
													 accessTokenURL:[NSURL URLWithString:SAPOConnectAccessTokenURL] 
														   delegate:self 
												 webRequestSelector:@selector(signIn:shouldStartWithRequest:) 
												   finishedSelector:@selector(signIn:finishedWithAuth:error:)];
		[authSignIn startSigningIn];
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]]; // let the network code run
	}
}

#define RUNLOOP_ITERATIONS 2
- (void)signIn:(GTMOAuthSignIn *)signIn shouldStartWithRequest:(NSURLRequest *)request
{
	TRACE(@"Opening browser to ask user for authorization: %@", request);
	if(!request) {
		// this is "needed" (needed in the sense that I wasn't able to make it work any other way)
		// to ensure the inner workings of GTMOAuthSignIn that depend on GTMHTTPFetcher and a valid runloop work as expected
		// All of the plugin code is running on a modal session owned by the iPhoto window, this is causing various glitches that I wasn't yet able to fully understand
		// As a temporary workaround, we simply force the execution of the currentRunLoop
		int i = 0;
		for(i = 0; i < RUNLOOP_ITERATIONS; i++) {
			[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]]; // let the network code run
		}
		return;
	}
	
	[[NSWorkspace sharedWorkspace] openURL:[request URL]];
	
	if([self.delegate respondsToSelector:@selector(authController:didRequestVerificationCodeForAuth:)]) {
		[self.delegate authController:self didRequestVerificationCodeForAuth:[signIn authentication]];
	}
}

- (void)signIn:(GTMOAuthSignIn *)signIn finishedWithAuth:(GTMOAuthAuthentication *)auth error:(NSError *)error
{
	TRACE(@"");
	SKSafeRelease(signIn);
	
	if(!error) {
		if(![GTMOAuthWindowController saveParamsToKeychainForName:kKeychainServiceName authentication:auth]) {
			ERROR(@"Error while saving OAuth params to keychain.\nTODO: take proper action here...");
		}
		TRACE(@"CanAuthorize: %d", [auth canAuthorize]);
		if([self.delegate respondsToSelector:@selector(authController:didFinishWithAuth:)]) {
			[self.delegate authController:self didFinishWithAuth:auth];
		}
		return;
	}
	
	if([error code] == kGTMOAuthErrorWindowClosed) {
		if([self.delegate respondsToSelector:@selector(authControllerDidCancelAuth:)]) {
			[self.delegate authControllerDidCancelAuth:self];
		}
	}
	else {
		if([self.delegate respondsToSelector:@selector(authController:didFailWithError:)]) {
			[self.delegate authController:self didFailWithError:error];
		}
	}	
}

@end

