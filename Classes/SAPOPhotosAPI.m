// Photos.m 

#import "SAPOPhotosAPI.h"
#import "XMLdocument.h"

@implementation SAPOPhotosAPI

- (NSDictionary *) albumCreateWithAlbum:(NSDictionary *)album
{
	NSString *location = @"http://services.sapo.pt/Photos";
	NSMutableArray *paramArray = [NSMutableArray array];
	[paramArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"album", @"name",album?album:nil, @"value", nil]];
	NSURLRequest *request = [self makeSOAPRequestWithLocation:location Parameters:paramArray Operation:@"AlbumCreate" Namespace:@"http://services.sapo.pt/definitions/Photos" Action:@"http://services.sapo.pt/definitions/Photos/AlbumCreate" SOAPVersion:SOAPVersion1_0];
	NSURLResponse *response;
	NSError *error;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	XMLdocument *xml = [XMLdocument documentWithData:data];
	return [self flattenSOAPResponse:xml.documentRoot withPath:@""];
	//	return [self returnComplexTypeFromSOAPResponse:xml asClass:[AlbumCreateResult class]];  // complex type 
}

- (NSDictionary *) albumGetListByUserWithUser:(NSDictionary *)user page:(NSInteger)page orderBy:(NSString *)orderBy interface:(NSString *)interface
{
	NSString *location = @"http://services.sapo.pt/Photos";
	NSMutableArray *paramArray = [NSMutableArray array];
	[paramArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"user", @"name",user?user:nil, @"value", nil]];
	[paramArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"page", @"name",[NSNumber numberWithInt:page], @"value", nil]];
	[paramArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"orderBy", @"name",orderBy?orderBy:@"", @"value", nil]];
	[paramArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"interface", @"name",interface?interface:@"", @"value", nil]];
	NSURLRequest *request = [self makeSOAPRequestWithLocation:location Parameters:paramArray Operation:@"AlbumGetListByUser" Namespace:@"http://services.sapo.pt/definitions/Photos" Action:@"http://services.sapo.pt/definitions/Photos/AlbumGetListByUser" SOAPVersion:SOAPVersion1_0];
	NSURLResponse *response;
	NSError *error;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	XMLdocument *xml = [XMLdocument documentWithData:data];
	return [self flattenSOAPResponse:xml.documentRoot withPath:@""];	
	//	return [self returnComplexTypeFromSOAPResponse:xml asClass:[AlbumGetListByUserResult class]];  // complex type 
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
	return [self flattenSOAPResponse:xml.documentRoot withPath:@""];	
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

#pragma mark -

- (NSDictionary *) imageGetByColorLikenessWithColor:(NSDictionary *)color interface:(NSString *)interface
{
	NSString *location = @"http://services.sapo.pt/Photos";
	NSMutableArray *paramArray = [NSMutableArray array];
	[paramArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"color", @"name",color?color:nil, @"value", nil]];
	[paramArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"interface", @"name",interface?interface:@"", @"value", nil]];
	NSURLRequest *request = [self makeSOAPRequestWithLocation:location Parameters:paramArray Operation:@"ImageGetByColorLikeness" Namespace:@"http://services.sapo.pt/definitions/Photos" Action:@"http://services.sapo.pt/definitions/Photos/ImageGetByColorLikeness" SOAPVersion:SOAPVersion1_0];
	NSURLResponse *response;
	NSError *error;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	XMLdocument *xml = [XMLdocument documentWithData:data];
	return [self flattenSOAPResponse:xml.documentRoot withPath:@""];	
	//	return [self returnComplexTypeFromSOAPResponse:xml asClass:[ImageGetByColorLikenessResult class]];  // complex type 
}

- (NSDictionary *) imageGetListBySearchWithPage:(NSInteger)page interface:(NSString *)interface terms:(NSArray *)terms dateFrom:(NSString *)dateFrom dateTo:(NSString *)dateTo
{
	NSString *location = @"http://services.sapo.pt/Photos";
	NSMutableArray *paramArray = [NSMutableArray array];
	[paramArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"page", @"name",[NSNumber numberWithInt:page], @"value", nil]];
	[paramArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"interface", @"name",interface?interface:@"", @"value", nil]];
	[paramArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"terms", @"name",terms?terms:nil, @"value", nil]];
	[paramArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"dateFrom", @"name",dateFrom?dateFrom:@"", @"value", nil]];
	[paramArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"dateTo", @"name",dateTo?dateTo:@"", @"value", nil]];
	NSURLRequest *request = [self makeSOAPRequestWithLocation:location Parameters:paramArray Operation:@"ImageGetListBySearch" Namespace:@"http://services.sapo.pt/definitions/Photos" Action:@"http://services.sapo.pt/definitions/Photos/ImageGetListBySearch" SOAPVersion:SOAPVersion1_0];
	NSURLResponse *response;
	NSError *error;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	XMLdocument *xml = [XMLdocument documentWithData:data];
	return [self flattenSOAPResponse:xml.documentRoot withPath:@""];
	//	return [self returnComplexTypeFromSOAPResponse:xml asClass:[ImageGetListBySearchResult class]];  // complex type 
}

- (NSDictionary *) imageGetListByTagsWithTags:(NSArray *)tags page:(NSInteger)page orderBy:(NSString *)orderBy m18:(BOOL)m18 user:(NSDictionary *)user interface:(NSString *)interface
{
	NSString *location = @"http://services.sapo.pt/Photos";
	NSMutableArray *paramArray = [NSMutableArray array];
	[paramArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"tags", @"name",tags?tags:nil, @"value", nil]];
	[paramArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"page", @"name",[NSNumber numberWithInt:page], @"value", nil]];
	[paramArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"orderBy", @"name",orderBy?orderBy:@"", @"value", nil]];
	[paramArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"m18", @"name",[NSNumber numberWithBool:m18], @"value", nil]];
	[paramArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"user", @"name",user?user:nil, @"value", nil]];
	[paramArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"interface", @"name",interface?interface:@"", @"value", nil]];
	NSURLRequest *request = [self makeSOAPRequestWithLocation:location Parameters:paramArray Operation:@"ImageGetListByTags" Namespace:@"http://services.sapo.pt/definitions/Photos" Action:@"http://services.sapo.pt/definitions/Photos/ImageGetListByTags" SOAPVersion:SOAPVersion1_0];
	NSURLResponse *response;
	NSError *error;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	XMLdocument *xml = [XMLdocument documentWithData:data];
	return [self flattenSOAPResponse:xml.documentRoot withPath:@""];
	//	return [self returnComplexTypeFromSOAPResponse:xml asClass:[ImageGetListByTagsResult class]];  // complex type 
}

- (NSDictionary *) imageGetListByUserWithPage:(NSInteger)page user:(NSDictionary *)user
{
	NSString *location = @"http://services.sapo.pt/Photos";
	NSMutableArray *paramArray = [NSMutableArray array];
	[paramArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"page", @"name",[NSNumber numberWithInt:page], @"value", nil]];
	[paramArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"user", @"name",user?user:nil, @"value", nil]];
	NSURLRequest *request = [self makeSOAPRequestWithLocation:location Parameters:paramArray Operation:@"ImageGetListByUser" Namespace:@"http://services.sapo.pt/definitions/Photos" Action:@"http://services.sapo.pt/definitions/Photos/ImageGetListByUser" SOAPVersion:SOAPVersion1_0];
	NSURLResponse *response;
	NSError *error;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	XMLdocument *xml = [XMLdocument documentWithData:data];
	return [self flattenSOAPResponse:xml.documentRoot withPath:@""];
	//	return [self returnComplexTypeFromSOAPResponse:xml asClass:[ImageGetListByUserResult class]];  // complex type 
}

- (NSDictionary *) imageGetListByUserAlbumWithUser:(NSDictionary *)user album:(NSDictionary *)album page:(NSInteger)page interface:(NSString *)interface orderBy:(NSString *)orderBy
{
	NSString *location = @"http://services.sapo.pt/Photos";
	NSMutableArray *paramArray = [NSMutableArray array];
	[paramArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"user", @"name",user?user:nil, @"value", nil]];
	[paramArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"album", @"name",album?album:nil, @"value", nil]];
	[paramArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"page", @"name",[NSNumber numberWithInt:page], @"value", nil]];
	[paramArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"interface", @"name",interface?interface:@"", @"value", nil]];
	[paramArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"orderBy", @"name",orderBy?orderBy:@"", @"value", nil]];
	NSURLRequest *request = [self makeSOAPRequestWithLocation:location Parameters:paramArray Operation:@"ImageGetListByUserAlbum" Namespace:@"http://services.sapo.pt/definitions/Photos" Action:@"http://services.sapo.pt/definitions/Photos/ImageGetListByUserAlbum" SOAPVersion:SOAPVersion1_0];
	NSURLResponse *response;
	NSError *error;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	XMLdocument *xml = [XMLdocument documentWithData:data];
	return [self flattenSOAPResponse:xml.documentRoot withPath:@""];
	//	return [self returnComplexTypeFromSOAPResponse:xml asClass:[ImageGetListByUserAlbumResult class]];  // complex type 
}

#pragma mark -

- (NSDictionary *) userCreateWithUser:(NSDictionary *)user
{
	NSString *location = @"http://services.sapo.pt/Photos";
	NSMutableArray *paramArray = [NSMutableArray array];
	[paramArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"user", @"name",user?user:nil, @"value", nil]];
	NSURLRequest *request = [self makeSOAPRequestWithLocation:location Parameters:paramArray Operation:@"UserCreate" Namespace:@"http://services.sapo.pt/definitions/Photos" Action:@"http://services.sapo.pt/definitions/Photos/UserCreate" SOAPVersion:SOAPVersion1_0];
	NSURLResponse *response;
	NSError *error;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	XMLdocument *xml = [XMLdocument documentWithData:data];
	return [self flattenSOAPResponse:xml.documentRoot withPath:@""];
	//	return [self returnComplexTypeFromSOAPResponse:xml asClass:[UserCreateResult class]];  // complex type 
}

- (NSDictionary *) userDetailsWithUser:(NSDictionary *)user interface:(NSDictionary *)interface
{
	NSString *location = @"http://services.sapo.pt/Photos";
	NSMutableArray *paramArray = [NSMutableArray array];
	[paramArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"user", @"name",user?user:nil, @"value", nil]];
	[paramArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"interface", @"name",interface?interface:nil, @"value", nil]];
	NSURLRequest *request = [self makeSOAPRequestWithLocation:location Parameters:paramArray Operation:@"UserDetails" Namespace:@"http://services.sapo.pt/definitions/Photos" Action:@"http://services.sapo.pt/definitions/Photos/UserDetails" SOAPVersion:SOAPVersion1_0];
	NSURLResponse *response;
	NSError *error;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	XMLdocument *xml = [XMLdocument documentWithData:data];
	return [self flattenSOAPResponse:xml.documentRoot withPath:@""];
	//	return [self returnComplexTypeFromSOAPResponse:xml asClass:[UserDetailsResult class]];  // complex type 
}

- (NSDictionary *) userGetTagsWithUser:(NSDictionary *)user interface:(NSString *)interface
{
	NSString *location = @"http://services.sapo.pt/Photos";
	NSMutableArray *paramArray = [NSMutableArray array];
	[paramArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"user", @"name",user?user:nil, @"value", nil]];
	[paramArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"interface", @"name",interface?interface:@"", @"value", nil]];
	NSURLRequest *request = [self makeSOAPRequestWithLocation:location Parameters:paramArray Operation:@"UserGetTags" Namespace:@"http://services.sapo.pt/definitions/Photos" Action:@"http://services.sapo.pt/definitions/Photos/UserGetTags" SOAPVersion:SOAPVersion1_0];
	NSURLResponse *response;
	NSError *error;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	XMLdocument *xml = [XMLdocument documentWithData:data];
	return [self flattenSOAPResponse:xml.documentRoot withPath:@""];
	//	return [self returnComplexTypeFromSOAPResponse:xml asClass:[UserGetTagsResult class]];  // complex type 
}

#pragma mark -

- (NSString *) dummyEchoWithEchoStr:(NSString *)echoStr
{
	NSString *location = @"http://services.sapo.pt/Photos";
	NSMutableArray *paramArray = [NSMutableArray array];
	[paramArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"echoStr", @"name",echoStr?echoStr:@"", @"value", nil]];
	NSURLRequest *request = [self makeSOAPRequestWithLocation:location Parameters:paramArray Operation:@"DummyEcho" Namespace:@"http://services.sapo.pt/definitions/Photos" Action:@"http://services.sapo.pt/definitions/Photos/DummyEcho" SOAPVersion:SOAPVersion1_0];
	NSURLResponse *response;
	NSError *error;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	XMLdocument *xml = [XMLdocument documentWithData:data];
	NSString *result = [self returnValueFromSOAPResponse:xml];
	return (NSString *) result;
}


@end