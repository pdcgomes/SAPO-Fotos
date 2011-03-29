//
//  SAPOConnectController.h
//  SAPOFotosApertureExportPlugin
//
//  Created by Pedro Gomes on 3/16/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <GTMOAuth/GTMOAuthAuthentication.h>

@interface SAPOConnectController : NSObject 
{
	NSObject				*delegate;
}

@property (nonatomic, assign) NSObject *delegate;

- (void)authorize;

@end

@interface NSObject(SAPOConnectControllerDelegate)

- (void)authControllerDidStartAuth:(SAPOConnectController *)controller;
- (void)authControllerDidCancelAuth:(SAPOConnectController *)controller;
- (void)authController:(SAPOConnectController *)controller didFinishWithAuth:(GTMOAuthAuthentication *)auth;
- (void)authController:(SAPOConnectController *)controller didFailWithError:(NSError *)error;

@end
