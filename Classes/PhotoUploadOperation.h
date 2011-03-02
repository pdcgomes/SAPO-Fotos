//
//  PhotoUploadOperation.h
//  SAPOFotosApertureExportPlugin
//
//  Created by Pedro Gomes on 2/15/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PhotoUploadOperation : NSOperation
{
	NSString			*token;
	NSString			*imagePath;
	NSData				*imageData;
	NSDictionary		*imageProperties;
	NSDictionary		*userInfo;

	NSMutableURLRequest	*request_;
	NSURLConnection		*connection_;
	
	BOOL				cancelled;
	BOOL				executing;
	BOOL				finished;
	BOOL				uploading;
	
	int					retries;
	float				progress;
	NSObject			*delegate;
}

@property (nonatomic, assign) NSObject *delegate;
@property (nonatomic, readonly) BOOL isCancelled;
@property (nonatomic, readonly) BOOL isExecuting;
@property (nonatomic, readonly) BOOL isFinished;
@property (nonatomic, readonly) float progress;
@property (nonatomic, readonly) NSString *imagePath;

- (id)initWithImagePath:(NSString *)imagePath imageProperties:(NSDictionary *)imageProperties userInfo:(NSDictionary *)userInfo;

@end

@interface NSObject(PhotoUploadOperationDelegate)

- (void)photoUploadOperationDidStart:(PhotoUploadOperation *)operation;
- (void)photoUploadOperationDidFinish:(PhotoUploadOperation *)operation;
- (void)photoUploadOperation:(PhotoUploadOperation *)operation didFailWithError:(NSError *)error;
- (void)photoUploadOperation:(PhotoUploadOperation *)operation didReportProgress:(NSNumber *)progress;

@end
