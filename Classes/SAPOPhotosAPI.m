// Photos.m 

#import <GTMOAuth/GTMOAuthAuthentication.h>

#import "SAPOPhotosAPI.h"
#import "XMLdocument.h"

#import "AlbumGetListByUserResult.h"

@implementation SAPOPhotosAPI

- (void)dealloc
{
	[super dealloc];
}

- (void)setUsername:(NSString *)username password:(NSString *)password
{
	NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
						  username, @"ESBUsername",
						  password, @"ESBPassword",
						  nil];
	
	NSString *header = @"ESBCredentials";
	[SOAPHeader setObject:dict forKey:header];
	[SOAPHeaderNamespaces setObject:@"http://services.sapo.pt/definitions" forKey:header];
	[dict release];
}


#pragma mark -
#pragma mark Public Methods

- (NSString *) dummyEchoWithString:(NSString *)echoString
{
	NSString *location = @"http://services.sapo.pt/Photos";
	
	NSMutableArray *paramArray = [NSMutableArray array];
	NSDictionary *dummyEcho = [echoString length] > 0 ? [NSDictionary dictionaryWithObject:echoString forKey:@"echoStr"] : nil;
	[paramArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"DummyEcho", @"name",dummyEcho?dummyEcho:nil, @"value", nil]];
	NSURLRequest *request = [self makeSOAPRequestWithLocation:location Parameters:paramArray Operation:@"DummyEcho" Namespace:@"http://services.sapo.pt/definitions/Photos" Action:@"http://services.sapo.pt/definitions/Photos/DummyEcho" SOAPVersion:SOAPVersion1_0];
	NSURLResponse *response;
	NSError *error;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	XMLdocument *xml = [XMLdocument documentWithData:data];
	return [self returnValueFromSOAPResponse:xml];
}

#pragma mark -

- (NSDictionary *) albumCreateWithAlbum:(NSDictionary *)album
{
	NSString *location = @"http://services.sapo.pt/Photos";
	NSMutableArray *paramArray = [NSMutableArray array];
	[paramArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"album", @"name",album?album:nil, @"value", nil]];
	NSURLRequest *request = [self makeSOAPRequestWithLocation:location Parameters:paramArray Operation:@"AlbumCreate" Namespace:@"http://services.sapo.pt/definitions/Photos" Action:@"http://services.sapo.pt/definitions/Photos/AlbumCreate" SOAPVersion:SOAPVersion1_0];
	NSURLResponse *response;
	NSError *error = nil;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	XMLdocument *xml = [XMLdocument documentWithData:data];
	
	XMLelement *body = [xml.documentRoot getNamedChild:@"Body"];
	XMLelement *soapResponse = [body.children lastObject];
	XMLelement *soapResult = [soapResponse.children lastObject];
	
	XMLelement *createResult = [[soapResult getNamedChild:@"result"] getNamedChild:@"ok"];
	if([createResult.text isEqualToString:@"false"]) {
		return nil;
	}
	
	XMLelement *createdAlbum = [soapResult getNamedChild:@"album"];
	NSAssert(createdAlbum != nil, @"Created album unepexectedly nil!");
	
	NSMutableDictionary *albumDict = [[NSMutableDictionary alloc] initWithCapacity:[createdAlbum.children count]];
	for(XMLelement *child in createdAlbum.children) {
		[albumDict setObject:child.text forKey:child.name];
	}
	return [NSDictionary dictionaryWithDictionary:[albumDict autorelease]];
//	return [self flattenSOAPResponse:xml.documentRoot withPath:@"Body/AlbumCreateResponse/AlbumCreateResult/result"];
}

- (AlbumGetListByUserResult *) albumGetListByUserWithUser:(NSDictionary *)user page:(NSInteger)page orderBy:(NSString *)orderBy interface:(NSString *)interface
{
	NSString *location = @"http://services.sapo.pt/Photos";
	
	NSMutableArray *paramArray = [NSMutableArray array];
	[paramArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"user", @"name",user?user:nil, @"value", nil]];
	[paramArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"page", @"name",[NSNumber numberWithInt:page], @"value", nil]];
	[paramArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"orderBy", @"name",orderBy?orderBy:@"", @"value", nil]];
	[paramArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"interface", @"name",interface?interface:@"", @"value", nil]];
	NSURLRequest *request = [self makeSOAPRequestWithLocation:location Parameters:paramArray Operation:@"AlbumGetListByUser" Namespace:@"http://services.sapo.pt/definitions/Photos" Action:@"http://services.sapo.pt/definitions/Photos/AlbumGetListByUser" SOAPVersion:SOAPVersion1_0];
	NSURLResponse *response;
	NSError *error = nil;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	XMLdocument *xml = [XMLdocument documentWithData:data];
	
	XMLelement *body = [xml.documentRoot getNamedChild:@"Body"];
	XMLelement *soapResponse = [body.children lastObject];  // there should be only one
	XMLelement *soapResult = [soapResponse.children lastObject];  // there should be only one
	
	NSArray *albums = [[soapResult getNamedChild:@"albums"] getNamedChildren:@"album"];
	XMLelement *total = [soapResult getNamedChild:@"result"];
	
	return [[[AlbumGetListByUserResult alloc] initWithAlbums:albums result:total] autorelease];
}

#pragma mark -

- (NSDictionary *) imageAddToAlbumWithImage:(NSDictionary *)image interface:(NSString *)interface
{
	NSString *location = @"http://services.sapo.pt/Photos";
	NSMutableArray *paramArray = [NSMutableArray array];
	[paramArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"image", @"name",image?image:nil, @"value", nil]];
	[paramArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"interface", @"name",interface?interface:@"", @"value", nil]];
	NSURLRequest *request = [self makeSOAPRequestWithLocation:location Parameters:paramArray Operation:@"ImageAddToAlbum" Namespace:@"http://services.sapo.pt/definitions/Photos" Action:@"http://services.sapo.pt/definitions/Photos/ImageAddToAlbum" SOAPVersion:SOAPVersion1_0];
	NSURLResponse *response;
	NSError *error;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	XMLdocument *xml = [XMLdocument documentWithData:data];
	
	return [self flattenSOAPResponse:xml.documentRoot withPath:@""];	
	//	return [self returnComplexTypeFromSOAPResponse:xml asClass:[ImageAddToAlbumResult class]];  // complex type 
}

- (NSDictionary *) imageCreateWithImage:(NSDictionary *)image interface:(NSString *)interface
{
	NSString *location = @"http://services.sapo.pt/Photos";
	NSMutableArray *paramArray = [NSMutableArray array];
	[paramArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"image", @"name",image?image:nil, @"value", nil]];
	[paramArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"interface", @"name",interface?interface:@"", @"value", nil]];
	NSURLRequest *request = [self makeSOAPRequestWithLocation:location Parameters:paramArray Operation:@"ImageCreate" Namespace:@"http://services.sapo.pt/definitions/Photos" Action:@"http://services.sapo.pt/definitions/Photos/ImageCreate" SOAPVersion:SOAPVersion1_0];
	NSURLResponse *response;
	NSError *error;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	XMLdocument *xml = [XMLdocument documentWithData:data];
	return [self flattenSOAPResponse:xml.documentRoot withPath:@"Body/ImageCreateResponse/ImageCreateResult"];	
	//	return [self returnComplexTypeFromSOAPResponse:xml asClass:[ImageCreateResult class]];  // complex type 
}

- (NSDictionary *) imageDetailsWithImage:(NSDictionary *)image
{
	NSString *location = @"http://services.sapo.pt/Photos";
	NSMutableArray *paramArray = [NSMutableArray array];
	[paramArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"image", @"name",image?image:nil, @"value", nil]];
	NSURLRequest *request = [self makeSOAPRequestWithLocation:location Parameters:paramArray Operation:@"ImageDetails" Namespace:@"http://services.sapo.pt/definitions/Photos" Action:@"http://services.sapo.pt/definitions/Photos/ImageDetails" SOAPVersion:SOAPVersion1_0];
	NSURLResponse *response;
	NSError *error;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	XMLdocument *xml = [XMLdocument documentWithData:data];
	return [self flattenSOAPResponse:xml.documentRoot withPath:@""];	
	//	return [self returnComplexTypeFromSOAPResponse:xml asClass:[ImageDetailsResult class]];  // complex type 
}

- (NSDictionary *) imageEditWithImage:(NSDictionary *)image
{
	NSString *location = @"http://services.sapo.pt/Photos";
	NSMutableArray *paramArray = [NSMutableArray array];
	[paramArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"image", @"name",image?image:nil, @"value", nil]];
	NSURLRequest *request = [self makeSOAPRequestWithLocation:location Parameters:paramArray Operation:@"ImageEdit" Namespace:@"http://services.sapo.pt/definitions/Photos" Action:@"http://services.sapo.pt/definitions/Photos/ImageEdit" SOAPVersion:SOAPVersion1_0];
	NSURLResponse *response;
	NSError *error;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	XMLdocument *xml = [XMLdocument documentWithData:data];
	return [self flattenSOAPResponse:xml.documentRoot withPath:@""];	
	//	return [self returnComplexTypeFromSOAPResponse:xml asClass:[ImageEditResult class]];  // complex type 
}

@end