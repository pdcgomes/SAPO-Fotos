/*
 *     Generated by class-dump 3.3.3 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2010 by Steve Nygard.
 */

@protocol IPHPluginManagerProtocol
- (id)defaultUserAgent;
- (void)setDefaultUserAgent:(id)arg1;
- (id)defaultAuthoringClient;
- (void)setDefaultAuthoringClient:(id)arg1;
- (id)applicationID;
- (id)supportedPhotoSizes;
- (BOOL)uidsAreCaseInsensitive;
- (void)saveKeychainInformationForURL:(id)arg1 andPassword:(id)arg2;
- (id)loadKeychainInformationForURL:(id)arg1;
- (void)removeKeychainInformationForURL:(id)arg1;
- (id)albumNamesForProtectionUsername:(id)arg1 serviceKey:(id)arg2 serviceUsername:(id)arg3;
- (void)updateProtectionUsername:(id)arg1 fromOldUsername:(id)arg2 serviceKey:(id)arg3 serviceUsername:(id)arg4;
- (id)generateUUID;
- (unsigned long long)sizeAtPath:(id)arg1 physical:(BOOL)arg2;
- (void)tickleInsertionPoint:(id)arg1;
- (id)incrementTrailingCount:(id)arg1 delim:(id)arg2 first:(BOOL)arg3;
- (id)ellipsizerWithAttributes:(id)arg1;
- (BOOL)canDoNetDiagnostics;
- (BOOL)isNetworkDisconnected;
- (void)showNetDiagnostics;
- (id)extensionForImageFormat:(unsigned long)arg1;
- (unsigned long)imageFormatForExtension:(id)arg1;
- (id)mimeTypeForExtension:(id)arg1;
- (id)errorFromDMKitTransaction:(id)arg1;
- (id)errorDisplayStringForError:(id)arg1 url:(id)arg2;
- (id)unpublishOperationForDB:(id)arg1 URL:(id)arg2 service:(id)arg3;
- (void)addUpdateOperation:(id)arg1;
@end

