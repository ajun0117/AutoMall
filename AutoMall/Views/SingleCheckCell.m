//
//  SingleCheckCell.m
//  AutoMall
//
//  Created by LYD on 2017/8/9.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "SingleCheckCell.h"


@implementation SingleCheckCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.switcher = [[DVSwitch alloc] initWithStringsArray:@[@"严重", @"轻微",@"正常"]];
    NSLog(@"frame  --  %@",NSStringFromCGRect(self.switcher.frame));
    self.switcher.frame = CGRectMake(8, self.frame.size.height - 30 - 8 + 16 + 5, SCREEN_WIDTH - 16, 30);
    self.switcher.font = [UIFont systemFontOfSize:13];
    [self.contentView addSubview:self.switcher];
    self.switcher.cornerRadius = 15;
    self.switcher.backgroundColor = RGBCOLOR(254, 255, 255);
    [self.switcher forceSelectedIndex:2 animated:NO];
    [self.switcher setPressedHandler:^(NSUInteger index) {
        
        NSLog(@"Did press position on first switch at index: %lu", (unsigned long)index);
        
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
