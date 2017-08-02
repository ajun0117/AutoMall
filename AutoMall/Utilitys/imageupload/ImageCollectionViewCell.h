//
//  ImageCollectionViewCell.h
//  mobilely
//
//  Created by Victoria on 15/3/3.
//  Copyright (c) 2015年 ylx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageObject.h"
@class WPImageView;
//委托
@protocol ImageCollectionViewCellDelegate <NSObject>

-(void) cellDidDeleteWithIndexPath:(NSIndexPath *)indexPath;

@end

@interface ImageCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) ImageObject *imageInfo;
@property (nonatomic, strong) WPImageView *imageView;
@property (nonatomic, strong) id<ImageCollectionViewCellDelegate>delegate;

/**
 *  设置图片信息
 *
 *  @param imageInfo <#imageInfo description#>
 */
-(void) setCellContentWithImageObject:(ImageObject *)imageInfo;
/**
 *  更新cell的索引
 *
 *  @param index <#index description#>
 */
-(void) changeIndex:(NSInteger)index;

/**
 *  修改图片当前的上传状态
 *
 *  @param uploadStatus <#uploadStatus description#>
 */
-(void) changeUploadStatus:(ImageUploadingStatus)uploadStatus;
/**
 *  上传图片
 *
 *  @param delegate
 */
-(void) uploadImage:(id)delegate andTargetId:(NSString *)targetId andTargetType:(NSString *)targetType;
@end
