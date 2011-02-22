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

@implementation AbstractExportPlugin

@synthesize session;
@synthesize albums;

#pragma mark -
#pragma mark Dealloc and Initialization

- (void)dealloc
{
	[operationQueue cancelAllOperations];
	[uploadOperations makeObjectsPerformSelector:@selector(setDelegate:) withObject:nil];
	
	[session release];
	[albums release];
	[operationQueue release];
	[uploadOperations release];
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
	}
	return self;
}

- (NSView *)settingsView
{
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
	
}

- (void)willBeDeactivated
{
	
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
	
	// You must call [_exportManager shouldBeginExport] here or elsewhere before Aperture will begin the export process
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

- (void)exportManagerDidWriteImageDataToRelativePath:(NSString *)relativePath forImageAtIndex:(unsigned)index
{
	[exportedImagePaths addObject:relativePath];
	
	NSString *imagePath = [[@"~/Pictures/Aperture Exports" stringByExpandingTildeInPath] stringByAppendingPathComponent:relativePath];
	TRACE(@"relativePath <%@> forIndex: %d", imagePath, index);
	
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
#pragma mark PhotoUploadOperationDelegate

- (void)photoUploadOperationDidStart:(PhotoUploadOperation *)operation
{
	TRACE(@"Upload operation for photo <%@> started...", operation);
}

- (void)photoUploadOperationDidFinish:(PhotoUploadOperation *)operation
{
	TRACE(@"Upload operation for photo <%@> finished successfully", operation);
	[uploadOperations removeObject:operation];
	[self finishExportIfCompletedOrCanceled];
}

- (void)photoUploadOperation:(PhotoUploadOperation *)operation didFailWithError:(NSError *)error
{
	TRACE(@"Upload operation for photo <%@> failed with error <%@>", error);
	[uploadOperations removeObject:operation];
	[self finishExportIfCompletedOrCanceled];	
}

- (void)photoUploadOperation:(PhotoUploadOperation *)operation didReportProgress:(NSNumber *)progress
{
	TRACE(@"Upload operation for photo <%@> reported progress: [%@]", operation, progress);
	
//	[self lockProgress];
//	
//	exportProgress.currentValue = [progress longValue];
//	
//	[self unlockProgress];
}

#pragma mark -
#pragma mark Actions

- (void)loginButtonPressed:(id)sender
{
	[self authenticateAndRetrieveAlbums];
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

- (void)finishExportIfCompletedOrCanceled
{
	TRACE(@"***** ATTEMPTING TO FINISH OR CANCEL EXPORT...");
	if([uploadOperations count] > 0) {
		TRACE(@"***** THERE ARE PENDING OPERATIONS. WAITING FOR THEM TO FINISH...");
		return;
	}
	
	[self deleteTemporaryFiles];
	if(exportCanceled) {
		TRACE(@"***** CANCELING EXPORT...");
		[self cancelExport];
	}
	else {
		TRACE(@"***** FISNISHING EXPORT...");
		[self finishExport];
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
