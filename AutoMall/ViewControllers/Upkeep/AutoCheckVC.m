//
//  AutoCheckVC.m
//  AutoMall
//
//  Created by LYD on 2017/8/3.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "AutoCheckVC.h"
#import "AutoCheckMultiCell.h"
#import "AutoCheckGroupCell.h"
#import "UpkeepPlanVC.h"
#import "DVSwitch.h"
#import "UpkeepCarMarkVC.h"
#import "AJSegmentedControl.h"
#import "CheckContentItem.h"
#import "CheckContentTool.h"
#import "JSONKit.h"

@interface AutoCheckVC () <UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,AJSegmentedControlDelegate,UIScrollViewDelegate>
{
    NSMutableDictionary *selectedDic;   //记录已选择
    NSMutableArray *selectedAry;   //记录已选择的状态（index对应检查部位的index，object对应相应的状态字段）
    AJSegmentedControl *mySegmentedControl;
    NSArray *partsArray;   //车身部位数组
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSArray *contentAry;    //检查内容列表
    NSInteger currentSelectIndex;  //当前选中的位置
}

@end

@implementation AutoCheckVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"粤A88888";
    
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
    [searchBtn addTarget:self action:@selector(toMark) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *searchBtnBarBtn = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, searchBtnBarBtn, nil];
    
    self.mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64 + 20, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 44 - 20)];
    self.mainScrollView.pagingEnabled = YES;
    self.mainScrollView.delegate = self;
    [self.view addSubview:self.mainScrollView];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    selectedDic = [NSMutableDictionary dictionary];
    selectedAry = [NSMutableArray array];
    [self requestGetCheckcategoryList];     //记录已选择的状态

}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (! _hud) {
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_hud];
    }
    
    if (!_networkConditionHUD) {
        _networkConditionHUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_networkConditionHUD];
    }
    _networkConditionHUD.mode = MBProgressHUDModeText;
    _networkConditionHUD.yOffset = APP_HEIGHT/2 - HUDBottomH;
    _networkConditionHUD.margin = HUDMargin;
}

-(void) creatTableViews {
    for (int i = 0; i < partsArray.count; ++i) {
        UITableView *myTableView = [[UITableView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH * i, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 44 - 20) style:UITableViewStyleGrouped];
        myTableView.tag = 1000 + i;
        [self.mainScrollView addSubview:myTableView];
        myTableView.delegate = self;
        myTableView.dataSource = self;
        myTableView.allowsSelection = NO;
        myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        //    [self.carBodyTV registerNib:[UINib nibWithNibName:@"AutoCheckSingleCell" bundle:nil] forCellReuseIdentifier:@"autoCheckSingleCell"];
        [myTableView registerNib:[UINib nibWithNibName:@"AutoCheckMultiCell" bundle:nil] forCellReuseIdentifier:@"autoCheckMultiCell"];
        [myTableView registerNib:[UINib nibWithNibName:@"AutoCheckGroupCell" bundle:nil] forCellReuseIdentifier:@"autoCheckGroupCell"];
    }
    currentSelectIndex = 0;     //默认第一个
    NSString *idString = partsArray[0] [@"id"];
    [self requestGetChecktermListWithId:idString];
}

#pragma mark - 自定义segmented
- (void)createSegmentControlWithTitles:(NSArray *)titls
{
    mySegmentedControl = [[AJSegmentedControl alloc] initWithOriginY:64 Titles:titls delegate:self];
    [self.view addSubview:mySegmentedControl];
}

- (void)ajSegmentedControlSelectAtIndex:(NSInteger)index
{
    NSLog(@"index: %ld",(long)index);
    currentSelectIndex = index;
    NSString *idString = partsArray[index] [@"id"];
    [self requestGetChecktermListWithId:idString];
    NSLog(@"%ld",(long)index);
    [self.mainScrollView setContentOffset:CGPointMake(SCREEN_WIDTH * index, 0) animated:NO];

//    [self requestGetOrderList];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.mainScrollView) {
        int index = scrollView.contentOffset.x / scrollView.frame.size.width;
        [mySegmentedControl changeSegmentedControlWithIndex:index];
    }
}

-(void)toMark {
    UpkeepCarMarkVC *markVC = [[UpkeepCarMarkVC alloc] init];
    [self.navigationController pushViewController:markVC animated:YES];
}

- (IBAction)carBodyAction:(id)sender {
    [self setButton:self.carBodyBtn withBool:YES andView:self.carBodyView withColor:Red_BtnColor];
    [self setButton:self.carInsideBtn withBool:NO andView:self.carInsideView withColor:[UIColor clearColor]];
    [self setButton:self.engineRoomBtn withBool:NO andView:self.engineRoomView withColor:[UIColor clearColor]];
    [self setButton:self.chassisBtn withBool:NO andView:self.chassisView withColor:[UIColor clearColor]];
    [self setButton:self.trunkBtn withBool:NO andView:self.trunkView withColor:[UIColor clearColor]];
    
    [self.mainScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
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
    return [contentAry count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = contentAry[section][@"checkContents"];
    NSDictionary *dicc = [array firstObject];
    id groupStr = dicc[@"group"];
    if ([groupStr isKindOfClass:[NSString class]] && [groupStr length] > 1) {   //表示存在多个检查结果，多个以英文逗号分开
        NSArray *ary = [groupStr componentsSeparatedByString:@","];
        return ary.count;
    }
    else {
        return array.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSArray *array = contentAry[section][@"checkContents"];
    NSDictionary *dicc = [array firstObject];
    id groupStr = dicc[@"group"];
    if ([groupStr isKindOfClass:[NSString class]] && [groupStr length] > 1) {   //表示存在多个检查结果，多个以英文逗号分开
        return 88;
    }
    else {
        return 44;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSArray *array = contentAry[section][@"checkContents"];
    NSDictionary *dicc = [array firstObject];
    id groupStr = dicc[@"group"];
    if ([groupStr isKindOfClass:[NSString class]] && [groupStr length] > 1) {   //表示存在多个检查结果，多个以英文逗号分开
        NSDictionary *dic = contentAry[section];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 90)];
        view.backgroundColor = [UIColor whiteColor];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8, 12, 100, 20)];
        label.font = [UIFont boldSystemFontOfSize:15];
        label.backgroundColor = [UIColor clearColor];
        label.text = dic[@"name"];
        [view addSubview:label];
        
        UIView *contentBgView = [[UIView alloc] initWithFrame:CGRectMake(8, 48, SCREEN_WIDTH - 16, 30)];
        contentBgView.backgroundColor = RGBCOLOR(244, 245, 246);
        UILabel *noticeL = [[UILabel alloc] initWithFrame:CGRectMake(8, 5, 77, 20)];
        noticeL.font = [UIFont systemFontOfSize:15];
        noticeL.text = @"检查内容：";
        [contentBgView addSubview:noticeL];
        UILabel *contentL = [[UILabel alloc] initWithFrame:CGRectMake(93, 5, CGRectGetWidth(contentBgView.frame) - 77 - 24 , 20)];
        contentL.font = [UIFont systemFontOfSize:15];
        NSArray *ary = dic[@"checkContents"];
        NSDictionary *dicc;
        if (ary.count == 1) {
            dicc = [ary firstObject];
        }
        contentL.text = dicc[@"name"];
        [contentBgView addSubview:contentL];
        [view addSubview:contentBgView];
        return view;
    }
    else {
        NSDictionary *dic = contentAry[section];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
        view.backgroundColor = [UIColor whiteColor];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8, 12, 100, 20)];
        label.font = [UIFont boldSystemFontOfSize:15];
        label.backgroundColor = [UIColor clearColor];
        label.text = dic[@"name"];
        [view addSubview:label];
        
        return view;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSArray *array = contentAry[indexPath.section][@"checkContents"];
    NSDictionary *dicc = [array firstObject];
    id groupStr = dicc[@"group"];
    if ([groupStr isKindOfClass:[NSString class]] && [groupStr length] > 1) {   //表示存在多个检查结果，多个以英文逗号分开
        AutoCheckGroupCell *cell = (AutoCheckGroupCell *)[tableView dequeueReusableCellWithIdentifier:@"autoCheckGroupCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSDictionary *dic = contentAry[indexPath.section];
        NSArray *ary = dic[@"checkContents"];
        NSDictionary *dicc;
        if (ary.count == 1) {
            dicc = [ary firstObject];
        }
        NSArray *groupAry = [dicc[@"group"] componentsSeparatedByString:@","];
        
        cell.contentL.text = groupAry[indexPath.row];
        for (DVSwitch *switcher in cell.segBgView.subviews) {
            [switcher removeFromSuperview];
        }
        
        NSArray *stateAry;
        if (dicc[@"state2"] && dicc[@"state2"] != [NSNull null] &&  ! [dicc[@"state2"] isEqualToString:@""]) {
            stateAry = [NSArray arrayWithObjects:STRING(dicc[@"state1"]),STRING(dicc[@"state2"]),STRING(dicc[@"state3"]), nil];
        } else {
            stateAry = [NSArray arrayWithObjects:STRING(dicc[@"state1"]),STRING(dicc[@"state3"]), nil];
        }
        
        DVSwitch *switcher = [[DVSwitch alloc] initWithStringsArray:stateAry];
        NSLog(@"frame  --  %@",NSStringFromCGRect(switcher.frame));
        switcher.frame = CGRectMake(0, 0, SCREEN_WIDTH - 16, 36);
        switcher.font = [UIFont systemFontOfSize:13];
        [cell.segBgView addSubview:switcher];
        switcher.cornerRadius = 18;
        switcher.backgroundColor = RGBCOLOR(254, 255, 255);
        
        id tipStr = dicc[@"tip"];
        if ([tipStr isKindOfClass:[NSString class]] && [tipStr length] > 1) {   //表示需要填写检查结果
            cell.checkResultBtn.hidden = NO;
            [cell.checkResultBtn addTarget:self action:@selector(toFillTip:) forControlEvents:UIControlEventTouchUpInside];
        }
        else {
            cell.checkResultBtn.hidden = YES;
        }
        
        CheckContentItem *item = [[CheckContentTool sharedManager] queryRecordWithID:NSStringWithNumber(dicc[@"id"])];
        NSLog(@"item.aid: %@",item.aid);
        NSLog(@"item.dPositionData: %@",item.dPosition);
        NSMutableArray *positionAry = [[item.dPosition objectFromJSONString] mutableCopy];
        NSArray *aryy = [groupStr componentsSeparatedByString:@","];
        NSString *positionStr = aryy[indexPath.row];
        NSMutableDictionary *positionDic = [positionAry[indexPath.row] mutableCopy];
        NSInteger selectedIndex = [positionDic[positionStr] integerValue];
        
        [switcher forceSelectedIndex:selectedIndex animated:NO];
        [switcher setPressedHandler:^(NSUInteger index) {
            NSLog(@"Did press position on first switch at index: %lu", (unsigned long)index);
            //这里要重新从数据库读一遍
            CheckContentItem *item1 = [[CheckContentTool sharedManager] queryRecordWithID:NSStringWithNumber(dicc[@"id"])];
            NSMutableArray *positionAry = [[item1.dPosition objectFromJSONString] mutableCopy];
            NSMutableDictionary *positionDic = [positionAry[indexPath.row] mutableCopy];    //这里要重新从数据库读一遍
            CheckContentItem *item = [[CheckContentItem alloc] init];
            item.aid = NSStringWithNumber(dicc[@"id"]);
            item.stateIndex = [NSString stringWithFormat:@"%lu",(unsigned long)index];
            //        item.stateName = stateAry[index];
            [positionDic setObject:[NSString stringWithFormat:@"%lu",(unsigned long)index] forKey:positionStr];
//            NSData *positionData = [NSKeyedArchiver archivedDataWithRootObject:positionAry];
            NSLog(@"positionDic: %@",positionDic);
            [positionAry replaceObjectAtIndex:indexPath.row withObject:positionDic];
            NSLog(@"positionAry: %@",positionAry);
            NSError *err = nil;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:positionAry options:NSJSONWritingPrettyPrinted error:&err];
            NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSLog(@"jsonStr: %@",jsonStr);
            item.dPosition = jsonStr;
            [[CheckContentTool sharedManager] UpdateContentItemWithItem:item];
        }];
        
        return cell;
    }
    
    else {
        AutoCheckMultiCell *cell = (AutoCheckMultiCell *)[tableView dequeueReusableCellWithIdentifier:@"autoCheckMultiCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSDictionary *dic = contentAry[indexPath.section];
        NSArray *ary = dic[@"checkContents"];
        NSDictionary *dicc = ary [indexPath.row];
        
        cell.contentL.text = dicc[@"name"];
        for (DVSwitch *switcher in cell.segBgView.subviews) {
            [switcher removeFromSuperview];
        }
        
        NSArray *stateAry;
        if (dicc[@"state2"] && dicc[@"state2"] != [NSNull null] &&  ! [dicc[@"state2"] isEqualToString:@""]) {
            stateAry = [NSArray arrayWithObjects:STRING(dicc[@"state1"]),STRING(dicc[@"state2"]),STRING(dicc[@"state3"]), nil];
        } else {
            stateAry = [NSArray arrayWithObjects:STRING(dicc[@"state1"]),STRING(dicc[@"state3"]), nil];
        }
        
        DVSwitch *switcher = [[DVSwitch alloc] initWithStringsArray:stateAry];
        NSLog(@"frame  --  %@",NSStringFromCGRect(switcher.frame));
        switcher.frame = CGRectMake(0, 0, SCREEN_WIDTH - 16, 36);
        switcher.font = [UIFont systemFontOfSize:13];
        [cell.segBgView addSubview:switcher];
        switcher.cornerRadius = 18;
        switcher.backgroundColor = RGBCOLOR(254, 255, 255);
        
        id tipStr = dicc[@"tip"];
        if ([tipStr isKindOfClass:[NSString class]] && [tipStr length] > 1) {   //表示需要填写检查结果
            cell.checkResultBtn.hidden = NO;
            [cell.checkResultBtn addTarget:self action:@selector(toFillTip:) forControlEvents:UIControlEventTouchUpInside];
        }
        else {
            cell.checkResultBtn.hidden = YES;
        }
        
        CheckContentItem *item = [[CheckContentTool sharedManager] queryRecordWithID:NSStringWithNumber(dicc[@"id"])];
        NSInteger selectedIndex = [item.stateIndex integerValue];
        [switcher forceSelectedIndex:selectedIndex animated:NO];
        [switcher setPressedHandler:^(NSUInteger index) {
            NSLog(@"Did press position on first switch at index: %lu", (unsigned long)index);
            //        [selectedDic setObject:[NSNumber numberWithInteger:index] forKey:indexPath];
            CheckContentItem *item = [[CheckContentItem alloc] init];
            item.aid = NSStringWithNumber(dicc[@"id"]);
            item.stateIndex = [NSString stringWithFormat:@"%lu",(unsigned long)index];
            //        item.stateName = stateAry[index];
            [[CheckContentTool sharedManager] UpdateContentItemWithItem:item];
        }];
        
        return cell;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    MyInfoViewController *detailVC = [[MyInfoViewController alloc] init];
//    detailVC.userID = userArray[indexPath.section][@"id"];
//    detailVC.isDrink = self.isDrink;
//    detailVC.slidePlaceDetail = self.slidePlaceDetail;
//    [self.navigationController pushViewController:detailVC animated:YES];
}

-(void)toFillTip:(UIButton *)btn {  //填写检查结果文本
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"自定义服务器地址" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil,nil];
    [alert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];

    UITextField *nameField = [alert textFieldAtIndex:0];
    nameField.placeholder = @"请输入检查结果";
    [alert show];
}


#pragma mark - 发起网络请求
-(void)requestGetCheckcategoryList { //获取检查部位列表
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:CheckcategoryList object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:CheckcategoryList, @"op", nil];
    NSString *urlString = [NSString stringWithFormat:@"%@?checkTypeId=%@&pageSize=%d",UrlPrefix(CheckcategoryList),self.checktypeID,20];
    [[DataRequest sharedDataRequest] getDataWithUrl:urlString delegate:nil params:nil info:infoDic];
}

-(void)requestGetChecktermListWithId:(NSString *)idStr { //获取某部位的检查内容列表
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:ChecktermList object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:ChecktermList, @"op", nil];
    NSString *urlString = [NSString stringWithFormat:@"%@?checkTypeId=%@&checkCategoryId=%@&pageNo=%d&pageSize=%d",UrlPrefix(ChecktermList),self.checktypeID,idStr,0,50];
    [[DataRequest sharedDataRequest] getDataWithUrl:urlString delegate:nil params:nil info:infoDic];
}

-(void)requestCarUpkeepAdd { //生成检查单
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:CarUpkeepAdd object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:CarUpkeepAdd, @"op", nil];
//    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:@"1",@"storeId",self.discountsNameTF.text,@"item",self.discountsMoneyTF.text,@"money", nil];
//    [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefix(CarUpkeepAdd) delegate:nil params:pram info:infoDic];
}

#pragma mark - 网络请求结果数据
-(void) didFinishedRequestData:(NSNotification *)notification{
    [_hud hide:YES];
    
    if ([[notification.userInfo valueForKey:@"RespResult"] isEqualToString:ERROR]) {
        _networkConditionHUD.labelText = [notification.userInfo valueForKey:@"ContentResult"];
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    NSDictionary *responseObject = [[NSDictionary alloc] initWithDictionary:[notification.userInfo objectForKey:@"RespData"]];
    NSLog(@"GetMerchantList_responseObject: %@",responseObject);
    if ([notification.name isEqualToString:CheckcategoryList]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CheckcategoryList object:nil];
        if ([responseObject[@"success"] isEqualToString:@"y"]) {  //返回正确
            partsArray = responseObject[@"data"];
            [self createSegmentControlWithTitles:partsArray];
            self.mainScrollView.contentSize = CGSizeMake(SCREEN_WIDTH * partsArray.count, SCREEN_HEIGHT - 64 - 44 - 44);
            [self creatTableViews];
        }
        else {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
    
    if ([notification.name isEqualToString:ChecktermList]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ChecktermList object:nil];
        if ([responseObject[@"success"] isEqualToString:@"y"]) {  //返回正确
            contentAry = responseObject[@"data"];
            NSMutableArray *ary = [NSMutableArray array];
            for (NSDictionary *dic in contentAry) {
                NSDictionary *dicc = [dic[@"checkContents"] firstObject];
                id groupStr = dicc[@"group"];
                if ([groupStr isKindOfClass:[NSString class]] && [groupStr length] > 1) {   //表示存在多个检查结果，多个以英文逗号分开
                    NSArray *aryy = [groupStr componentsSeparatedByString:@","];
                    NSMutableArray *mulAry = [NSMutableArray array];
                    for (NSString *str in aryy) {
                        NSMutableDictionary *positionDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"0",str, nil];
                        [mulAry addObject:positionDic];
                    }
                    CheckContentItem *item = [[CheckContentItem alloc] init];
                    item.aid = NSStringWithNumber(dicc[@"id"]);
                    item.name = dicc[@"name"];
                    item.pId = NSStringWithNumber(partsArray[currentSelectIndex] [@"id"]);
                    item.pName = partsArray[currentSelectIndex] [@"name"];
                    item.stateIndex = @"0";
                    item.stateName = @"";
                    
                    NSError *err = nil;
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mulAry options:NSJSONWritingPrettyPrinted error:&err];
                    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    NSLog(@"jsonStr: %@",jsonStr);
                    item.dPosition = jsonStr;

                    [ary addObject:item];
                }
                else {
                    CheckContentItem *item = [[CheckContentItem alloc] init];
                    item.aid = NSStringWithNumber(dicc[@"id"]);
                    item.name = dicc[@"name"];
                    item.pId = NSStringWithNumber(partsArray[currentSelectIndex] [@"id"]);
                    item.pName = partsArray[currentSelectIndex] [@"name"];
                    item.stateIndex = @"0";
                    item.stateName = @"";
                    [ary addObject:item];
                }
            }
            NSLog(@"ary.count: %lu",(unsigned long)ary.count);
            [[CheckContentTool sharedManager] insertRecordsWithAry:ary];
            
            if ([[self.mainScrollView viewWithTag:1000+currentSelectIndex] isKindOfClass:[UITableView class]]) {
                UITableView *tableV = [self.mainScrollView viewWithTag:1000+currentSelectIndex];
                [tableV reloadData];
            }
        }
        else {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
}

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
