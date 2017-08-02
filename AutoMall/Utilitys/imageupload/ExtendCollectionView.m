//
//  ExtendCollectionView.m
//  mobilely
//
//  Created by Victoria on 15/3/5.
//  Copyright (c) 2015年 ylx. All rights reserved.
//

#import "ExtendCollectionView.h"

@implementation ExtendCollectionView

- (id<ExtendCollectionViewDelegate>)delegate {
    return (id<ExtendCollectionViewDelegate>)[super delegate];
}

- (void)setDelegate:(id<ExtendCollectionViewDelegate>)delegate {
    [super setDelegate:delegate];
    _flags.delegateWillReloadData = [delegate respondsToSelector:@selector(collectionViewWillReloadData:)];
    _flags.delegateDidReloadData = [delegate respondsToSelector:@selector(collectionViewDidReloadData:)];
}

- (void)reloadData {
    [super reloadData];
    if (_flags.reloading == NO) {
        _flags.reloading = YES;
        if (_flags.delegateWillReloadData) {
            [(id<ExtendCollectionViewDelegate>)self.delegate collectionViewWillReloadData:self];
        }
        [self performSelector:@selector(finishReload) withObject:nil afterDelay:0.0f];
    }
}

- (void)finishReload {
    _flags.reloading = NO;
    if (_flags.delegateDidReloadData) {
        [(id<ExtendCollectionViewDelegate>)self.delegate collectionViewDidReloadData:self];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
