//
//	SAPOFotosApertureExportPlugin.m
//	SAPOFotosApertureExportPlugin
//
//	Created by Pedro Gomes on 2/15/11.
//	Copyright SAPO 2011. All rights reserved.
//

#import "SAPOFotosApertureExportPlugin.h"
#import "SAPOPhotosAPI.h"
#import "PhotoUploadOperation.h"
#import "AlbumGetListByUserResult.h"

#define kSession_IsAuthenticatingKey	@"isPerformingAuthentication"
#define kSession_IsAuthenticatedKey		@"isAuthenticated"

@interface SAPOFotosApertureExportPlugin(Private)

- (void)authenticateAndRetrieveAlbums;

- (void)finishExportIfCompletedOrCanceled;
- (void)deleteTemporaryFiles;

@end

@implementation SAPOFotosApertureExportPlugin

@synthesize session;
@synthesize albums;

//---------------------------------------------------------
// initWithAPIManager:
//
// This method is called when a plug-in is first loaded, and
// is a good point to conduct any checks for anti-piracy or
// system compatibility. This is also your only chance to
// obtain a reference to Aperture's export manager. If you
// do not obtain a valid reference, you should return nil.
// Returning nil means that a plug-in chooses not to be accessible.
//---------------------------------------------------------

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
	
	[_progressLock release];
	[_exportManager release];
	
	[super dealloc];
}

 - (id)initWithAPIManager:(id<PROAPIAccessing>)apiManager
{
	if ((self = [super init])) {
		_apiManager	= apiManager;
		_exportManager = [[_apiManager apiForProtocol:@protocol(ApertureExportManager)] retain];
		if (!_exportManager)
			return nil;
		
		_progressLock = [[NSLock alloc] init];
		
		session = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
				   [NSNumber numberWithBool:NO], kSession_IsAuthenticatedKey, 
				   [NSNumber numberWithBool:NO], kSession_IsAuthenticatingKey, 
				   nil];
		
		if(!operationQueue) {
			operationQueue = [[NSOperationQueue alloc] init];
			[operationQueue setMaxConcurrentOperationCount:5]; // TODO: define a constant 
		}
	}
	
	return self;
}

#pragma mark -
#pragma mark UI Methods

- (NSView *)settingsView
{
	if (nil == settingsView) {
		// Load the nib using NSNib, and retain the array of top-level objects so we can release
		// them properly in dealloc
		NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
		NSNib *myNib = [[NSNib alloc] initWithNibNamed:@"ExportView" bundle:myBundle];
		if ([myNib instantiateNibWithOwner:self topLevelObjects:&_topLevelNibObjects]) {
			[_topLevelNibObjects retain];
		}
		[myNib release];
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

#pragma mark
#pragma mark Aperture UI Controls

- (BOOL)allowsOnlyPlugInPresets
{
	return NO;	
}

- (BOOL)allowsMasterExport
{
	return YES;	
}

- (BOOL)allowsVersionExport
{
	return YES;	
}

- (BOOL)wantsFileNamingControls
{
	return YES;	
}

- (void)exportManagerExportTypeDidChange
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
	
	[self lockProgress];
	exportProgress = (ApertureExportProgress){
		.currentValue = 0.0,
		.totalValue = 1.0,
		.message = nil,
		.indeterminateProgress = NO,
	};
	[self unlockProgress];
	
	// You must call [_exportManager shouldBeginExport] here or elsewhere before Aperture will begin the export process
	[_exportManager shouldBeginExport];
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
	
	NSDictionary *imageProperties = [_exportManager propertiesWithoutThumbnailForImageAtIndex:index];
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

- (ApertureExportProgress *)progress
{
	return &exportProgress;
}

- (void)lockProgress
{
	if (!_progressLock)
		_progressLock = [[NSLock alloc] init];
		
	[_progressLock lock];
}

- (void)unlockProgress
{
	[_progressLock unlock];
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
	[self finishExportIfCompletedOrCanceled];
}

//- (void)photoUploadOperation:(PhotoUploadOperation *)operation didFailWithError:(NSError *)error
//{
//	TRACE(@"Upload operation for photo <%@> failed with error <%@>", error);
//	[uploadOperations removeObject:operation];
//	[self finishExportIfCompletedOrCanceled];	
//}

- (void)photoUploadOperation:(PhotoUploadOperation *)operation didReportProgress:(NSNumber *)progress
{
	TRACE(@"Upload operation for photo <%@> reported progress: [%@]", operation, progress);
	
	[self lockProgress];
	
	exportProgress.currentValue = [progress longValue];
	
	[self unlockProgress];
}

#pragma mark -
#pragma mark Actions

- (void)loginButtonPressed:(id)sender
{
	[self authenticateAndRetrieveAlbums];
}

#pragma mark -
#pragma mark Private Methods

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
		[_exportManager shouldCancelExport];
	}
	else {
		TRACE(@"***** FISNISHING EXPORT...");
		[_exportManager shouldFinishExport];
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
