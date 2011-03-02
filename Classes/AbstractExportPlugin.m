//
//  AbstractExportPlugin.m
//  SAPOFotosApertureExportPlugin
//
//  Created by Pedro Gomes on 2/22/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "AbstractExportPlugin.h"
#import "SAPOPhotosAPI.h"
#import "PhotoUploadOperation.h"
#import "AlbumGetListByUserResult.h"
#import "ProgressSheetController.h"
#import "CreateAlbumSheetController.h"

@implementation AbstractExportPlugin

@synthesize session;
@synthesize albums;

#pragma mark -
#pragma mark Dealloc and Initialization

- (void)dealloc
{
	[operationQueue cancelAllOperations];
	[uploadOperations makeObjectsPerformSelector:@selector(setDelegate:) withObject:nil];
	
	[progressController release];
	[createAlbumController release];
	
	[session release];
	[albums release];
	[operationQueue release];
	[uploadOperations release];
	[failedOperations release];
	[exportBasePath release];
	[exportedImagePaths release];
	
	// Release the top-level objects from the nib.
	[_topLevelNibObjects makeObjectsPerformSelector:@selector(release)];
	[_topLevelNibObjects release];
	[_nibName release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark UI Methods

- (id)initWithNibName:(NSString *)nibName
{
	if((self = [super init])) {
		_nibName = [nibName copy];
	
		session = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
				   [NSNumber numberWithBool:NO], kSession_IsAuthenticatedKey, 
				   [NSNumber numberWithBool:NO], kSession_IsAuthenticatingKey, 
				   [NSNumber numberWithDouble:0], kSession_CurrentProgressKey,
				   [NSNumber numberWithInt:0], kSession_CurrentImageKey,
				   [NSNumber numberWithInt:0], kSession_TotalImagesKey,
				   nil];
		
		operationQueue = [[NSOperationQueue alloc] init];
		[operationQueue setMaxConcurrentOperationCount:5]; // TODO: define a constant 
	}
	return self;
}

- (NSView *)settingsView
{
	return settingsView;
	if(nil == settingsView) {
		// Load the nib using NSNib, and retain the array of top-level objects so we can release
		// them properly in dealloc
		NSBundle *mainBundle = [NSBundle bundleForClass:[self class]];
		NSNib *mainNib = [[NSNib alloc] initWithNibNamed:_nibName bundle:mainBundle];
		if ([mainNib instantiateNibWithOwner:self topLevelObjects:&_topLevelNibObjects]) {
			[_topLevelNibObjects retain];
		}
		[mainNib release];
	}
	
	return settingsView;
}

- (NSView *)firstView
{
	return firstView;
}

- (NSView *)lastView
{
	return lastView;
}

- (void)willBeActivated
{
	TRACE(@"");
}

- (void)willBeDeactivated
{
	TRACE(@"");	
}

#pragma mark -
#pragma mark Save/Path Methods

- (BOOL)wantsDestinationPathPrompt
{
	return NO;
}

- (NSString *)destinationPath
{
	return nil;
}

- (NSString *)defaultDirectory
{
	return nil;
}

#pragma mark -
#pragma mark Export Process Methods

- (NSUInteger)numberOfImages
{
	return 0;
}

- (void)exportManagerShouldBeginExport
{
	if(![[session objectForKey:kSession_IsAuthenticatedKey] boolValue]) {
		// authenticate first
		return;
	}
	
	if(!uploadOperations) {
		uploadOperations = [[NSMutableArray alloc] initWithCapacity:1];
	}
	if(!exportedImagePaths) {
		exportedImagePaths = [[NSMutableArray alloc] initWithCapacity:1];
	}

	[session setObject:[NSNumber numberWithDouble:0] forKey:kSession_CurrentProgressKey];
	
	progressController = [[ProgressSheetController alloc] initWithWindowNibName:@"ProgressSheet"];
	progressController.delegate = self;
	progressController.maxProgress = 100.0;
	progressController.numberOfImages = [self numberOfImages];
	[NSApp beginSheet:progressController.window modalForWindow:[settingsView window] modalDelegate:self didEndSelector:@selector(progressSheetDidEnd:returnCode:contextInfo:) contextInfo:NULL];
}

- (void)progressSheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	[sheet orderOut:self];
	SKSafeRelease(progressController);
}

- (void)exportManagerWillBeginExportToPath:(NSString *)path
{
	if(!exportBasePath) {
		exportBasePath = [path copy];
		TRACE(@"Export base path has been set to <%@>", exportBasePath);
	}
	else if(![path isEqualToString:exportBasePath]){
		WARN(@"EXPORT PATH HAS CHANGED. THE PLUGIN IS NOT WORKING AS ASSUMED, FIX AND SUPPORT THIS BEHAVIOR");
	}
}

- (BOOL)exportManagerShouldExportImageAtIndex:(unsigned)index
{
	return YES;
}

- (void)exportManagerWillExportImageAtIndex:(unsigned)index
{
	
}

- (BOOL)exportManagerShouldWriteImageData:(NSData *)imageData toRelativePath:(NSString *)path forImageAtIndex:(unsigned)index
{
	return YES;	
}

- (void)exportImageWithPath:(NSString *)imagePath
{
	NSDictionary *selectedAlbum = [[albumController arrangedObjects] objectAtIndex:[albumController selectionIndex]];
	NSString *tags = [[tagsTokenField stringValue] copy];
	
//	NSDictionary *imageProperties = [_exportManager propertiesWithoutThumbnailForImageAtIndex:index];
	NSDictionary *imageProperties = nil;
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  [usernameTextField stringValue], @"username",
							  [passwordTextField stringValue], @"password",
							  [selectedAlbum albumID], @"albumID",
							  tags, @"tags",
							  nil];
	PhotoUploadOperation *uploadOperation = [[PhotoUploadOperation alloc] initWithImagePath:imagePath imageProperties:imageProperties userInfo:userInfo];
	[uploadOperation setDelegate:self];
	[uploadOperations addObject:uploadOperation];
	[operationQueue addOperation:uploadOperation];
	
	[uploadOperation release];
	[tags release];
}

- (void)exportManagerDidFinishExport
{
	TRACE(@"***** exportManagerDidFinishExport *****");
	
	// You must call [_exportManager shouldFinishExport] before Aperture will put away the progress window and complete the export.
	// NOTE: You should assume that your plug-in will be deallocated immediately following this call. Be sure you have cleaned up
	// any callbacks or running threads before calling.
	[self finishExportIfCompletedOrCanceled];
	// else wait for all operations to finish
}

- (void)exportManagerShouldCancelExport
{
	TRACE(@"***** exportManagerShouldCancelExport *****");
	exportCanceled = YES;
	[operationQueue cancelAllOperations];
	[self finishExportIfCompletedOrCanceled];
	
	// You must call [_exportManager shouldCancelExport] here or elsewhere before Aperture will cancel the export process
	// NOTE: You should assume that your plug-in will be deallocated immediately following this call. Be sure you have cleaned up
	// any callbacks or running threads before calling.
}

#pragma mark -
#pragma mark Progress Methods

#pragma mark -
#pragma mark Actions

- (void)loginButtonPressed:(id)sender
{
	[self authenticateAndRetrieveAlbums];
}

- (IBAction)createAlbumButtonPressed:(id)sender
{
	TRACE(@"");
	createAlbumController = [[CreateAlbumSheetController alloc] initWithWindowNibName:@"CreateAlbumSheet"];
	createAlbumController.delegate = self;
	[NSApp beginSheet:createAlbumController.window modalForWindow:[settingsView window] modalDelegate:self didEndSelector:@selector(createAlbumSheetDidEnd:returnCode:contextInfo:) contextInfo:NULL];	
}

- (void)createAlbumSheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	[sheet orderOut:self];
	SKSafeRelease(createAlbumController);
}

#pragma mark -
#pragma mark PhotoUploadOperationDelegate

- (void)photoUploadOperationDidStart:(PhotoUploadOperation *)operation
{
	TRACE(@"Upload operation for photo <%@> started...", operation);
}

- (void)photoUploadOperationDidFinish:(PhotoUploadOperation *)operation
{
	TRACE(@"Upload operation for photo <%@> finished successfully", operation);
	[uploadOperations removeObject:operation];
	
	double progress = ((double)([self numberOfImages] - [uploadOperations count]) / (double)[self numberOfImages]) * 100.0;
	[session setObject:[NSNumber numberWithDouble:progress] forKey:kSession_CurrentProgressKey];
//	TRACE(@"Current progress %f", progress);
	
//	progressController.progress = progress;
	
	[self finishExportIfCompletedOrCanceled];
}

- (void)photoUploadOperation:(PhotoUploadOperation *)operation didFailWithError:(NSError *)error
{
	TRACE(@"Upload operation for photo <%@> failed with error <%@>", error, [error userInfo]);

	if(!failedOperations) {
		failedOperations = [[NSMutableArray alloc] initWithCapacity:1];
	}
	[failedOperations addObject:operation];
	[uploadOperations removeObject:operation];
	
	[self updateProgress];
	[self finishExportIfCompletedOrCanceled];	
}

- (void)photoUploadOperation:(PhotoUploadOperation *)operation didReportProgress:(NSNumber *)progress
{
	[self updateProgress];
}

- (void)updateProgress
{
	// Get the accumulated progress of all running operations
	double totalProgress = [[uploadOperations valueForKeyPath:@"@sum.progress"] doubleValue] / (double)[self numberOfImages];
	// Since the upload operations are removed when finished, we also need to add the remainder (100% of each finished operation)
	totalProgress += (([self numberOfImages] - [uploadOperations count]) * 100.0) / (double)[self numberOfImages];
	progressController.progress = totalProgress;
}

#pragma mark -
#pragma mark CreateAlbumControllerDelegate

- (BOOL)createAlbumController:(CreateAlbumSheetController *)controller requestedAlbumCreation:(NSDictionary *)album
{
	NSString *username = [[usernameTextField stringValue] copy];
	NSString *password = [[passwordTextField stringValue] copy];
	
	NSBlockOperation *operation = [[NSBlockOperation alloc] init];
	[operation addExecutionBlock:^{
		SAPOPhotosAPI *client = [[SAPOPhotosAPI alloc] init];
		[client setUsername:username password:password];
		
		NSDictionary *createAlbumParams = [NSDictionary dictionaryWithObjectsAndKeys:
										   [album objectForKey:@"albumName"], @"title",
										   [album objectForKey:@"albumDescription"], @"description",
										   nil];
		NSDictionary *result = [client albumCreateWithAlbum:createAlbumParams];
		if([[result objectForKey:@"ok"] isEqualToString:@"true"]) {
			TRACE(@"Album creation succeeded!");
			dispatch_sync(dispatch_get_main_queue(), ^{
				[NSApp endSheet:controller.window];
				[self authenticateAndRetrieveAlbums];
			});
		}
		else {
			TRACE(@"Album creation failed!");
			dispatch_sync(dispatch_get_main_queue(), ^{
				[NSApp endSheet:controller.window];
				NSAlert *alert = [NSAlert alertWithMessageText:@"" 
												 defaultButton:@"OK" 
											   alternateButton:nil 
												   otherButton:nil 
									 informativeTextWithFormat:@"We were unable to create the album at this time.\nPlease try again later."];
				[alert beginSheetModalForWindow:settingsView.window modalDelegate:self didEndSelector:@selector(createAlbumFailedAlertSheetDidEnd:returnCode:contextInfo:) contextInfo:NULL];
			});
		}
		[client release];
	}];
	[operationQueue addOperation:operation];
	
	[operation release];
	[username release];
	[password release];
	
	return YES;
}

- (void)createAlbumFailedAlertSheetDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	[[alert window] orderOut:self];
}

#pragma mark -
#pragma mark ProgressSheetControllerDelegate

- (void)progressSheetControllerCanceled:(ProgressSheetController *)controller
{
	[operationQueue cancelAllOperations];
}

#pragma mark -
#pragma mark Protected Methods

- (void)authenticateAndRetrieveAlbums
{
	NSString *username = [[usernameTextField stringValue] copy];
	NSString *password = [[passwordTextField stringValue] copy];
	
	//	if(![[NSUserDefaults standardUserDefaults] boolForKey:UserDefaults_DisableKeychainUsage]) {
	//		EMGenericKeychainItem *keychainItem = [EMGenericKeychainItem genericKeychainItemForService:Keychain_ServiceName withUsername:username];
	//		if(!keychainItem) {
	//			keychainItem = [EMGenericKeychainItem addGenericKeychainItemForService:Keychain_ServiceName withUsername:username password:password];
	//			if(!keychainItem) {
	//				ERROR(@"Unable to store the credentials in the Keychain");
	//			}
	//		}
	//		else if(![password isEqualToString:keychainItem.password]) {
	//			keychainItem.password = password;
	//		}
	//	}
	
	
	[self willChangeValueForKey:@"albums"];
	[albums release], albums = nil;
	[self didChangeValueForKey:@"albums"];
	
	TRACE(@"**** TESTING USER CREDENTIALS... *****");
	NSBlockOperation *operation = [[NSBlockOperation alloc] init];
	[operation addExecutionBlock:^{
		[session setObject:[NSNumber numberWithBool:YES] forKey:kSession_IsAuthenticatingKey];
		
		SAPOPhotosAPI *client = [[SAPOPhotosAPI alloc] init];
		[client setUsername:username password:password];
		AlbumGetListByUserResult *result = [client albumGetListByUserWithUser:nil page:0 orderBy:nil interface:nil];
		
		TRACE(@"Auth result: %@", result);
		
		BOOL authSuccess = ([result.albums count] > 0);
		if(authSuccess) {
			for(NSDictionary *album in result.albums) {
				TRACE(@"Album info <ID: %@; NAME: %@>", [album albumID], [album albumName]);
			}
			
			[self willChangeValueForKey:@"albums"];
			albums = [[NSArray arrayWithArray:result.albums] retain];
			[self didChangeValueForKey:@"albums"];
		}
		
		[session setObject:[NSNumber numberWithBool:authSuccess] forKey:kSession_IsAuthenticatedKey];
		[session setObject:[NSNumber numberWithBool:NO] forKey:kSession_IsAuthenticatingKey];
		
		[client release];
	}];
	[operationQueue addOperation:operation];
	
	[operation release];
	[username release];
	[password release];
}

#define YES_BUTTON_INDEX 0
- (void)finishExportIfCompletedOrCanceled
{
	TRACE(@"***** ATTEMPTING TO FINISH OR CANCEL EXPORT...");
	if([uploadOperations count] > 0) {
		TRACE(@"***** THERE ARE PENDING OPERATIONS. WAITING FOR THEM TO FINISH...");
		return;
	}
	[NSApp endSheet:progressController.window];
	
	if([failedOperations count] > 0 && !exportCanceled) {
		TRACE(@"***** FOUND FAILED OPERATIONS. PROMPTING USER FOR ACTION...");
		NSAlert *alert = [NSAlert alertWithMessageText:@"Warning" 
										 defaultButton:@"No" 
									   alternateButton:@"Yes" 
										   otherButton:nil 
							 informativeTextWithFormat:@"Some of the images could not be exported.\nWould you like to retry now?"];
		[alert beginSheetModalForWindow:settingsView.window modalDelegate:self didEndSelector:@selector(retryAlertSheetDidEnd:returnCode:contextInfo:) contextInfo:NULL];
		return;
	}
	
	[self deleteTemporaryFiles];
	if(exportCanceled) {
		TRACE(@"***** CANCELING EXPORT...");
		//[self cancelExport];
	}
	else {
		TRACE(@"***** FISNISHING EXPORT...");
		[self finishExport];
	}
}

- (void)retryAlertSheetDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	[[alert window] orderOut:self];
	if(YES_BUTTON_INDEX == returnCode) {
		[self retryExport];
	}
	else {
		[failedOperations removeAllObjects];
		[self finishExportIfCompletedOrCanceled];
	}
}

- (void)cancelExport
{
	TRACE(@"***** SUBCLASSES MUST IMPLEMENT THIS METHOD *****");
}

- (void)finishExport
{
	TRACE(@"***** SUBCLASSES MUST IMPLEMENT THIS METHOD *****");
}

- (void)retryExport
{
	TRACE(@"***** RETRYING EXPORT FOR <%d> FAILED OPERATIONS...", [failedOperations count]);
	
	[self exportManagerShouldBeginExport];
	NSArray *imagePaths = [failedOperations valueForKey:@"imagePath"];
	[failedOperations removeAllObjects];
	for(NSString *imagePath in imagePaths) {
		[self exportImageWithPath:imagePath];
	}
}

- (void)deleteTemporaryFiles
{
	TRACE(@"***** REMOVING TEMPORARY FILES... *****");
	NSFileManager *fileManager = [NSFileManager defaultManager];
	for(NSString *imagePath in exportedImagePaths) {
		if(![fileManager removeItemAtPath:[exportBasePath stringByAppendingPathComponent:imagePath] error:nil]) {
			ERROR(@"Error while trying to remove temporary file <%@>", [exportBasePath stringByAppendingPathComponent:imagePath]);
		}
	}
}

@end
