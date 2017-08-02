//
//  QBImagePickerController.h
//  QBImagePickerController
//
//  Created by hn3l on 2013/12/30.
//  Copyright (c) 2013年 Katsuma Tanaka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef NS_ENUM(NSUInteger, QBImagePickerControllerFilterType) {
    QBImagePickerControllerFilterTypeNone,
    QBImagePickerControllerFilterTypePhotos,
    QBImagePickerControllerFilterTypeVideos
};

UIKIT_EXTERN ALAssetsFilter * ALAssetsFilterFromQBImagePickerControllerFilterType(QBImagePickerControllerFilterType type);

@class QBImagePickerController;

@protocol QBImagePickerControllerDelegate <NSObject>

@optional
- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didSelectAsset:(ALAsset *)asset;
- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didSelectAssets:(NSArray *)assets;
- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController;

@end

@interface QBImagePickerController : UITableViewController

@property (nonatomic, strong, readonly) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, copy, readonly) NSArray *assetsGroups;
#warning smy修改
@property (nonatomic, strong) NSMutableOrderedSet *selectedAssetURLs;

@property (nonatomic, weak) id<QBImagePickerControllerDelegate> delegate;
@property (nonatomic, copy) NSArray *groupTypes;
@property (nonatomic, assign) QBImagePickerControllerFilterType filterType;
@property (nonatomic, assign) BOOL showsCancelButton;
@property (nonatomic, assign) BOOL allowsMultipleSelection;
@property (nonatomic, assign) NSUInteger minimumNumberOfSelection;
@property (nonatomic, assign) NSUInteger maximumNumberOfSelection;

+ (BOOL)isAccessible;

@end
