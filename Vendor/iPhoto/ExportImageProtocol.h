/*
 *     Generated by class-dump 3.3.3 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2010 by Steve Nygard.
 */

@protocol ExportImageProtocol
- (unsigned int)imageCount;
- (struct _NSSize)imageSizeAtIndex:(unsigned int)arg1;
- (unsigned long)imageFormatAtIndex:(unsigned int)arg1;
- (unsigned long)originalImageFormatAtIndex:(unsigned int)arg1;
- (BOOL)originalIsRawAtIndex:(unsigned int)arg1;
- (BOOL)originalIsMovieAtIndex:(unsigned int)arg1;
- (id)imageTitleAtIndex:(unsigned int)arg1;
- (id)imageCommentsAtIndex:(unsigned int)arg1;
- (float)imageRotationAtIndex:(unsigned int)arg1;
- (id)imagePathAtIndex:(unsigned int)arg1;
- (id)sourcePathAtIndex:(unsigned int)arg1;
- (id)thumbnailPathAtIndex:(unsigned int)arg1;
- (id)imageFileNameAtIndex:(unsigned int)arg1;
- (BOOL)imageIsEditedAtIndex:(unsigned int)arg1;
- (BOOL)imageIsPortraitAtIndex:(unsigned int)arg1;
- (float)imageAspectRatioAtIndex:(unsigned int)arg1;
- (unsigned long long)imageFileSizeAtIndex:(unsigned int)arg1;
- (id)imageDateAtIndex:(unsigned int)arg1;
- (int)imageRatingAtIndex:(unsigned int)arg1;
- (id)imageTiffPropertiesAtIndex:(unsigned int)arg1;
- (id)imageExifPropertiesAtIndex:(unsigned int)arg1;
- (id)imageKeywordsAtIndex:(unsigned int)arg1;
- (id)albumsOfImageAtIndex:(unsigned int)arg1;
- (id)getExtensionForImageFormat:(unsigned long)arg1;
- (unsigned long)getImageFormatForExtension:(id)arg1;
- (unsigned int)albumCount;
- (unsigned int)imageCountAtAlbumIndex:(unsigned int)arg1;
- (id)albumNameAtIndex:(unsigned int)arg1;
- (id)albumMusicPathAtIndex:(unsigned int)arg1;
- (id)albumCommentsAtIndex:(unsigned int)arg1;
- (unsigned int)positionOfImageAtIndex:(unsigned int)arg1 inAlbum:(unsigned int)arg2;
- (id)window;
- (void)enableControls;
- (void)disableControls;
- (void)clickExport;
- (void)startExport;
- (void)cancelExportBeforeBeginning;
- (id)directoryPath;
- (unsigned int)sessionID;
- (BOOL)exportImageAtIndex:(unsigned int)arg1 dest:(id)arg2 options:(void *)arg3;
- (struct _NSSize)lastExportedImageSize;
@end

