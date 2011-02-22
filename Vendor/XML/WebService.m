//
//  WebService.m
//  SOAP
//
//  Created by Oliver on 16.10.09.
//  Copyright 2009 Drobnik.com. All rights reserved.
//

#import "WebService.h"
#import "XMLdocument.h"
#import "NSString+Helpers.h"
#import "NSDataAdditions.h"

@interface WebService(Private)

- (void)appendParameter:(id)parameter toEnvelope:(NSMutableString *)envelope;

@end

@implementation WebService

- (void)dealloc
{
	[SOAPHeader release];
	[SOAPHeaderNamespaces release];
	[super dealloc];
}

- (id)init
{
	if((self = [super init])) {
		SOAPHeader = [[NSMutableDictionary alloc] init];
		SOAPHeaderNamespaces = [[NSMutableDictionary alloc] init];
	}
	return self;
}

#pragma mark Conversions

- (BOOL) isBoolStringYES:(NSString *)string
{
	if ([[string lowercaseString] isEqualToString:@"false"] ||
		[[string lowercaseString] isEqualToString:@"0"])
	{
		return NO;
	}
	else
	{
		return YES;
	}
}

#pragma mark Requests

- (NSURLRequest *) makeGETRequestWithLocation:(NSString *)url Parameters:(NSDictionary *)parameters
{
	NSMutableString *query = [NSMutableString string];
	
	for (NSString *oneKey in [parameters allKeys])
	{
		if ([query length])
		{
			[query appendString:@"&"];
		}
		else
		{
			[query appendString:@"?"];
		}

		
		[query appendFormat:@"%@=%@", oneKey, [[parameters objectForKey:oneKey] stringByUrlEncoding]];	
	}
	
	url = [url stringByAppendingString:query];

	return [[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]] autorelease];
}


- (NSURLRequest *) makePOSTRequestWithLocation:(NSString *)url Parameters:(NSDictionary *)parameters
{
	NSMutableString *query = [NSMutableString string];
	
	for (NSString *oneKey in [parameters allKeys])
	{
		if ([query length])
		{
			[query appendString:@"&"];
		}
		
		
		[query appendFormat:@"%@=%@", oneKey, [[parameters objectForKey:oneKey] stringByUrlEncoding]];	
	}
	
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]] autorelease];
	
	[request setHTTPMethod:@"POST"];
	[request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	
	// make body
	NSData *postBody = [NSData dataWithData:[query dataUsingEncoding:NSUTF8StringEncoding]];
	[request setHTTPBody:postBody];
	
	return request;
}


- (NSURLRequest *) makeSOAPRequestWithLocation:(NSString *)url Parameters:(NSArray *)parameters Operation:(NSString *)operation Namespace:(NSString *)namespace Action:(NSString *)action SOAPVersion:(SOAPVersion)soapVersion;
{
	NSMutableString *envelope = [NSMutableString string];
	
	[envelope appendString:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"];
	
	switch (soapVersion) {
		case SOAPVersion1_0:
			[envelope appendString:@"<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"];
			break;
		case SOAPVersion1_2:
			[envelope appendString:@"<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://www.w3.org/2003/05/soap-envelope\">\n"];
			break;
	}
	
	if(SOAPHeader) {
		[envelope appendString:@"<soap:Header>"];
		
		for(NSString *headerElement in [SOAPHeader allKeys]) {
			NSString *headerNamespace = [SOAPHeaderNamespaces objectForKey:headerElement];
			NSAssert(headerNamespace != nil, SKStringWithFormat(@"Undeclared namespace for SOAPHeader element <%@>", headerElement));
			[envelope appendFormat:@"<%@ xmlns=\"%@\">\n", headerElement, headerNamespace];

			NSDictionary *child = [SOAPHeader objectForKey:headerElement];
			for(NSString *childKey in [child allKeys]) {
				[envelope appendFormat:@"<%1$@>%2$@</%1$@>\n", childKey, [child objectForKey:childKey]];
			}
			
			[envelope appendFormat:@"</%@>\n", headerElement];
		}
		
		[envelope appendString:@"</soap:Header>"];
	}
	
	[envelope appendString:@"<soap:Body>\n"];
	
	[envelope appendFormat:@"<%@ xmlns=\"%@\">\n", operation, namespace];
	

	for (NSDictionary *oneParameter in parameters) {
		NSObject *value = [oneParameter objectForKey:@"value"];
		NSString *parameterName = [[oneParameter objectForKey:@"name"] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"_"]];

		[envelope appendFormat:@"<%@>", parameterName];
		[self appendParameter:value toEnvelope:envelope];
		[envelope appendFormat:@"</%@>\n", parameterName];
	}

	[envelope appendFormat:@"</%@>\n", operation];
	[envelope appendString:@"</soap:Body>\n"];
	[envelope appendString:@"</soap:Envelope>\n"];
	
	//NSLog(@"%@", parameters);
	//NSLog(@"%@", envelope);
	
//#if LOG_WEBSERVICE_REQUESTS == 1
	TRACE(@"Webservice request: SOAPAction <%@>:\n"
		  @"***** SOAP ENVELOPE START *****\n"
		  @"%@\n"
		  @"***** SOAP ENVELOPE END *****", action, envelope);
//#endif
	
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]] autorelease];
	
	[request setHTTPMethod:@"POST"];
	[request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
	[request addValue:action forHTTPHeaderField:@"SOAPAction"];
	
	// make body
	NSData *postBody = [NSData dataWithData:[envelope dataUsingEncoding:NSUTF8StringEncoding]];
	[request setHTTPBody:postBody];
	
	return request;	
}

- (void)appendParameter:(id)parameter toEnvelope:(NSMutableString *)envelope
{
	if([parameter isKindOfClass:[NSString class]]) {
		[envelope appendString:[parameter stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	}
	else if([parameter isKindOfClass:[NSDictionary class]]) {
		for(NSString *key in [parameter allKeys]) {
			NSObject *value = [parameter objectForKey:key];
			
			[envelope appendFormat:@"\n<%@>", key];
			[self appendParameter:value toEnvelope:envelope];
			[envelope appendFormat:@"</%@>\n", key];
	
		}
	}
	else if([parameter isKindOfClass:[NSArray class]]) {
		for(id object in parameter) {
			[self appendParameter:object toEnvelope:envelope];
		}
	}
	else {
		WARN(@"***** UNSUPPORTED CLASS TYPE FOR PARAMETER <%@>", parameter);
	}

}

- (NSString *) returnValueFromSOAPResponse:(XMLdocument *)envelope
{
	XMLelement *body = [envelope.documentRoot getNamedChild:@"Body"];
	XMLelement *response = [body.children lastObject];  // there should be only one

	if (response.children)
	{	
		XMLelement *retChild = [response.children lastObject];
		
		return retChild.text;
	}
	else 
	{
		return nil;
	}
}

- (id) returnComplexTypeFromSOAPResponse:(XMLdocument *)envelope asClass:(Class)retClass
{
	// create a new instance of expected class
	
	id newObject = [[[retClass alloc] init] autorelease];
	
	XMLelement *body = [envelope.documentRoot getNamedChild:@"Body"];
	XMLelement *response = [body.children lastObject];  // there should be only one

	XMLelement *result = [response.children lastObject];  // there should be only one

	
	for (XMLelement *oneChild in result.children)
	{
		// this seems to work for scalars as well as strings without problem
		[newObject setValue:oneChild.text forKey:oneChild.name];
	}
	
	return newObject;
}

- (NSMutableDictionary*) flattenSOAPResponse:(XMLelement *)element withPath:(NSString*)path
{	
	NSArray *steps = [path componentsSeparatedByString: @"/"];
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
	XMLelement *el = element;
	for(id step in steps) {
		el = [el getNamedChild: step];
		if(el.children) {
			for (XMLelement *oneChild in el.children)
			{
				[dict setObject:oneChild.text forKey:oneChild.name];
			}
		}
	}
	return dict;
}

- (NSArray *) returnArrayFromSOAPResponse:(XMLdocument *)envelope withClass:(Class)retClass
{
	NSMutableArray *tmpArray = [NSMutableArray array];
	
	XMLelement *body = [envelope.documentRoot getNamedChild:@"Body"];
	XMLelement *response = [body.children lastObject];  // there should be only one
	
	XMLelement *result = [response.children lastObject];  // there should be only one
	
	for (XMLelement *oneThing in result.children)
	{
		id newObject = [[[retClass alloc] init] autorelease];
		
		for (XMLelement *oneChild in oneThing.children)
		{
			// this seems to work for scalars as well as strings without problem
			[newObject setValue:oneChild.text forKey:oneChild.name];
		}
		
		[tmpArray addObject:newObject];
	}
	
	if ([tmpArray count])
	{
		return [NSArray arrayWithArray:tmpArray];
	}
	else
	{
		return nil;
	}

}

- (XMLdocument *) returnXMLDocumentFromSOAPResponse:(XMLdocument *)envelope
{
	// create a new instance of expected class
	
	//id newObject = [[[retClass alloc] init] autorelease];
	
	XMLelement *body = [envelope.documentRoot getNamedChild:@"Body"];
	XMLelement *response = [body.children lastObject];  // there should be only one
	
	XMLelement *result = [response.children lastObject];  // there should be only one
	XMLelement *oneMore = [result.children lastObject];  // there should be only one
	
	return [XMLdocument documentWithString:[oneMore description]];
}

@end
