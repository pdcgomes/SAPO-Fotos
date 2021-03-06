//
//  PhotoUploadOperationTests
//  SAPOFotosApertureExportPlugin
//
//  Created by Pedro Gomes on 2/18/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import <GHUnit/GHUnit.h>
#import "SAPOPhotosAPI.h"
#import "PhotoUploadOperation.h"
#import "AlbumGetListByUserResult.h"
#import "SAPOConnectController.h"

#define LOG_WEBSERVICE_REQUESTS 1

@interface PhotoUploadOperationTest : GHAsyncTestCase 
{
	NSOperationQueue		*operationQueue;
	GTMOAuthAuthentication	*auth_;
}

@end

@implementation PhotoUploadOperationTest

#pragma mark -
#pragma mark GHUnit

- (BOOL)shouldRunOnMainThread 
{
	return YES;
}

- (void)setUpClass 
{
	operationQueue = [[NSOperationQueue alloc] init];
	[operationQueue setMaxConcurrentOperationCount:5];
}

- (void)tearDownClass 
{
	[operationQueue cancelAllOperations];
	[operationQueue release];
	operationQueue = nil;
	
	[auth_ release];
	auth_ = nil;
}

- (void)setUp 
{
	// Run before each test method
}

- (void)tearDown 
{
	// Run after each test method
}  

#pragma mark -
#pragma mark Tests

//- (void)test_01_ListUserAlbums
//{
////	NSArray *albums = nil;
//	
//	SAPOPhotosAPI *client = [[SAPOPhotosAPI alloc] init];
//	[client setUsername:@"pdcgomes@sapo.pt" password:@"xt2851cq"];
//	AlbumGetListByUserResult *result = [client albumGetListByUserWithUser:nil page:0 orderBy:nil interface:nil];
//	
//	for(NSDictionary *album in result.albums) {
//		TRACE(@"Album info <ID: %@; NAME: %@>", [album albumID], [album albumName]);
//	}
//	TRACE(@"ServiceResponse: %@", result);
//	
//	GHAssertTrue(result != nil, @"Invalid service response");
//	GHAssertTrue([result.albums count] > 0, @"No albums found. Expecting at least one album.");
//}
//
//- (void)test_02_CreateUserAlbum
//{
//	SAPOPhotosAPI *client = [[SAPOPhotosAPI alloc] init];
//	[client setUsername:@"pdcgomes@sapo.pt" password:@"xt2851cq"];
//	
//	NSDictionary *album = [[NSDictionary alloc] initWithObjectsAndKeys:
//						   @"CreateUserAlbumTest", @"title",
//						   @"CreateUserAlbumTest", @"description",
//						   nil];
//	
//	NSDictionary *result = [client albumCreateWithAlbum:album];
//	TRACE(@"ServiceResponse: %@", result);
//
//	[album release];
//}
//
//- (void)test_03_DeleteUserAlbum
//{
//	
//}

//- (void)test_04_PhotoUploadOperation
//{
//	[self prepare];
//	
//	NSString *imagePath = @"/Users/pdcgomes/Downloads/Screenshot.png";
//	NSDictionary *imageProperties = nil;
//	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
//							  @"pdcgomes@sapo.pt", @"username",
//							  @"xt2851cq", @"password",
//							  nil];
//	PhotoUploadOperation *operation = [[PhotoUploadOperation alloc] initWithImagePath:imagePath imageProperties:imageProperties userInfo:userInfo];
//	[operation setDelegate:self];
//	[operationQueue addOperation:operation];
//	[operation release];
//	
//	[self waitForStatus:kGHUnitWaitStatusSuccess timeout:20.0];
//}

//- (void)test_05_PhotoUploadOperationWithAlbum
//{
//	[self prepare];
//	
//	NSString *imagePath = @"/Users/pdcgomes/Downloads/Screenshot.png";
//	NSDictionary *imageProperties = nil;
//	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
//							  @"pdcgomes@sapo.pt", @"username",
//							  @"xt2851cq", @"password",
//							  @"1", @"albumID",
//							  nil];
//	PhotoUploadOperation *operation = [[PhotoUploadOperation alloc] initWithImagePath:imagePath imageProperties:imageProperties userInfo:userInfo];
//	[operation setDelegate:self];
//	[operationQueue addOperation:operation];
//	[operation release];
//	
//	[self waitForStatus:kGHUnitWaitStatusSuccess timeout:20.0];
//}

- (void)test_06_SAPOConnectAuth
{
	[self prepare];
	
	SAPOConnectController *sapoConnect = [[SAPOConnectController alloc] init];
	[sapoConnect setDelegate:self];
	[sapoConnect authorize];
	
	[self waitForStatus:kGHUnitWaitStatusSuccess timeout:20.0];
}

#pragma mark -
#pragma mark PhotoUploadOperationDelegate

- (void)photoUploadOperationDidStart:(PhotoUploadOperation *)operation
{
	
}

- (void)photoUploadOperationDidFinish:(PhotoUploadOperation *)operation
{
	[self notify:kGHUnitWaitStatusSuccess];
}

- (void)photoUploadOperation:(PhotoUploadOperation *)operation didFailWithError:(NSError *)error
{
	[self notify:kGHUnitWaitStatusFailure];	
}

- (void)photoUploadOperation:(PhotoUploadOperation *)operation didReportProgress:(NSNumber *)progress
{

}

#pragma mark -
#pragma mark SAPOConnectControllerDelegate

#pragma mark -
#pragma mark SAPOConnectControllerDelegate

- (void)authController:(SAPOConnectController *)controller didFinishWithAuth:(GTMOAuthAuthentication *)auth
{
	TRACE(@"Auth success!");
	if(auth_ != nil) {
		[auth_ release];
		auth_ = nil;
	}
	auth_ = [auth retain];
	[self notify:kGHUnitWaitStatusSuccess];
}

- (void)authController:(SAPOConnectController *)controller didFailWithError:(NSError *)error
{
	TRACE(@"Auth failure!");
	[self notify:kGHUnitWaitStatusFailure];
}

@end
