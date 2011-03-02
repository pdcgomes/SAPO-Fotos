//
//  IPHSAPOFotosSettingsController.m
//  SAPOFotosApertureExportPlugin
//
//  Created by Pedro Gomes on 2/24/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "IPHSAPOFotosSettingsController.h"

@implementation IPHSAPOFotosSettingsController

- (id)initFromPlugin:(id)plugin withManager:(id)manager
{
	if((self = [super init])) {
		TRACE(@"");
	}
	return self;
}

- (void)awakeFromNib
{
	TRACE(@"");	
}

#pragma mark -
#pragma mark IPHPluginSettingsProtocol

- (id)settingsPanel
{
	TRACE(@"");
	return _settingsPanel;
}

- (id)advancedSettingsView
{
	TRACE(@"");	
	return _advancedSettingsPanel;
}

- (void)endWithReturnCode:(int)arg1
{
	TRACE(@"");	
}

- (id)settings
{
	TRACE(@"");	
	return nil;
}

- (void)setSettings:(id)arg1
{
	TRACE(@"");	
}

- (void)updateSetting:(id)arg1 forKey:(id)arg2
{
	TRACE(@"");	
}

- (id)settingForKey:(id)arg1
{
	TRACE(@"Setting: %@", arg1);
	return nil;
}

- (void)updateLocalSetting:(id)arg1 forKey:(id)arg2
{
	TRACE(@"localSetting: %@ forKey: %@", arg1, arg2);
}

- (id)localSettingForKey:(id)arg1
{
	TRACE(@"key: %@", arg1);
	return nil;
}

@end
