//
//  MessageListCell.h
//  AutoMall
//
//  Created by LYD on 2017/11/3.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageListCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *nameL;
@property (strong, nonatomic) IBOutlet UILabel *contentL;
@property (strong, nonatomic) IBOutlet UIImageView *ReadIM;
@property (strong, nonatomic) IBOutlet UIImageView *headIM;
@property (strong, nonatomic) IBOutlet UILabel *timeL;

@end
