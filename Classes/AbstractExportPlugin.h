//
//  AbstractExportPlugin.h
//  SAPOFotosApertureExportPlugin
//
//  Created by Pedro Gomes on 2/22/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define kSession_IsAuthenticatingKey	@"isPerformingAuthentication"
#define kSession_IsAuthenticatedKey		@"isAuthenticated"

@interface AbstractExportPlugin : NSObject 
{
	NSString					*_nibName;
	// Top-level objects in the nib are automatically retained - this array
	// tracks those, and releases them
	NSArray						*_topLevelNibObjects;
	
	// Outlets to your plug-ins user interface
	IBOutlet NSView				*settingsView;
	IBOutlet NSView				*firstView;
	IBOutlet NSView				*lastView;
	
	IBOutlet NSTextField		*usernameTextField;
	IBOutlet NSTextField		*passwordTextField;
	
	IBOutlet NSPopUpButton		*albumsPopUpButton;
	IBOutlet NSTokenField		*tagsTokenField;
	
	IBOutlet NSArrayController	*albumController;
	
	NSOperationQueue			*operationQueue;
	NSMutableArray				*uploadOperations;
	
	NSString					*exportBasePath;
	NSMutableArray				*exportedImagePaths;
	
	BOOL						exportCanceled;
	
	NSMutableDictionary			*session;
	NSArray						*albums;
}

@property (nonatomic, readonly) NSMutableDictionary *session;
@property (nonatomic, readonly) NSArray *albums;

- (IBAction)loginButtonPressed:(id)sender;

- (id)initWithNibName:(NSString *)nibName;

- (void)finishExport;
- (void)cancelExport;

- (void)exportManagerDidFinishExport;
- (void)exportManagerShouldCancelExport;

- (void)willBeActivated;
- (void)willBeDeactivated;

- (BOOL)wantsDestinationPathPrompt;
- (NSString *)destinationPath;
- (NSString *)defaultDirectory;

- (NSView *)settingsView;
- (NSView *)firstView;
- (NSView *)lastView;

@end

@interface AbstractExportPlugin(Protected)

- (void)authenticateAndRetrieveAlbums;

- (void)finishExportIfCompletedOrCanceled;
- (void)deleteTemporaryFiles;

@end
