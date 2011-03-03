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

//@synthesize session;
//@synthesize albums;

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
	[_progressLock release];
	[_exportManager release];
	
	[super dealloc];
}

 - (id)initWithAPIManager:(id<PROAPIAccessing>)apiManager
{
	if ((self = [super initWithNibName:@"ApertureExportView"])) {
		_apiManager	= apiManager;
		_exportManager = [[_apiManager apiForProtocol:@protocol(ApertureExportManager)] retain];
		if (!_exportManager)
			return nil;
		
		_progressLock = [[NSLock alloc] init];
	}
	
	return self;
}

#pragma mark -
#pragma mark UI Methods

- (void)willBeActivated
{
	
}

- (void)willBeDeactivated
{
	
}

- (NSUInteger)numberOfImages
{
	return [_exportManager imageCount];
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
	[super exportManagerShouldBeginExport];
	
	if(!exportedImagePaths) {
		exportedImagePaths = [[NSMutableArray alloc] initWithCapacity:1];
	}
	
	exportProgress = (ApertureExportProgress){
		.currentValue = 0.0,
		.totalValue = MAX_PROGRESS_VALUE,
		.message = NSLocalizedString(@"Uploading photos...", @""),
		.indeterminateProgress = NO,
	};
	
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
	NSString *imagePath = [[@"~/Pictures/Aperture Exports" stringByExpandingTildeInPath] stringByAppendingPathComponent:relativePath];
	TRACE(@"relativePath <%@> forIndex: %d", imagePath, index);
	[super exportImageWithPath:imagePath];
	[exportedImagePaths addObject:imagePath];
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
	TRACE(@"***** APERTURE IS QUERYING THE PLUGIN FOR PROGRESS. CURRENT VALUE: <%f>", exportProgress.currentValue);
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

- (void)photoUploadOperationDidFinish:(PhotoUploadOperation *)operation
{
	[super photoUploadOperationDidFinish:operation];
	
	[self lockProgress];
	exportProgress.currentValue = totalProgress;
	[self unlockProgress];
}

- (void)photoUploadOperation:(PhotoUploadOperation *)operation didFailWithError:(NSError *)error
{
	[self photoUploadOperation:operation didFailWithError:error];
	
	[self lockProgress];
	exportProgress.currentValue = totalProgress;
	[self unlockProgress];
}

- (void)photoUploadOperation:(PhotoUploadOperation *)operation didReportProgress:(NSNumber *)progress
{
//	TRACE(@"Upload operation for photo <%@> reported progress: [%@]", operation, progress);

	[super photoUploadOperation:operation didReportProgress:progress];
	[self lockProgress];
	
	exportProgress.currentValue = totalProgress;
	
	[self unlockProgress];
}

#pragma mark -
#pragma mark Private Methods

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

@end
