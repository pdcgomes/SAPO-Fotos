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
	NSUInteger	numberOfImages;
	double		maxProgress;	
	double		progress;

}

@property (nonatomic, assign) NSUInteger numberOfImages;
@property (nonatomic, assign) double maxProgress;
@property (nonatomic, assign) double progress;

@end
