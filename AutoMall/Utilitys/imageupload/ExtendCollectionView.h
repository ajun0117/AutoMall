//
//  ExtendCollectionView.h
//  mobilely
//
//  Created by Victoria on 15/3/5.
//  Copyright (c) 2015年 ylx. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ExtendCollectionViewDelegate<NSObject, UICollectionViewDelegate>

@optional
- (void)collectionViewWillReloadData:(UICollectionView *)collectionView;
- (void)collectionViewDidReloadData:(UICollectionView *)collectionView;
@end

@interface ExtendCollectionView : UICollectionView{
    
    struct {
        unsigned int delegateWillReloadData:1;
        unsigned int delegateDidReloadData:1;
        unsigned int reloading:1;
    } _flags;
    
}

@end
