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
#import "MyAlertView.h"
#import "AutoCheckCarInfoVC.h"
#import "AddPicViewController.h"
#import "AutoCheckResultVC.h"
#import "BaoyangHistoryDetailVC.h"

@interface AutoCheckVC () <UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,AJSegmentedControlDelegate,UIScrollViewDelegate,UIAlertViewDelegate>
{
    AJSegmentedControl *mySegmentedControl;
    NSArray *partsArray;   //车身部位数组
    MBProgressHUD *_hud; 
    MBProgressHUD *_networkConditionHUD;
    NSArray *contentAry;    //检查内容列表
    NSInteger currentSelectIndex;  //当前选中的位置
    NSIndexPath *currentPhotoIndexPath;     //记录当前拍照按钮对应的cell位置
    NSDictionary *lichengDic;    //里程油量数据
    NSString *carImageUrl;  //车图的url
    NSArray *carImagesAry;  //车图的拍照照片
    NSArray *historyAry;        //车辆保养记录
    IBOutlet UIButton *historyBtn;
}

@end

@implementation AutoCheckVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = self.carDic[@"plateNumber"];
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
    //最近iOS项目中要求导航栏的返回按钮只保留那个箭头，去掉后边的文字，在网上查了一些资料，最简单且没有副作用的方法就是
//    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -6;

    UIButton *infoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    infoBtn.frame = CGRectMake(0, 0, 30, 30);
//    [infoBtn setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    infoBtn.contentMode = UIViewContentModeScaleAspectFit;
    [infoBtn setImage:[UIImage imageNamed:@"carInfo"] forState:UIControlStateNormal];
    [infoBtn addTarget:self action:@selector(toFillLicheng) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *infoBtnBarBtn = [[UIBarButtonItem alloc] initWithCustomView:infoBtn];
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame = CGRectMake(0, 0, 30, 30);
//    [searchBtn setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    searchBtn.contentMode = UIViewContentModeScaleAspectFit;
    [searchBtn setImage:[UIImage imageNamed:@"mark"] forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(toMark) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *searchBtnBarBtn = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: negativeSpacer, searchBtnBarBtn, infoBtnBarBtn, nil];
    
    self.mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64 + 20, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 49 - 20)];
    self.mainScrollView.pagingEnabled = YES;
    self.mainScrollView.delegate = self;
    [self.view insertSubview:self.mainScrollView belowSubview:historyBtn];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    historyBtn.layer.cornerRadius = 10;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
    [historyBtn addGestureRecognizer:pan];
    
    [[CheckContentTool sharedManager] removeAllContentItems];   //先删除所有数据
    
    [self requestGetCheckcategoryList];     //记录已选择的状态
    
    [self requestGetHistoryList];       //获取该车辆的保养记录

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
        UITableView *myTableView = [[UITableView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH * i, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 49 - 20) style:UITableViewStyleGrouped];
        myTableView.tag = 1000 + i;
        [self.mainScrollView addSubview:myTableView];
        myTableView.delegate = self;
        myTableView.dataSource = self;
        myTableView.allowsSelection = NO;
//        myTableView.pagingEnabled = YES;
        myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        //    [self.carBodyTV registerNib:[UINib nibWithNibName:@"AutoCheckSingleCell" bundle:nil] forCellReuseIdentifier:@"autoCheckSingleCell"];
        [myTableView registerNib:[UINib nibWithNibName:@"AutoCheckMultiCell" bundle:nil] forCellReuseIdentifier:@"autoCheckMultiCell"];
        [myTableView registerNib:[UINib nibWithNibName:@"AutoCheckGroupCell" bundle:nil] forCellReuseIdentifier:@"autoCheckGroupCell"];
    }
    currentSelectIndex = 0;     //默认第一个
    NSString *idString = [partsArray firstObject] [@"id"];
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

-(void)toFillLicheng {
    AutoCheckCarInfoVC *infoVC = [[AutoCheckCarInfoVC alloc] init];
    infoVC.mileageAndfuelAmountDic = lichengDic;
    infoVC.GoBackSubmitLicheng = ^(NSDictionary *dic) {
        lichengDic = dic;
        NSLog(@"lichengDic: %@",lichengDic);
    };
    infoVC.carDic = self.carDic;
    [self.navigationController pushViewController:infoVC animated:YES];
}

-(void)toMark {
    UpkeepCarMarkVC *markVC = [[UpkeepCarMarkVC alloc] init];
    markVC.GoBackGet = ^(NSString *imageUrl) {
        carImageUrl = imageUrl;
        NSLog(@"carImageUrl: %@",carImageUrl);
    };
    markVC.imgs = carImagesAry;
    markVC.GoBackCarPhoto = ^(NSArray *carImages) {
        carImagesAry = carImages;
    };
    markVC.imgUrl = carImageUrl;    
    [self.navigationController pushViewController:markVC animated:YES];
}

/**
 *  实现拖动手势方法
 *
 *  @param panGestureRecognizer 手势本身
 */
- (void)panGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer{
    //获取拖拽手势在self.view 的拖拽位置
    CGPoint translation = [panGestureRecognizer translationInView:self.view];
    //改变panGestureRecognizer.view的中心点 就是self.imageView的中心点
    panGestureRecognizer.view.center = CGPointMake(panGestureRecognizer.view.center.x, panGestureRecognizer.view.center.y + translation.y);
    //重置拖拽手势的位置
    [panGestureRecognizer setTranslation:CGPointZero inView:self.view];
}

- (IBAction)historyAction:(id)sender {
//    if (historyAry.count >= 1) {
    NSDictionary *dic = [historyAry firstObject];
    if (! [dic[@"checkTypeId"] isKindOfClass:[NSNull class]]) {
        BaoyangHistoryDetailVC *detailVC = [[BaoyangHistoryDetailVC alloc] init];
        detailVC.carDic = dic[@"car"];
        detailVC.mileage = dic[@"mileage"];
        detailVC.fuelAmount = dic[@"fuelAmount"];
        detailVC.carUpkeepId = dic[@"id"];
        detailVC.checktypeID = dic[@"checkTypeId"];
        [self.navigationController pushViewController:detailVC animated:YES];
    }
    else {
        _networkConditionHUD.labelText = @"此订单是老数据，因数据不全，不能跳转！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
    }
//    } else {
//        _networkConditionHUD.labelText = @"没有最近保养记录！";
//        [_networkConditionHUD show:YES];
//        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
//    }
}

#pragma mark - 提交生成检查单
- (IBAction)creatChecklistAction:(id)sender {
    if (lichengDic) {
        [self requestCarUpkeepAdd];
    } else {
        _networkConditionHUD.labelText = @"请先在右上角填写保养的车辆总里程表！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
    }
}

-(void) setButton:(UIButton *)btn  withBool:(BOOL)bo andView:(UIView *)view withColor:(UIColor *)color {
    btn.selected = bo;
    view.backgroundColor = color;
}

#pragma mark - 填写检查结果
-(void)toFillTip:(UIButton *)btn {  //填写检查结果文本
    UITableViewCell *cell = (UITableViewCell  *)btn.superview.superview;
    UITableView *tableV;
    if ([[self.mainScrollView viewWithTag:1000 + currentSelectIndex] isKindOfClass:[UITableView class]]) {
        tableV = [self.mainScrollView viewWithTag:1000 + currentSelectIndex];
    }
    NSIndexPath *ind = [tableV indexPathForCell:cell];
    NSArray *array = contentAry[ind.section][@"checkContents"];
    NSDictionary *dicc = [array firstObject];
    MyAlertView *alert = [[MyAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"%@",dicc[@"tip"]] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil,nil];
    alert.section = ind.section;
    alert.row = ind.row;
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    UITextField *nameField = [alert textFieldAtIndex:0];
    nameField.placeholder = @"请输入检查结果";
    
    if (! [dicc[@"tipType"] isKindOfClass:[NSNull class]]) {
        int keyType = [dicc[@"tipType"] intValue];
        switch (keyType) {
            case 0:     //文字
                nameField.keyboardType = UIKeyboardTypeDefault;
                break;
                
            case 1:     //数字带小数点
                nameField.keyboardType = UIKeyboardTypeDecimalPad;
                break;
                
            default:
                nameField.keyboardType = UIKeyboardTypeDefault;
                break;
        }
    }
    
    [alert show];
}

- (void)alertView:(MyAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSLog(@"%@",@"点击了确定");
        NSIndexPath *ind = [NSIndexPath indexPathForRow:alertView.row inSection:alertView.section];
        UITableView *tableV;
        if ([[self.mainScrollView viewWithTag:1000+currentSelectIndex] isKindOfClass:[UITableView class]]) {
            tableV = [self.mainScrollView viewWithTag:1000+currentSelectIndex];
        }
        UITableViewCell *cell = (UITableViewCell  *)[tableV cellForRowAtIndexPath:ind];
        UIButton *btn = (UIButton *)[cell viewWithTag:ind.section + 100];
        UITextField *nameField = [alertView textFieldAtIndex:0];
        [btn setTitle:nameField.text forState:UIControlStateNormal];
        
        NSArray *array = contentAry[ind.section][@"checkContents"];
        NSDictionary *dicc = [array firstObject];
        id groupStr = dicc[@"group"];
        if ([groupStr isKindOfClass:[NSString class]] && [groupStr length] > 1) {   //表示存在多个检查结果，多个以英文逗号分开,,,由于接口数据不全，待测试
            NSArray *positionArray = [groupStr componentsSeparatedByString:@","];
            NSString *positionStr = positionArray[ind.row];
            CheckContentItem *item1 = [[CheckContentTool sharedManager] queryRecordWithID:NSStringWithNumber(dicc[@"id"])];
            NSMutableArray *tipAry = [[item1.tip objectFromJSONString] mutableCopy];
            NSMutableDictionary *tipDic = [tipAry[ind.row] mutableCopy];
            CheckContentItem *item2 = [[CheckContentItem alloc] init];
            item2.aid = NSStringWithNumber(dicc[@"id"]);
            [tipDic setObject:nameField.text forKey:positionStr];
            [tipAry replaceObjectAtIndex:ind.row withObject:tipDic];
            NSLog(@"tipAry: %@",tipAry);
            NSError *err = nil;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tipAry options:NSJSONWritingPrettyPrinted error:&err];
            NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSLog(@"jsonStr: %@",jsonStr);
            item2.tip = jsonStr;
            [[CheckContentTool sharedManager] UpdateContentItemTipWithItem:item2];
        }
        else {
            CheckContentItem *item = [[CheckContentItem alloc] init];
            item.aid = NSStringWithNumber(dicc[@"id"]);
            item.tip = nameField.text;
            [[CheckContentTool sharedManager] UpdateContentItemTipWithItem:item];
        }
    }
}


//点击拍照按钮，通过按钮的父视图判断出项目
-(void) toTakePhoto:(UIButton *)btn {
    
    UITableViewCell *cell = (UITableViewCell  *)btn.superview.superview;
    UITableView *tableV;
    if ([[self.mainScrollView viewWithTag:1000+currentSelectIndex] isKindOfClass:[UITableView class]]) {
        tableV = [self.mainScrollView viewWithTag:1000+currentSelectIndex];
    }
    currentPhotoIndexPath = [tableV indexPathForCell:cell];     //记录当前拍照按钮对应的cell位置
    
    AddPicViewController *photoVC = [[AddPicViewController alloc] init];
    photoVC.GoBackUpdate = ^(NSMutableArray *array) {
        [self updatePhotoWithImages:array];
    };
    
    NSArray *array = contentAry[currentPhotoIndexPath.section][@"checkContents"];
    NSDictionary *dicc = [array firstObject];
    id groupStr = dicc[@"group"];
    if ([groupStr isKindOfClass:[NSString class]] && [groupStr length] > 1) {   //表示存在多个检查结果，多个以英文逗号分开,,,由于接口数据不全，待测试
        CheckContentItem *item = [[CheckContentTool sharedManager] queryRecordWithID:NSStringWithNumber(dicc[@"id"])];
        NSLog(@"item.aid: %@",item.aid);
        NSLog(@"item.images: %@",item.images);
        NSArray *positionArray = [groupStr componentsSeparatedByString:@","];
        NSString *positionStr = positionArray[currentPhotoIndexPath.row];
        NSMutableArray *imagesAry = [[item.images objectFromJSONString] mutableCopy];
        NSMutableDictionary *imagesDic = [imagesAry[currentPhotoIndexPath.row] mutableCopy];
        NSArray *imagesArray = imagesDic[positionStr];
        NSLog(@"imagesArray: %@",imagesArray);
        photoVC.localImgsArray = imagesArray;
    }
    else {
        CheckContentItem *item = [[CheckContentTool sharedManager] queryRecordWithID:NSStringWithNumber(dicc[@"id"])];
        NSArray *imagesAry = [[item.images objectFromJSONString] mutableCopy];
        NSLog(@"imagesAry: %@",imagesAry);
        photoVC.localImgsArray = imagesAry;
    }

    [self.navigationController pushViewController:photoVC animated:YES];
}

-(void)updatePhotoWithImages:(NSArray *)images {
    NSLog(@"拍照后返回了%@",images);
    NSArray *array = contentAry[currentPhotoIndexPath.section][@"checkContents"];
    NSDictionary *dicc = [array firstObject];
    id groupStr = dicc[@"group"];
    if ([groupStr isKindOfClass:[NSString class]] && [groupStr length] > 1) {   //表示存在多个检查结果，多个以英文逗号分开,,,由于接口数据不全，待测试
        NSArray *positionArray = [groupStr componentsSeparatedByString:@","];
        NSString *positionStr = positionArray[currentPhotoIndexPath.row];
        CheckContentItem *item1 = [[CheckContentTool sharedManager] queryRecordWithID:NSStringWithNumber(dicc[@"id"])];
        NSMutableArray *imagesAry = [[item1.images objectFromJSONString] mutableCopy];
        NSMutableDictionary *imagesDic = [imagesAry[currentPhotoIndexPath.row] mutableCopy];
        CheckContentItem *item2 = [[CheckContentItem alloc] init];
        item2.aid = NSStringWithNumber(dicc[@"id"]);
        [imagesDic setObject:images forKey:positionStr];
        [imagesAry replaceObjectAtIndex:currentPhotoIndexPath.row withObject:imagesDic];
        NSLog(@"imagesAry: %@",imagesAry);
        NSError *err = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:imagesAry options:NSJSONWritingPrettyPrinted error:&err];
        NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"jsonStr: %@",jsonStr);
        item2.images = jsonStr;
        [[CheckContentTool sharedManager] UpdateContentItemImagesWithItem:item2];
    }
    else {
        CheckContentItem *item = [[CheckContentItem alloc] init];
        item.aid = NSStringWithNumber(dicc[@"id"]);
        NSError *err = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:images options:NSJSONWritingPrettyPrinted error:&err];
        NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"jsonStr: %@",jsonStr);
        item.images = jsonStr;
        [[CheckContentTool sharedManager] UpdateContentItemImagesWithItem:item];
    }

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

/// 根据指定文本和字体计算尺寸
- (CGSize)sizeWithText:(NSString *)text font:(UIFont *)font
{
    NSMutableDictionary *attrDict = [NSMutableDictionary dictionary];
    attrDict[NSFontAttributeName] = font;
    return [text sizeWithAttributes:attrDict];
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
//    NSArray *array = contentAry[section][@"checkContents"];
    NSArray *array;
    if (contentAry.count > section && section >= 0) {
        array = contentAry[section][@"checkContents"];
    }
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
//    NSArray *array = contentAry[indexPath.section][@"checkContents"];
    NSArray *array;
    if (contentAry.count > indexPath.section && indexPath.section >= 0) {
        array = contentAry[indexPath.section][@"checkContents"];
    }
    NSDictionary *dicc = [array firstObject];
    id groupStr = dicc[@"group"];
    if ([groupStr isKindOfClass:[NSString class]] && [groupStr length] > 1) {   //表示存在多个检查结果，多个以英文逗号分开
        return 85;
    }
    else {
        return 90;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    NSArray *array = contentAry[section][@"checkContents"];
    NSArray *array;
    if (contentAry.count > section && section >= 0) {
        array = contentAry[section][@"checkContents"];
    }
    NSDictionary *dicc = [array firstObject];
    id groupStr = dicc[@"group"];
    if ([groupStr isKindOfClass:[NSString class]] && [groupStr length] > 1) {   //表示存在多个检查结果，多个以英文逗号分开
        return 44;
    }
    else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSArray *array;
    if (contentAry.count > section && section >= 0) {
        array = contentAry[section][@"checkContents"];
    }
//    NSArray *array = contentAry[section][@"checkContents"];
    NSDictionary *dicc = [array firstObject];
    id groupStr = dicc[@"group"];
    if ([groupStr isKindOfClass:[NSString class]] && [groupStr length] > 1) {   //表示存在多个检查结果，多个以英文逗号分开
        NSDictionary *dic = contentAry[section];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
        view.backgroundColor = [UIColor whiteColor];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8, 12, 100, 20)];
        label.font = [UIFont boldSystemFontOfSize:15];
        label.backgroundColor = [UIColor clearColor];
        label.text = dic[@"name"];
        CGSize nameSize = [self sizeWithText:dic[@"name"] font:[UIFont boldSystemFontOfSize:15]];
        label.frame = CGRectMake(8, 12, nameSize.width, 20);
        [view addSubview:label];
        
        UIView *contentBgView = [[UIView alloc] initWithFrame:CGRectMake(8 + 108, 7, SCREEN_WIDTH - 16 - 108, 30)];
//        contentBgView.backgroundColor = RGBCOLOR(244, 245, 246);
        contentBgView.backgroundColor = [UIColor clearColor];
//        UILabel *noticeL = [[UILabel alloc] initWithFrame:CGRectMake(8, 5, 77, 20)];
//        noticeL.font = [UIFont systemFontOfSize:15];
//        noticeL.text = @"检查内容：";
//        noticeL.textColor = Gray_Color;
//        [contentBgView addSubview:noticeL];
        UILabel *contentL = [[UILabel alloc] initWithFrame:CGRectMake(8, 5, CGRectGetWidth(contentBgView.frame) - 24 , 20)];
        contentL.font = [UIFont systemFontOfSize:15];
        NSArray *ary = dic[@"checkContents"];
        NSDictionary *dicc;
        if (ary.count == 1) {
            dicc = [ary firstObject];
        }
//        contentL.text = dicc[@"name"];
        contentL.text = [NSString stringWithFormat:@"/%@",dicc[@"name"]];
        CGSize contentSize = [self sizeWithText:dicc[@"name"] font:[UIFont boldSystemFontOfSize:15]];
        contentBgView.frame = CGRectMake(8 + nameSize.width + 8, 7, contentSize.width + 46, 30);
        [contentBgView addSubview:contentL];
        [view addSubview:contentBgView];
        return view;
    }
//    else {
//        NSDictionary *dic = contentAry[section];
//        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
//        view.backgroundColor = [UIColor whiteColor];
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8, 12, 100, 20)];
//        label.font = [UIFont boldSystemFontOfSize:15];
//        label.backgroundColor = [UIColor clearColor];
//        label.text = dic[@"name"];
//        [view addSubview:label];
//
//        return view;
//    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *array;
    if (contentAry.count > indexPath.section && indexPath.section >= 0) {
        array = contentAry[indexPath.section][@"checkContents"];
    }
//    NSArray *array = contentAry[indexPath.section][@"checkContents"];
    NSDictionary *dicc = [array firstObject];
    id groupStr = dicc[@"group"];
    if ([groupStr isKindOfClass:[NSString class]] && [groupStr length] > 1) {   //表示存在多个检查结果，多个以英文逗号分开
        AutoCheckGroupCell *cell = (AutoCheckGroupCell *)[tableView dequeueReusableCellWithIdentifier:@"autoCheckGroupCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSArray *groupAry = [groupStr componentsSeparatedByString:@","];
        
         if (groupAry.count > indexPath.row && indexPath.row >= 0) {
             cell.contentL.text = groupAry[indexPath.row];
         }
        
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
        
        CheckContentItem *item = [[CheckContentTool sharedManager] queryRecordWithID:NSStringWithNumber(dicc[@"id"])];
        NSLog(@"item.aid: %@",item.aid);
        NSLog(@"item.images: %@",item.images);
        NSArray *positionArray = [groupStr componentsSeparatedByString:@","];
        
        NSString *positionStr;
        if (positionArray.count > indexPath.row && indexPath.row >= 0) {
           positionStr = positionArray[indexPath.row];
        }
        
        id tipStr = dicc[@"tip"];
        cell.checkResultBtn.tag = indexPath.section + 100;
        if ([tipStr isKindOfClass:[NSString class]] && [tipStr length] > 1) {   //表示需要填写检查结果
            NSMutableArray *tipAry = [[item.tip objectFromJSONString] mutableCopy];
            NSMutableDictionary *tipDic = [tipAry[indexPath.row] mutableCopy];
            NSString *tipString = tipDic[positionStr];
            NSLog(@"tipString: %@",tipString);
            if ([tipString length] > 0) {
                [cell.checkResultBtn setTitle:tipString forState:UIControlStateNormal];
            }
            else {
                [cell.checkResultBtn setTitle:@"" forState:UIControlStateNormal];
            }
            cell.resultL.hidden = NO;
            cell.checkResultBtn.hidden = NO;
            [cell.checkResultBtn addTarget:self action:@selector(toFillTip:) forControlEvents:UIControlEventTouchUpInside];
        }
        else {
            cell.resultL.hidden = YES;
            cell.checkResultBtn.hidden = YES;
        }
        
//        NSMutableArray *imagesAry = [[item.images objectFromJSONString] mutableCopy];
//        NSMutableDictionary *imagesDic = [imagesAry[indexPath.row] mutableCopy];
//        NSArray *imagesArray = imagesDic[positionStr];
//        NSLog(@"imagesArray: %@",imagesArray);
        [cell.photoBtn addTarget:self action:@selector(toTakePhoto:) forControlEvents:UIControlEventTouchUpInside];

        NSMutableArray *positionAry = [[item.dPosition objectFromJSONString] mutableCopy];
        NSMutableDictionary *positionDic;
        if (positionAry.count > indexPath.row && indexPath.row >= 0) {
            positionDic = [positionAry[indexPath.row] mutableCopy];
        }
        NSDictionary *objDic = positionDic[positionStr];
        NSInteger selectedIndex = [objDic[@"stateIndex"] integerValue];
        [switcher forceSelectedIndex:selectedIndex animated:NO];
        [switcher setPressedHandler:^(NSUInteger index, NSInteger tag, NSString *indexName) {
            NSLog(@"Did press position on first switch index: %lu, tag: %lu, indexName:%@",  (unsigned long)index,(unsigned long)tag,indexName);
            //这里要重新从数据库读一遍
            CheckContentItem *item1 = [[CheckContentTool sharedManager] queryRecordWithID:NSStringWithNumber(dicc[@"id"])];
            NSMutableArray *positionAry = [[item1.dPosition objectFromJSONString] mutableCopy];
            NSMutableDictionary *positionDic = [positionAry[indexPath.row] mutableCopy];
            CheckContentItem *item2 = [[CheckContentItem alloc] init];
            item2.aid = NSStringWithNumber(dicc[@"id"]);
//            item2.stateIndex = [NSString stringWithFormat:@"%lu",(unsigned long)index];
//            item2.stateName = [NSString stringWithFormat:@"%@",indexName];
//            item2.level = indexName;
            NSDictionary *objectDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%lu",(unsigned long)index],@"stateIndex",[NSString stringWithFormat:@"%lu",(unsigned long)tag-5000],@"level",indexName,@"result", nil];
            [positionDic setObject:objectDic forKey:positionStr];
            NSLog(@"positionDic: %@",positionDic);
            [positionAry replaceObjectAtIndex:indexPath.row withObject:positionDic];
            NSLog(@"positionAry: %@",positionAry);
            NSError *err = nil;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:positionAry options:NSJSONWritingPrettyPrinted error:&err];
            NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSLog(@"jsonStr: %@",jsonStr);
            item2.dPosition = jsonStr;
            [[CheckContentTool sharedManager] UpdateContentItemWithItem:item2];
        }];
        
        return cell;
    }
    
    else {
        AutoCheckMultiCell *cell = (AutoCheckMultiCell *)[tableView dequeueReusableCellWithIdentifier:@"autoCheckMultiCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        if (array.count > indexPath.row && indexPath.row >= 0) {
        
            NSDictionary *dicc = array [indexPath.row];
            
            NSDictionary *nameDic = contentAry[indexPath.section];
            cell.nameL.text = nameDic[@"name"];
            
            cell.contentL.text = [NSString stringWithFormat:@"/%@",dicc[@"name"]];
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
            
            CheckContentItem *item = [[CheckContentTool sharedManager] queryRecordWithID:NSStringWithNumber(dicc[@"id"])];
            id tipStr = dicc[@"tip"];
            cell.checkResultBtn.tag = indexPath.section + 100;
            if ([tipStr isKindOfClass:[NSString class]] && [tipStr length] > 1) {   //表示需要填写检查结果
                NSLog(@"item.tip: %@",item.tip);
                if ([item.tip length] > 0) {
                    [cell.checkResultBtn setTitle:item.tip forState:UIControlStateNormal];
                }
                else {
                    [cell.checkResultBtn setTitle:@"" forState:UIControlStateNormal];
                }
                cell.resultL.hidden = NO;
                cell.checkResultBtn.hidden = NO;
                [cell.checkResultBtn addTarget:self action:@selector(toFillTip:) forControlEvents:UIControlEventTouchUpInside];
            }
            else {
                cell.resultL.hidden = YES;
                cell.checkResultBtn.hidden = YES;
            }
            
    //        NSArray *imagesAry = [[item.images objectFromJSONString] mutableCopy];
    //        NSLog(@"imagesAry: %@",imagesAry);
            [cell.photoBtn addTarget:self action:@selector(toTakePhoto:) forControlEvents:UIControlEventTouchUpInside];
            
            NSInteger selectedIndex = [item.stateIndex integerValue];
            [switcher forceSelectedIndex:selectedIndex animated:NO];
            [switcher setPressedHandler:^(NSUInteger index, NSInteger tag, NSString *indexName) {
                NSLog(@"Did press position on first switch index: %lu, tag: %lu, indexName:%@",  (unsigned long)index,(unsigned long)tag,indexName);
                CheckContentItem *item = [[CheckContentItem alloc] init];
                item.aid = NSStringWithNumber(dicc[@"id"]);
                item.stateIndex = [NSString stringWithFormat:@"%lu",(unsigned long)index];
                item.stateName = indexName;
                item.level = [NSString stringWithFormat:@"%lu",(unsigned long)tag-5000];
                [[CheckContentTool sharedManager] UpdateContentItemWithItem:item];
            }];
            
        }
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

#pragma mark - 发起网络请求
-(void)requestGetCheckcategoryList { //获取检查部位列表
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:CheckcategoryList object:nil];
    id storeId = [[GlobalSetting shareGlobalSettingInstance] storeId];
    NSLog(@"storeId: %@",storeId);
    if (![storeId isKindOfClass:[NSNumber class]]) {
        storeId = @"";
    }
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:CheckcategoryList, @"op", nil];
    NSString *urlString = [NSString stringWithFormat:@"%@?checkTypeId=%@&storeId=%@&pageSize=%d",UrlPrefix(CheckcategoryList),self.checktypeID,storeId,20];
    [[DataRequest sharedDataRequest] getDataWithUrl:urlString delegate:nil params:nil info:infoDic];
}

-(void)requestGetChecktermListWithId:(NSString *)idStr { //获取某部位的检查内容列表
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:ChecktermList object:nil];
    id storeId = [[GlobalSetting shareGlobalSettingInstance] storeId];
    NSLog(@"storeId: %@",storeId);
    if (![storeId isKindOfClass:[NSNumber class]]) {
        storeId = @"";
    }
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:ChecktermList, @"op", nil];
    NSString *urlString = [NSString stringWithFormat:@"%@?checkTypeId=%@&checkCategoryId=%@&storeId=%@&pageNo=%d&pageSize=%d",UrlPrefix(ChecktermList),self.checktypeID,idStr,storeId,0,50];
    [[DataRequest sharedDataRequest] getDataWithUrl:urlString delegate:nil params:nil info:infoDic];
}

-(void)requestCarUpkeepAdd { //生成检查单
//    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:CarUpkeepAdd object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:CarUpkeepAdd, @"op", nil];
    
    NSMutableArray *carUpkeepCheckContentsAry = [NSMutableArray array];
    NSMutableArray *items = [[CheckContentTool sharedManager] queryAllContent];    //从数据库查出所有记录
    for (CheckContentItem *item in items) {
        NSMutableArray *positionAry = [[item.dPosition objectFromJSONString] mutableCopy];
        if (positionAry.count > 0) {  //说明是多个位置
            NSMutableArray *tipAry = [[item.tip objectFromJSONString] mutableCopy];
            NSMutableArray *imagesAry = [[item.images objectFromJSONString] mutableCopy];
            for (int i=0; i<positionAry.count; ++i) {
                NSMutableDictionary *checkContentDic = [NSMutableDictionary dictionary];
                NSMutableDictionary *positionDic = positionAry[i];
                NSMutableDictionary *tipDic = tipAry[i];
                NSMutableDictionary *imagesDic = imagesAry[i];
                NSDictionary *objDic = [[positionDic allValues] firstObject];
                [checkContentDic setObject:objDic[@"result"] forKey:@"result"];
                [checkContentDic setObject:objDic[@"level"] forKey:@"level"];
                [checkContentDic setObject:[[positionDic allKeys] firstObject] forKey:@"dPosition"];
                [checkContentDic setObject:[[tipDic allValues] firstObject] forKey:@"describe"];
                NSArray *imgs = [[imagesDic allValues] firstObject];
                if (imgs.count > 0) {
                    [checkContentDic setObject:imgs  forKey:@"minorImages"];
                }
                int idNum = [item.aid intValue];
                NSDictionary *contentDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:idNum],@"id",item.name,@"name", nil];
                [checkContentDic setObject:contentDic forKey:@"checkContent"];
                [carUpkeepCheckContentsAry addObject:checkContentDic];
            }
        }
        else {
            NSMutableDictionary *checkContentDic = [NSMutableDictionary dictionary];
            NSArray *imagesAry = [[item.images objectFromJSONString] mutableCopy];
            [checkContentDic setObject:item.stateName forKey:@"result"];
            [checkContentDic setObject:item.level forKey:@"level"];
            [checkContentDic setObject:@"" forKey:@"dPosition"];
            [checkContentDic setObject:item.tip forKey:@"describe"];
            if (imagesAry.count > 0) {
                [checkContentDic setObject:imagesAry forKey:@"minorImages"];
            }
            int idNum = [item.aid intValue];
            NSDictionary *contentDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:idNum],@"id",item.name,@"name", nil];
            [checkContentDic setObject:contentDic forKey:@"checkContent"];
            [carUpkeepCheckContentsAry addObject:checkContentDic];
        }
        
    }
//    NSLog(@"carUpkeepCheckContentsAry: %@",carUpkeepCheckContentsAry);
    
    NSDictionary *carDicc = @{@"id":self.carDic[@"id"],@"mileage":self.carDic[@"mileage"],@"fuelAmount":self.carDic[@"fuelAmount"]};
    id storeId = [[GlobalSetting shareGlobalSettingInstance] storeId];
    NSLog(@"storeId: %@",storeId);
//    NSDictionary *storeDic;
//    if (![storeId isKindOfClass:[NSNumber class]]) {
//        storeDic = NULL;
//    }
//    else {
//        storeDic = @{@"id":storeId};
//    }
    if (![storeId isKindOfClass:[NSNumber class]]) {
        storeId = @"";
    }
    NSDictionary *storeDic = @{@"id":storeId};
    NSLog(@"storeDic: %@",storeDic);
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:STRING_Nil(carImageUrl),@"image",lichengDic[@"mileage"],@"mileage",lichengDic[@"mileageImg"],@"mileageImage",lichengDic[@"fuelAmount"],@"fuelAmount",lichengDic[@"fuelAmountImg"],@"fuelImage",lichengDic[@"remark"],@"remark",carDicc,@"car",storeDic,@"store",carUpkeepCheckContentsAry,@"carUpkeepCheckContents",self.checktypeID,@"checkTypeId",carImagesAry,@"carUpkeepImages", nil];
    NSLog(@"pram: %@",pram);
    [[DataRequest sharedDataRequest] postJSONRequestWithUrl:UrlPrefix(CarUpkeepAdd) delegate:nil params:pram info:infoDic];
}

#pragma mark - 发送请求
-(void)requestGetHistoryList { //获取车辆保养历史信息记录
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:CarUpkeepSearch object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:CarUpkeepSearch, @"op", nil];
    NSString *urlString = [NSString stringWithFormat:@"%@?carId=%@&pageNo=%d&paymentStatus=5",UrlPrefix(CarUpkeepSearch),self.carDic[@"id"], 0];
    [[DataRequest sharedDataRequest] getDataWithUrl:urlString delegate:nil params:nil info:infoDic];
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
    if ([notification.name isEqualToString:CheckcategoryList]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CheckcategoryList object:nil];
        if ([responseObject[@"success"] isEqualToString:@"y"]) {  //返回正确
            partsArray = responseObject[@"data"];
            [self createSegmentControlWithTitles:partsArray];
            self.mainScrollView.contentSize = CGSizeMake(SCREEN_WIDTH * partsArray.count, SCREEN_HEIGHT - 64 - 44 - 49);
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
                    NSMutableArray *tipMulAry = [NSMutableArray array];
                    NSMutableArray *imagesMulAry = [NSMutableArray array];
                    for (NSString *str in aryy) {
                        NSDictionary *objectDic;
                        if (dicc[@"state2"] && dicc[@"state2"] != [NSNull null] &&  ! [dicc[@"state2"] isEqualToString:@""]) {  //存在state2，则默认在2的位置
                            objectDic = [NSDictionary dictionaryWithObjectsAndKeys:@"2",@"stateIndex",[NSString stringWithFormat:@"%lu",(unsigned long)3],@"level",dicc[@"state3"],@"result", nil];
                        } else {
                            objectDic = [NSDictionary dictionaryWithObjectsAndKeys:@"1",@"stateIndex",[NSString stringWithFormat:@"%lu",(unsigned long)3],@"level",dicc[@"state3"],@"result", nil];
                        }
                        NSMutableDictionary *positionDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:objectDic,str, nil];
                        [mulAry addObject:positionDic];
                        
                        NSMutableDictionary *tipPositionDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"",str, nil];
                        [tipMulAry addObject:tipPositionDic];
                        
                        NSMutableDictionary *imagesPositionDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@[],str, nil];
                        [imagesMulAry addObject:imagesPositionDic];
                    }
                    CheckContentItem *item = [[CheckContentItem alloc] init];
                    item.aid = NSStringWithNumber(dicc[@"id"]);
                    item.name = dicc[@"name"];
                    item.pId = NSStringWithNumber(partsArray[currentSelectIndex] [@"id"]);
                    item.pName = partsArray[currentSelectIndex] [@"name"];
//                    item.stateIndex = @"0";
//                    item.stateName = @"";
//                    item.level = @"1";
                    //位置state重组
                    NSError *err = nil;
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mulAry options:NSJSONWritingPrettyPrinted error:&err];
                    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    NSLog(@"jsonStr: %@",jsonStr);
                    item.dPosition = jsonStr;
                    //位置tip重组
                    NSData *tipJsonData = [NSJSONSerialization dataWithJSONObject:tipMulAry options:NSJSONWritingPrettyPrinted error:&err];
                    NSString *tipJsonStr = [[NSString alloc] initWithData:tipJsonData encoding:NSUTF8StringEncoding];
                    NSLog(@"tipJsonStr: %@",tipJsonStr);
                    item.tip = tipJsonStr;
                    //位置images重组
                    NSData *imagesJsonData = [NSJSONSerialization dataWithJSONObject:imagesMulAry options:NSJSONWritingPrettyPrinted error:&err];
                    NSString *imagesJsonStr = [[NSString alloc] initWithData:imagesJsonData encoding:NSUTF8StringEncoding];
                    NSLog(@"imagesJsonStr: %@",imagesJsonStr);
                    item.images = imagesJsonStr;

                    [ary addObject:item];
                }
                else {
                    CheckContentItem *item = [[CheckContentItem alloc] init];
                    item.aid = NSStringWithNumber(dicc[@"id"]);
                    item.name = dicc[@"name"];
                    item.pId = NSStringWithNumber(partsArray[currentSelectIndex] [@"id"]);
                    item.pName = partsArray[currentSelectIndex] [@"name"];
                    if (dicc[@"state2"] && dicc[@"state2"] != [NSNull null] &&  ! [dicc[@"state2"] isEqualToString:@""]) {  //存在state2，则默认在2的位置
                        item.stateIndex = @"2";
                    } else {
                        item.stateIndex = @"1";
                    }
                    item.stateName = dicc[@"state3"];
                    item.level = @"3";
                    item.tip = @"";
                    //位置images重组
                    NSError *err = nil;
                    NSData *imagesJsonData = [NSJSONSerialization dataWithJSONObject:@[] options:NSJSONWritingPrettyPrinted error:&err];
                    NSString *imagesJsonStr = [[NSString alloc] initWithData:imagesJsonData encoding:NSUTF8StringEncoding];
                    NSLog(@"imagesJsonStr: %@",imagesJsonStr);
                    item.images = imagesJsonStr;
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
    
    if ([notification.name isEqualToString:CarUpkeepAdd]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CarUpkeepAdd object:nil];
        NSLog(@"CarUpkeepAdd: %@",responseObject);
        if ([responseObject[@"success"] isEqualToString:@"y"]) {  //返回正确
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            NSDictionary *dic = responseObject[@"data"];
            [self performSelector:@selector(toPushVC:) withObject:dic[@"id"] afterDelay:HUDDelay];
            
        }
        else {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
    
    if ([notification.name isEqualToString:CarUpkeepSearch]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CarUpkeepSearch object:nil];
        if ([responseObject[@"success"] isEqualToString:@"y"]) {  //返回正确
            historyAry = responseObject[@"data"];
            if (historyAry.count >= 1) {
                historyBtn.hidden = NO;
            } else {
                historyBtn.hidden = YES;
            }
        }
        else {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
}

- (void)toPushVC:(NSString *)carId {
    AutoCheckResultVC *resultVC = [[AutoCheckResultVC alloc] init];
    resultVC.carUpkeepId = carId;
    resultVC.checktypeID = self.checktypeID;
    [self.navigationController pushViewController:resultVC animated:YES];
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
