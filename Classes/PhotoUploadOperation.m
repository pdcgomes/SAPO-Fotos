//
//  PhotoUploadOperation.m
//  SAPOFotosApertureExportPlugin
//
//  Created by Pedro Gomes on 2/15/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#define UPLOAD_URL	@"http://fotos.sapo.pt/uploadPost.html"

#import "PhotoUploadOperation.h"
#import "SAPOPhotosAPI.h"
#import "NSDictionary+Additions.h"

@interface PhotoUploadOperation()

- (BOOL)loadImage;
- (BOOL)requestUploadToken;
- (void)uploadImage;

- (void)reportError:(NSError *)theError;
- (void)reportProgress:(NSNumber *)theProgress;
- (BOOL)checkImageFileExists;

@property (nonatomic, assign) BOOL isCancelled;
@property (nonatomic, assign) BOOL isExecuting;
@property (nonatomic, assign) BOOL isFinished;
@property (nonatomic, assign) float progress;

@end

@implementation PhotoUploadOperation

@synthesize delegate;
@synthesize isCancelled = cancelled;
@synthesize isExecuting = executing;
@synthesize isFinished = finished;
@synthesize progress;
@synthesize imagePath;

#pragma mark -
#pragma mark Dealloc and Initialization

- (void)dealloc
{
	[connection_ cancel];

	SKSafeRelease(connection_);
	SKSafeRelease(request_);
	
	SKSafeRelease(token);
	SKSafeRelease(imagePath);
	SKSafeRelease(imageData);
	SKSafeRelease(imageProperties);
	SKSafeRelease(userInfo);
	
	[super dealloc];
}

- (id)initWithImagePath:(NSString *)theImagePath imageProperties:(NSDictionary *)properties userInfo:(NSDictionary *)theUserInfo
{
	if((self = [super init])) {
		imagePath		= [theImagePath copy];
		imageProperties = [properties retain];
		userInfo		= [theUserInfo retain];
	}
	return self;
}

#pragma mark -
#pragma mark NSOperation

- (void)cancel
{
	[connection_ cancel];
	
	self.isCancelled = YES;
}
- (void)start
{
	[self main];
}

- (void)main
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	self.isExecuting = YES;
	void (^finishOperationBlock)(BOOL) = ^(BOOL succeeded){
		self.isExecuting = NO;
		self.isFinished = YES;
		
		if(succeeded) {
			if([self.delegate respondsToSelector:@selector(photoUploadOperationDidFinish:)]) {
				[self.delegate performSelectorOnMainThread:@selector(photoUploadOperationDidFinish:) withObject:self waitUntilDone:NO];
			}
		}
		else {
			[self performSelectorOnMainThread:@selector(reportError:) withObject:nil waitUntilDone:YES];
		}

		[pool release];
	};
	
	// This part runs synchronously
	if(![self loadImage]) {
		finishOperationBlock(NO);
		return;
	}
	if(![self requestUploadToken]) {
		finishOperationBlock(NO);
		return;
	}
	[self uploadImage];
	
	NSRunLoop *runLoop = [[NSRunLoop currentRunLoop] retain];
	
	while(uploading && ![self isCancelled]) {
		[runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate date]];
	}
	
	[runLoop release];
	finishOperationBlock(YES);
}

- (BOOL)isConcurrent
{
	return YES;
}

#pragma mark -
#pragma mark Private Methods

- (BOOL)loadImage
{
	if(![self checkImageFileExists]) {
		return NO;
	}
	NSData *data = [NSData dataWithContentsOfFile:imagePath];
	if(!data) {
		ERROR(@"Unable to load image at the given path <%@>", imagePath);
		return NO;
	}
	
	imageData = [data retain];
	return YES;
}

- (BOOL)requestUploadToken
{
	NSAssert(imageData != nil && [imageData length] > 0, @"Image data is nil or zero-length.");
	
	TRACE(@"***** REQUESTING UPLOAD TOKEN FOR <%@>... *****", [imagePath lastPathComponent]);
	SAPOPhotosAPI *serviceClient = [[SAPOPhotosAPI alloc] init];
	
	NSString *username = [userInfo objectForKey:@"username"];
	NSString *password = [userInfo objectForKey:@"password"];
	[serviceClient setUsername:username password:password];

	NSMutableDictionary *image = [[NSMutableDictionary alloc] init];
	if([userInfo containsKey:@"albumID"]) {
		NSDictionary *album = [NSDictionary dictionaryWithObject:[userInfo objectForKey:@"albumID"] forKey:@"id"];
//		NSArray *albums = [NSArray arrayWithObject:[NSDictionary dictionaryWithObject:[userInfo objectForKey:@"albumID"] forKey:@"album"]];
		NSArray *albums = [NSArray arrayWithObject:[NSDictionary dictionaryWithObject:album forKey:@"album"]];
		[image setObject:albums forKey:@"albums"];
	}
	if([userInfo containsKey:@"tags"]) {
		[image setObject:[userInfo objectForKey:@"tags"] forKey:@"tags"];
	}
	if([userInfo containsKey:@"title"]) {
		[image setObject:[userInfo objectForKey:@"title"] forKey:@"title"];
	}
	else {
		[image setObject:@"Exported Image" forKey:@"title"];
	}
	
	BOOL success = NO;
	NSDictionary *serviceResponse = [serviceClient imageCreateWithImage:image interface:nil];
	if(nil == serviceResponse || ![serviceResponse containsKey:@"token"]) {
		ERROR(@"Invalid service response");
	}
	else {
		token = [[serviceResponse objectForKey:@"token"] copy];
		TRACE(@"***** SUCCESSFULLY OBTAINED UPLOAD TOKEN FOR <%@> :: %@(...)", [imagePath lastPathComponent], [token substringToIndex:10]);
		success = YES;
	}
	[image release];
	[serviceClient release];
	return success;
}

- (void)uploadImage
{
	NSAssert(token != nil, @"The upload token in unexpectedly nil!");
	NSAssert(imageData != nil && [imageData length] > 0, @"Image data is nil or zero-length.");
	
	// TODO: check that the image file actually exists at imagePath
	// Attempt to load the image from the file
	
	// TODO: generate a random string (mktemp maybe a good candidate)
	// or simply use kExportKeyUniqueID declared in ApertureSDKCommon.h to fetch a unique id from the exported image property dictionary
	// but ensure that said unique id can be used as a filename
	NSString *imageName	= [imagePath lastPathComponent];
	NSString *boundaryMarker = @"AaB03x";
	NSString *contentTypeHeader = [NSString stringWithFormat:@"multipart/form-data, boundary=%@", boundaryMarker];
	NSString *postString = [NSString stringWithFormat:
							@"--%1$@\r\n"
							@"content-disposition: form-data; name=\"token\"\r\n"
							@"Content-Type: text/plain;charset=UTF-8\r\n\r\n"
							@"%2$@\r\n"
							@"--%1$@\r\n"
							@"content-disposition: form-data; name=\"image\"; filename=\"%3$@\"\r\n"
							@"Content-Type: image/png\r\n\r\n",
							boundaryMarker, token, imageName];

	NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData:imageData];
	[postData appendData:[SKStringWithFormat(@"\r\n--%@--\r\n", boundaryMarker) dataUsingEncoding:NSASCIIStringEncoding]];
				
	request_ = [[NSMutableURLRequest requestWithURL:[NSURL URLWithString:UPLOAD_URL]] retain];
	
	[request_ setHTTPMethod:@"POST"];
	[request_ setHTTPBody:postData];
	[request_ setValue:contentTypeHeader forHTTPHeaderField:@"Content-Type"];

	[postData release];

	uploading = YES;
	
	TRACE(@"Delegate: %@", self.delegate);
	if([self.delegate respondsToSelector:@selector(photoUploadOperationDidStart:)]) {
		[self.delegate performSelectorOnMainThread:@selector(photoUploadOperationDidStart:) withObject:self waitUntilDone:NO];
	}
	
	TRACE(@"***** UPLOADING IMAGE <%@>...", [imagePath lastPathComponent]);
	connection_ = [[NSURLConnection alloc] initWithRequest:request_ delegate:self];
	[connection_ scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[connection_ start];
}

#pragma mark -
#pragma mark NSURLRequestDelegate

#define MAX_UPLOAD_RETRIES 3
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	ERROR(@"***** THERE WAS AN ERROR WHILE UPLOADING IMAGE <%@> *****", @"TODO");
	
	if(retries < MAX_UPLOAD_RETRIES) {
		retries++;
		[connection_ start];
		return;
	}
	
	if (connection == connection_) {
		[connection_ release];
		connection_ = nil;
	}
	[self reportError:error];
	
	uploading = NO;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	TRACE(@"***** FINISHED UPLOADING IMAGE <%@> *****", @"TODO");
	if (connection == connection_) {
		[connection_ release];
		connection_ = nil;
	
		uploading = NO;
	}
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
	if(totalBytesExpectedToWrite > 0) {
		self.progress = ((float)totalBytesWritten/(float)totalBytesExpectedToWrite) * 100.0f;
//		TRACE(@"Current upload progress for image <%@>: %f%", [imagePath lastPathComponent], self.progress);
		[self performSelectorOnMainThread:@selector(reportProgress:) withObject:[NSNumber numberWithFloat:self.progress] waitUntilDone:NO];
	}
}

#pragma mark -
#pragma mark Helper Methods

- (void)reportProgress:(NSNumber *)theProgress
{
	SK_ASSERT_MAIN_THREAD;
	
	if([self.delegate respondsToSelector:@selector(photoUploadOperation:didReportProgress:)]) {
		[self.delegate performSelector:@selector(photoUploadOperation:didReportProgress:) withObject:self withObject:theProgress];
	}
}

- (void)reportError:(NSError *)theError
{
	SK_ASSERT_MAIN_THREAD;
	
	if([self.delegate respondsToSelector:@selector(photoUploadOperation:didFailWithError:)]) {
		[self.delegate performSelector:@selector(photoUploadOperation:didFailWithError:) withObject:self withObject:theError];
	}
}

- (BOOL)checkImageFileExists
{
	if(![[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
		ERROR(@"Image file couldn't be found at the given path <%@>", imagePath);
		return NO;
	}
	
	NSError *error = nil;
	NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:imagePath error:&error];
	if(!fileAttributes) {
		ERROR(@"NSFileManager was unable to read the attribures of file <%@> due to error <%@>", imagePath, error);
		return NO;
	}
	
	return [fileAttributes fileSize] > 0;
}


@end
