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
#define kSession_CurrentProgressKey		@"progress"
#define kSession_CurrentImageKey		@"currentImage"
#define kSession_TotalImagesKey			@"totalImages"

#define MAX_PROGRESS_VALUE 100.0

@class ProgressSheetController;
@class CreateAlbumSheetController;

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

	ProgressSheetController		*progressController;
	CreateAlbumSheetController	*createAlbumController;
	
	NSOperationQueue			*operationQueue;
	NSMutableArray				*uploadOperations;
	NSMutableArray				*failedOperations;
	
	NSString					*exportBasePath;
	NSMutableArray				*exportedImagePaths;
	
	BOOL						exportCanceled;
	double						totalProgress;
	
	NSMutableDictionary			*session;
	NSArray						*albums;
}

@property (nonatomic, readonly) NSMutableDictionary *session;
@property (nonatomic, readonly) NSArray *albums;

- (IBAction)loginButtonPressed:(id)sender;
- (IBAction)createAlbumButtonPressed:(id)sender;

- (id)initWithNibName:(NSString *)nibName;

- (NSUInteger)numberOfImages;

- (void)finishExport;
- (void)cancelExport;
- (void)retryExport;
- (void)updateProgress;
- (void)presentProgressSheet;

- (void)exportManagerShouldBeginExport;
- (void)exportImageWithPath:(NSString *)imagePath;
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
