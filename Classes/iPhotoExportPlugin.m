//
//  iPhotoExportPlugin.m
//  SAPOFotosApertureExportPlugin
//
//  Created by Pedro Gomes on 2/22/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "iPhotoExportPlugin.h"

@implementation iPhotoExportPlugin

#pragma mark -
#pragma mark Dealloc and Initialization

- (void)dealloc
{
	[progressLock release];
	
	[super dealloc];
}

- (id)initWithExportImageObj:(id)fp8 
{
   	if((self = [super initWithNibName:@"Panel"])) {
		_exportManager = fp8;
		[NSBundle loadNibNamed:@"Panel" owner:self];
	}
	return self;
} 

#pragma mark -
#pragma mark AbstractExportPlugin Overrides

- (NSUInteger)numberOfImages
{
	return [_exportManager imageCount];
}

- (id)defaultDirectory 
{
    return [NSString stringWithFormat:@"%@/Pictures/iPhoto Exports", NSHomeDirectory()];
}

- (id)getDestinationPath 
{
	return [NSString stringWithFormat: @"%@/ExampleOutput.txt", NSHomeDirectory()];
}

- (BOOL)wantsDestinationPrompt 
{
    return NO;
}

#pragma mark -
#pragma mark iPhoto ExportMgr

- (void)clickExport
{
	TRACE(@"ExampleExport -- clickExport");
}

- (void)performExport:(id)fp8 
{
	TRACE(@"ExampleExport -- performExport");
}

- (void)startExport:(id)fp8 
{
    TRACE(@"ExampleExport -- startExport");
	TRACE(@"%@", fp8);

	[session setObject:[NSNumber numberWithInt:[_exportManager imageCount]] forKey:kSession_TotalImagesKey];
	 [_exportManager disableControls];
	[self exportManagerShouldBeginExport];
	
	// open the file passed in as a parameter
    FILE *stream = fopen([fp8 UTF8String], "w");
	
	progress = (CDStruct_e5bf5178) {
		._field1 = 0.0,
		._field2 = [_exportManager imageCount]
	};
	
	int i;
	for(i = 0; i < [_exportManager imageCount]; i++) {
		TRACE(@"\nImage %d\n"
			  @"-------------\n"
			  @"Path: %s\n"
			  @"Caption: %s\n"
			  @"Date: %s\n",
			  i+1,
			  [[_exportManager imagePathAtIndex:i] UTF8String],
			  [[_exportManager imageTitleAtIndex:i] UTF8String],
			  [[[_exportManager imageDateAtIndex:i] description] UTF8String]);
	
		[self exportImageWithPath:[_exportManager imagePathAtIndex:i]];

//		fprintf(stream, "\nImage %d\n", (i+1));
//		fprintf(stream, "-------------\n");
//		fprintf(stream, "Path: %s\n", [[_exportManager imagePathAtIndex:i] UTF8String]);
//		fprintf(stream, "Caption: %s\n", [[_exportManager imageTitleAtIndex:i] UTF8String]);
//        fprintf(stream, "Date: %s\n", [[[_exportManager imageDateAtIndex:i] description] UTF8String]);
		
//		NSArray *keywords = [_exportManager imageKeywordsAtIndex:i];
//		int j;
//		for(j = 0; j < [keywords count]; j++) {
//			fprintf(stream, "Keyword: %s\n", [[keywords objectAtIndex:j] UTF8String]);
//		}
//		fprintf(stream, "Comments: %s\n", [[_exportManager imageCommentsAtIndex:i] UTF8String]);
	}
	
    fclose(stream);
}

- (BOOL)validateUserCreatedPath:(id)fp8 
{
    return YES;
}

- (BOOL)treatSingleSelectionDifferently 
{
    return NO;
}

- (void)viewWillBeDeactivated 
{
	[super willBeDeactivated];
}

- (void)viewWillBeActivated 
{
	[super willBeActivated];
}

- (BOOL)handlesMovieFiles
{
	return NO;
}

- (id)defaultFileName 
{
	return @"ExampleOutput.txt";
}

- (id)requiredFileType 
{
	return @"txt";
}

- (id)description 
{
    return NSLocalizedString(@"ExampleExport", @"Name of the Plugin");
}

- (id)name 
{
    return NSLocalizedString(@"ExampleExport", @"Name of the Project");
}

- (void)cancelExport 
{
	TRACE(@"ExampleExport -- cancelExport");
	exportCanceled = YES;
	[self finishExportIfCompletedOrCanceled];
}

- (void)finishExport
{
	[_exportManager markFilesExported];
	[[_exportManager window] close];
	[NSApp abortModal];
}

- (void)unlockProgress 
{
	TRACE(@"ExampleExport -- unlockProgress");
	[progressLock unlock];
}

- (void)lockProgress 
{
	TRACE(@"ExampleExport -- lockProgress");
	if(!progressLock) {
		progressLock = [[NSLock alloc] init];
	}
	[progressLock lock];
}

- (CDStruct_e5bf5178 *)progress 
{	
	TRACE(@"PROGRESS REQUEST!");
	return &progress; 
}

#pragma mark -
#pragma mark KVO

@end
