//
//  ImageCollectionViewCell.m
//  mobilely
//
//  Created by Victoria on 15/3/3.
//  Copyright (c) 2015年 ylx. All rights reserved.
//

#import "ImageCollectionViewCell.h"
#import "WPImageView.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface ImageCollectionViewCell ()

@property (nonatomic, strong) UIButton *delButn;
@end

@implementation ImageCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
//        self.backgroundColor = [UIColor redColor];
//        self.alpha = 0.3;
        
        self.imageView = [[WPImageView alloc] initWithFrame:CGRectMake(10, 10, 80, 80) backColor:[UIColor colorWithWhite:0.603 alpha:0.390] progressColor:[UIColor greenColor] lineWidth:2];
        //self.imageView.center = self.contentView.center;
        [self addSubview:self.imageView];
        
        //初始化删除按钮
        self.delButn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.delButn setFrame:CGRectMake(frame.size.width - 20, 0, 20, 20)];
        [self.delButn setImage:[UIImage imageNamed:@"delete_pic"] forState:UIControlStateNormal];
        [self.delButn addTarget:self action:@selector(didDeleteCell:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.delButn];
    }
    
    return self;
}

-(void)setCellContentWithImageObject:(ImageObject *)imageInfo{
    self.imageInfo = imageInfo;
    ALAssetsLibrary* alLibrary = [[ALAssetsLibrary alloc] init];
    [alLibrary assetForURL:imageInfo.imageUrl resultBlock:^(ALAsset *asset) {
//        NSLog(@"asset：%@",asset);
        UIImage *image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
        [self.imageView setImageViewWithImage:image];
        if (!imageInfo.imageStorePath) {
//            [self.imageView setCurrentProgress:0.0];
//            [self.imageView setCircleProgressViewHidden:NO];
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"%@",error.description);
    }];
}

-(void) didDeleteCell:(id)sender{
    if ([self.delegate respondsToSelector:@selector(cellDidDeleteWithIndexPath:)]) {
        [self.delegate cellDidDeleteWithIndexPath:self.indexPath];
    }
}

-(void)changeIndex:(NSInteger)index{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    self.indexPath = indexPath;
}

-(void)changeUploadStatus:(ImageUploadingStatus)uploadStatus{
    self.imageInfo.uploadStatus = uploadStatus;
}

-(void) uploadImage:(id)delegate andTargetId:(NSString *)targetId andTargetType:(NSString *)targetType {
    if (self.imageView.image) {
//        ALAssetsLibrary* alLibrary = [[ALAssetsLibrary alloc] init];
//        [alLibrary assetForURL:self.imageInfo.imageUrl resultBlock:^(ALAsset *asset) {
//            NSLog(@"asset： %@",asset);
//            NSString *extStr = [nss];
            [self requestUploadImgWithIndex:self.indexPath andImage:self.imageView delegate:delegate andTargetId:targetId andTargetType:targetType andExt:nil];
//        } failureBlock:^(NSError *error) {
//            NSLog(@"%@",error.description);
//        }];
        
    } else {
        ALAssetsLibrary* alLibrary = [[ALAssetsLibrary alloc] init];
        [alLibrary assetForURL:self.imageInfo.imageUrl resultBlock:^(ALAsset *asset) {
//            NSLog(@"%@",asset);
//            [asset.defaultRepresentation url]
            UIImage *image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
            [self.imageView setImageViewWithImage:image];
            [self requestUploadImgWithIndex:self.indexPath andImage:self.imageView delegate:delegate andTargetId:targetId andTargetType:targetType andExt:nil];
        } failureBlock:^(NSError *error) {
            NSLog(@"%@",error.description);
        }];
    }
    
}

#pragma mark - 发送请求
-(void)requestUploadImgWithIndex:(NSIndexPath *)indexPath andImage:(WPImageView *)image delegate:(id)delegate andTargetId:(NSString *)targetId andTargetType:(NSString *)targetType andExt:(NSString *)ext {
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:ImageUpload,@"op",indexPath,@"indexPath", nil];

    //data=data
    NSData *imageData = UIImageJPEGRepresentation(image.image, 1);
    NSInteger length = imageData.length;
    if (length > 1048) {
        CGFloat packRate = 1048.0/length;
        imageData = UIImageJPEGRepresentation(image.image, packRate);
    }
    //    NNSData* originData = [originStr dataUsingEncoding:NSASCIIStringEncoding];
    NSString* baseStr = [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    NSString *baseString = (__bridge NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                         (CFStringRef)baseStr,
                                                                                         NULL,
                                                                                         CFSTR(":/?#[]@!$&’()*+,;="),
                                                                                         kCFStringEncodingUTF8);
//    NSLog(@"baseString:%@",baseString); 
    
    NSDictionary *paramsDic = [[NSDictionary alloc] initWithObjectsAndKeys:baseString,@"imgData",@"jpg",@"ext",targetType,@"targetType",targetId,@"targetId", nil]; //评论targetType=3
    NSLog(@"paramsDic: %@",paramsDic);
    [[DataRequest sharedDataRequest] postDataWithUrl:RequestURL(ImageUpload) delegate:nil params:paramsDic info:infoDic];
//    [[DataRequest sharedDataRequest] uploadImageWithUrl:RequestURL(ImageUpload) params:paramsDic target:image delegate:delegate info:infoDic];
}

@end
