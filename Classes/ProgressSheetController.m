//
//  ProgressViewController.m
//  SAPOFotosApertureExportPlugin
//
//  Created by Pedro Gomes on 2/23/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "ProgressSheetController.h"


@implementation ProgressSheetController

@synthesize numberOfImages;
@synthesize maxProgress;
@synthesize progress;
@synthesize delegate;

- (void)awakeFromNib
{
	numberOfImages	= 0;
	maxProgress		= 0;
	progress		= 0;
}

- (IBAction)cancel:(id)sender
{
	[(NSControl *)sender setEnabled:NO];
	[textField setStringValue:NSLocalizedString(@"Canceling export...", @"")];
	
	if([self.delegate respondsToSelector:@selector(progressSheetControllerCanceled:)]) {
		[self.delegate progressSheetControllerCanceled:self];
	}
}

@end
