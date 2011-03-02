//
//  ProgressViewController.h
//  SAPOFotosApertureExportPlugin
//
//  Created by Pedro Gomes on 2/23/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ProgressSheetController : NSWindowController 
{
	IBOutlet NSTextField	*textField;

	NSUInteger				numberOfImages;
	double					maxProgress;	
	double					progress;
	
	NSObject				*delegate;
}

@property (nonatomic, assign) NSUInteger numberOfImages;
@property (nonatomic, assign) double maxProgress;
@property (nonatomic, assign) double progress;
@property (nonatomic, assign) NSObject *delegate;

- (IBAction)cancel:(id)sender;

@end

@interface NSObject(ProgressSheetControllerDelegate)

- (void)progressSheetControllerCanceled:(ProgressSheetController *)controller;

@end