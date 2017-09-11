//
//  AutoCheckVC.m
//  AutoMall
//
//  Created by LYD on 2017/8/3.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "AutoCheckVC.h"
#import "SingleCheckCell.h"
#import "MultiCheckCell.h"
#import "UpkeepPlanVC.h"

@interface AutoCheckVC () <UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@end

@implementation AutoCheckVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"汽车检查页";
    
//    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
////    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
//    backButton.frame = CGRectMake(0, 0, 24, 24);
//    [backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
//    UIBarButtonItem *backButnItem = [[UIBarButtonItem alloc]initWithCustomView:backButton];
//    self.navigationItem.leftBarButtonItem = backButnItem;
    
    //最近iOS项目中要求导航栏的返回按钮只保留那个箭头，去掉后边的文字，在网上查了一些资料，最简单且没有副作用的方法就是
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -6;

    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame = CGRectMake(0, 0, 24, 24);
    searchBtn.contentMode = UIViewContentModeScaleAspectFit;
    [searchBtn setImage:[UIImage imageNamed:@"mark"] forState:UIControlStateNormal];
//    [searchBtn addTarget:self action:@selector(toSearch) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *searchBtnBarBtn = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, searchBtnBarBtn, nil];
    
    self.mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64 + 44, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 44 - 44)];
    self.mainScrollView.contentSize = CGSizeMake(SCREEN_WIDTH * 5, SCREEN_HEIGHT - 64 - 44 - 44);
    self.mainScrollView.pagingEnabled = YES;
    [self.view addSubview:self.mainScrollView];
    
    self.carBodyTV = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 44) style:UITableViewStyleGrouped];
    [self.mainScrollView addSubview:self.carBodyTV];
    self.carBodyTV.delegate = self;
    self.carBodyTV.dataSource = self;
    self.carBodyTV.allowsSelection = NO;
    [self.carBodyTV registerNib:[UINib nibWithNibName:@"SingleCheckCell" bundle:nil] forCellReuseIdentifier:@"SingleCell"];
    
    self.carInsideTV = [[UITableView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 44) style:UITableViewStyleGrouped];
    [self.mainScrollView addSubview:self.carInsideTV];
    
    self.engineRoomTV = [[UITableView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH * 2, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 44) style:UITableViewStyleGrouped];
    [self.mainScrollView addSubview:self.engineRoomTV];
    
    self.chassisTV = [[UITableView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH * 3, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 44) style:UITableViewStyleGrouped];
    [self.mainScrollView addSubview:self.chassisTV];
    
    self.trunkTV = [[UITableView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH * 4, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 44) style:UITableViewStyleGrouped];
    [self.mainScrollView addSubview:self.trunkTV];
    
}

- (IBAction)carBodyAction:(id)sender {
    [self setButton:self.carBodyBtn withBool:YES andView:self.carBodyView withColor:Red_BtnColor];
    [self setButton:self.carInsideBtn withBool:NO andView:self.carInsideView withColor:[UIColor clearColor]];
    [self setButton:self.engineRoomBtn withBool:NO andView:self.engineRoomView withColor:[UIColor clearColor]];
    [self setButton:self.chassisBtn withBool:NO andView:self.chassisView withColor:[UIColor clearColor]];
    [self setButton:self.trunkBtn withBool:NO andView:self.trunkView withColor:[UIColor clearColor]];
    
    [self.mainScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
//    self.carBodyBtn.selected = YES;
//    self.carBodyView.backgroundColor = Red_BtnColor;
//    self.carInsideBtn.selected = NO;
//    self.carInsideView.backgroundColor = [UIColor clearColor];
//    self.engineRoomBtn.selected = NO;
//    self.engineRoomView.backgroundColor = [UIColor clearColor];
//    self.chassisBtn.selected = NO;
//    self.chassisView.backgroundColor = [UIColor clearColor];
//    self.trunkBtn.selected = NO;
//    self.trunkView.backgroundColor = [UIColor clearColor];
}

- (IBAction)carInsideAction:(id)sender {
    [self setButton:self.carBodyBtn withBool:NO andView:self.carBodyView withColor:[UIColor clearColor]];
    [self setButton:self.carInsideBtn withBool:YES andView:self.carInsideView withColor:Red_BtnColor];
    [self setButton:self.engineRoomBtn withBool:NO andView:self.engineRoomView withColor:[UIColor clearColor]];
    [self setButton:self.chassisBtn withBool:NO andView:self.chassisView withColor:[UIColor clearColor]];
    [self setButton:self.trunkBtn withBool:NO andView:self.trunkView withColor:[UIColor clearColor]];
    
    [self.mainScrollView setContentOffset:CGPointMake(SCREEN_WIDTH, 0) animated:NO];
}

- (IBAction)engineRoomAction:(id)sender {
    [self setButton:self.carBodyBtn withBool:NO andView:self.carBodyView withColor:[UIColor clearColor]];
    [self setButton:self.carInsideBtn withBool:NO andView:self.carInsideView withColor:[UIColor clearColor]];
    [self setButton:self.engineRoomBtn withBool:YES andView:self.engineRoomView withColor:Red_BtnColor];
    [self setButton:self.chassisBtn withBool:NO andView:self.chassisView withColor:[UIColor clearColor]];
    [self setButton:self.trunkBtn withBool:NO andView:self.trunkView withColor:[UIColor clearColor]];
    
    [self.mainScrollView setContentOffset:CGPointMake(SCREEN_WIDTH * 2, 0) animated:NO];
}

- (IBAction)chassisAction:(id)sender {
    [self setButton:self.carBodyBtn withBool:NO andView:self.carBodyView withColor:[UIColor clearColor]];
    [self setButton:self.carInsideBtn withBool:NO andView:self.carInsideView withColor:[UIColor clearColor]];
    [self setButton:self.engineRoomBtn withBool:NO andView:self.engineRoomView withColor:[UIColor clearColor]];
    [self setButton:self.chassisBtn withBool:YES andView:self.chassisView withColor:Red_BtnColor];
    [self setButton:self.trunkBtn withBool:NO andView:self.trunkView withColor:[UIColor clearColor]];
    
    [self.mainScrollView setContentOffset:CGPointMake(SCREEN_WIDTH * 3, 0) animated:NO];
}

- (IBAction)trunkAction:(id)sender {
    [self setButton:self.carBodyBtn withBool:NO andView:self.carBodyView withColor:[UIColor clearColor]];
    [self setButton:self.carInsideBtn withBool:NO andView:self.carInsideView withColor:[UIColor clearColor]];
    [self setButton:self.engineRoomBtn withBool:NO andView:self.engineRoomView withColor:[UIColor clearColor]];
    [self setButton:self.chassisBtn withBool:NO andView:self.chassisView withColor:[UIColor clearColor]];
    [self setButton:self.trunkBtn withBool:YES andView:self.trunkView withColor:Red_BtnColor];
    
    [self.mainScrollView setContentOffset:CGPointMake(SCREEN_WIDTH * 4, 0) animated:NO];
}

- (IBAction)creatChecklistAction:(id)sender {
    UpkeepPlanVC *planVC = [[UpkeepPlanVC alloc] init];
    planVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:planVC animated:YES];
}

-(void) setButton:(UIButton *)btn  withBool:(BOOL)bo andView:(UIView *)view withColor:(UIColor *)color {
    btn.selected = bo;
    view.backgroundColor = color;
}

//点击拍照按钮，通过按钮的父视图判断出项目
-(void) toTakePhoto:(UIButton *)btn {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选取照片方式" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"相机" otherButtonTitles:@"图库", nil];
    //    sheet.tag = 3000;
    [sheet showInView:self.view];
}

#pragma mark -
#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        NSLog(@"取消");
    }
    switch (buttonIndex) {
        case 0:{
            //打开照相机
            [self takePhoto];
            break;
        }
        case 1:{
            //打开本地图库
            [self localPhoto];
            break;
        }
    }
}

/**
 *  打开照相机
 */
-(void)takePhoto
{
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        self.modalPresentationStyle=UIModalPresentationOverCurrentContext;
    }
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        [self presentViewController:picker animated:YES completion:nil];
        
    }else
    {
        NSLog(@"模拟器中无法使用照相机，请在真机中使用");
    }
}

#pragma mark -
#pragma UIImagePickerControllerDelegate
//照相机选择的图片
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString *type=[info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        //__block NSString * imageURL = nil;
//        ALAssetsLibraryWriteImageCompletionBlock completeBlock = ^(NSURL *assetURL, NSError *error){
//            if (!error) {
//#pragma mark get image url from camera capture.
//                //imageURL = [NSString stringWithFormat:@"%@",assetURL];
//                
//                //总是覆盖第一个
//                ImageObject *obj = [[ImageObject alloc] init];
//                obj.imageUrl = assetURL;
//                obj.imageStorePath = nil;
//                obj.uploadStatus = ImageUploadingStatusDefault;
//                if (self.imageDataArr.count >= UpLoafImagesCount) {
//                    [self.imageDataArr removeObjectAtIndex:0];
//                    //[self.myCollectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:0 inSection:0]]];
//                }
//                [self.imageDataArr addObject:obj];
//                //                [self.myCollectionView insertItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:self.imageDataArr.count - 1 inSection:0]]];
//                [self.myCollectionView reloadData];
//            } else {
//                NSLog(@"%@",error.description);
//            }
//        };
        if(image){
//            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//            [library writeImageToSavedPhotosAlbum:[image CGImage]
//                                      orientation:(ALAssetOrientation)[image imageOrientation]
//                                  completionBlock:completeBlock];
        }
        
    }
    
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    picker.delegate = nil;
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
    picker.delegate = nil;
}

/**
 *  打开本地图库
 */
-(void)localPhoto
{
        NSUInteger sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        // 判断是否支持相机
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                    //来源:相册
                sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        else {
            sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        }
        // 跳转到相机或相册页面
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = YES;
        imagePickerController.sourceType = sourceType;
        
        [self presentViewController:imagePickerController animated:YES completion:^{
            
        }];
    
//    NSMutableOrderedSet *orderedSet = [[NSMutableOrderedSet alloc] init];
//    for (ImageObject *obj in self.imageDataArr) {
//        [orderedSet addObject:obj.imageUrl];
//    }
//    
//    QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
//    imagePickerController.selectedAssetURLs = orderedSet;
//    imagePickerController.delegate = self;
//    imagePickerController.allowsMultipleSelection = 1;
//    imagePickerController.maximumNumberOfSelection = UpLoafImagesCount;
//    imagePickerController.minimumNumberOfSelection = 0;
//    
//    self.imagePickerNavC = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
//    self.imagePickerNavC.delegate = self;
//    [self presentViewController:self.imagePickerNavC animated:YES completion:NULL];
}

//#pragma mark -
//#pragma QBImagePickerControllerDelegate
//////把选中的图片放到这里
//- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didSelectAssets:(NSArray *)assets
//{
//    [self dismissImagePickerController];
//    imagePickerController.delegate = nil;
//    
//    NSMutableArray *imageUrlArr = [[NSMutableArray alloc] init];
//    for (ImageObject *obj in self.imageDataArr) {
//        [imageUrlArr addObject:obj.imageUrl];
//    }
//    
//    NSArray *newImageDataArr = [[NSArray alloc] initWithArray:self.imageDataArr];
//    
//    [self.imageDataArr removeAllObjects];
//    
//    for (int i=0; i<assets.count; i++) {
//        ALAsset *asset = assets[i];
//        NSURL *url = [asset valueForProperty:ALAssetPropertyAssetURL];
//        ImageObject *imageObj = [[ImageObject alloc] init];
//        imageObj.imageUrl = url;
//        if ([imageUrlArr containsObject:url]) {
//            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"imageUrl = %@",url];
//            ImageObject *obj = [[newImageDataArr filteredArrayUsingPredicate:predicate] firstObject];
//            imageObj.imageStorePath = obj.imageStorePath;
//            imageObj.uploadStatus = obj.uploadStatus;
//        } else {
//            imageObj.uploadStatus = ImageUploadingStatusDefault;
//            imageObj.imageStorePath = nil;
//        }
//        [self.imageDataArr addObject:imageObj];
//    }
//    
//    [self.myCollectionView reloadData];
//}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 144;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.carBodyTV.bounds), 60)];
//    view.backgroundColor = RGBCOLOR(249, 250, 251);
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8, 12, 100, 20)];
//    label.font = [UIFont systemFontOfSize:17];
//    label.backgroundColor = [UIColor clearColor];
//    label.text = @"水箱水";
//    [view addSubview:label];
//    
//    UIButton *photoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    photoBtn.frame = CGRectMake(CGRectGetWidth(self.carBodyTV.bounds) - 8 - 20, 12, 20, 20);
//    [photoBtn setImage:IMG(@"photoBtn") forState:UIControlStateNormal];
//    [photoBtn addTarget:self action:@selector(toTakePhoto:) forControlEvents:UIControlEventTouchUpInside];
//    [view addSubview:photoBtn];
//    return view;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SingleCheckCell *cell = (SingleCheckCell *)[tableView dequeueReusableCellWithIdentifier:@"SingleCell"];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.carBodyTV.bounds), 44)];
    view.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8, 12, 100, 20)];
    label.font = [UIFont boldSystemFontOfSize:17];
    label.backgroundColor = [UIColor clearColor];
    label.text = @"水箱水";
    [view addSubview:label];
    
    UIButton *photoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    photoBtn.frame = CGRectMake(CGRectGetWidth(self.carBodyTV.bounds) - 8 - 20, 12, 20, 20);
    [photoBtn setImage:IMG(@"photoBtn") forState:UIControlStateNormal];
    [photoBtn addTarget:self action:@selector(toTakePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:photoBtn];
    [cell.contentView addSubview:view];

    UIView *viewContentV = [[UIView alloc] initWithFrame:CGRectMake(8, 44, CGRectGetWidth(self.carBodyTV.bounds) - 16, 44)];
    viewContentV.backgroundColor = RGBCOLOR(244, 245, 246);
    UILabel *noticeL = [[UILabel alloc] initWithFrame:CGRectMake(8, 12, 100, 20)];
    noticeL.font = [UIFont systemFontOfSize:15];
    noticeL.backgroundColor = [UIColor clearColor];
    noticeL.textColor = RGBCOLOR(156, 157, 158);
    noticeL.text = @"检查内容：";
    [viewContentV addSubview:noticeL];
    
    UILabel *contentL = [[UILabel alloc] initWithFrame:CGRectMake(108, 12, viewContentV.frame.size.width - 8 - 100, 20)];
    contentL.font = [UIFont systemFontOfSize:16];
    contentL.backgroundColor = [UIColor clearColor];
    contentL.tag = 1000;
    contentL.text = @"冰点";
    contentL.textAlignment = NSTextAlignmentLeft;
    [viewContentV addSubview:contentL];
    [cell.contentView addSubview:viewContentV];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    MyInfoViewController *detailVC = [[MyInfoViewController alloc] init];
//    detailVC.userID = userArray[indexPath.section][@"id"];
//    detailVC.isDrink = self.isDrink;
//    detailVC.slidePlaceDetail = self.slidePlaceDetail;
//    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - GroupedCell
//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([cell respondsToSelector:@selector(tintColor)]) {
//            CGFloat cornerRadius = 5.f;
//            cell.backgroundColor = UIColor.clearColor;
//            CAShapeLayer *layer = [[CAShapeLayer alloc] init];
//            CGMutablePathRef pathRef = CGPathCreateMutable();
//            CGRect bounds = CGRectInset(cell.bounds, 0, 0);
//            BOOL addLine = NO;
//            if (indexPath.row == 0 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
//                CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius);
//            } else if (indexPath.row == 0) {
//                CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
//                CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
//                CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
//                CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
//                addLine = YES;
//            } else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
//                CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
//                CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
//                CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
//                CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
//            } else {
//                CGPathAddRect(pathRef, nil, bounds);
//                addLine = YES;
//            }
//            layer.path = pathRef;
//            CFRelease(pathRef);
//            layer.fillColor = [UIColor colorWithWhite:1.f alpha:0.8f].CGColor;
//            
//            if (addLine == YES) {
//                CALayer *lineLayer = [[CALayer alloc] init];
//                CGFloat lineHeight = (1.f / [UIScreen mainScreen].scale);
//                lineLayer.frame = CGRectMake(CGRectGetMinX(bounds)+10, bounds.size.height-lineHeight, bounds.size.width-10, lineHeight);
//                lineLayer.backgroundColor = tableView.separatorColor.CGColor;
//                [layer addSublayer:lineLayer];
//            }
//            UIView *testView = [[UIView alloc] initWithFrame:bounds];
//            [testView.layer insertSublayer:layer atIndex:0];
//            testView.backgroundColor = UIColor.clearColor;
//            cell.backgroundView = testView;
//    }
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
