//
//  AddPicViewController.m
//  YMYL
//
//  Created by 李俊阳 on 15/12/23.
//  Copyright © 2015年 ljy. All rights reserved.
//

#import "AddPicViewController.h"
#import "AppDelegate.h"
#import "HZPhotoBrowser.h"
#import "MJRefresh.h"
//#import "AddPicFooterCollectionReusableView.h"
#import "AlbumListCollectionViewCell.h"
#import "ImageCollectionViewCell.h"
#import "ImageObject.h"
#import "QBImagePickerController.h"
#import "ExtendCollectionView.h"

#define AlbumListCell      @"AlbumListCell"
//#define UpLoafImagesCount     3 //最允许上传图片张数

@interface AddPicViewController () <HZPhotoBrowserDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,QBImagePickerControllerDelegate,UICollectionViewDataSource, UICollectionViewDelegate, ImageCollectionViewCellDelegate, ExtendCollectionViewDelegate>
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSDictionary *myInfoDic;
    NSMutableArray *_imgsArray;
}
@property (weak, nonatomic) IBOutlet UICollectionView *imgsCollectionView;
@property (weak, nonatomic) IBOutlet UIView *upImageView;
@property (weak, nonatomic) IBOutlet ExtendCollectionView *myCollectionView;
@property (nonatomic, strong) NSMutableArray *imageDataArr; //当前collectionView的数据源
@property (nonatomic, strong) UINavigationController *imagePickerNavC;

@end

@implementation AddPicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"添加图片";
    // 设置导航栏按钮和标题颜色
//    [self wr_setNavBarTintColor:NavBarTintColor];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.leftBarButtonItem =  [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem.tintColor = NavBarTintColor;
    
//    self.view.backgroundColor = [UIColor colorWithPatternImage:IMG(@"homeBg")];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(uploadAction:)];
    self.navigationItem.rightBarButtonItem.tintColor = RGBCOLOR(0, 191, 243);
    
//    UIButton *editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    editBtn.frame = CGRectMake(0, 0, 50, 44);
//    //    searchBtn.contentMode = UIViewContentModeRight;
//    editBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
//    [editBtn setTitleColor:RGBCOLOR(0, 191, 243) forState:UIControlStateNormal];
//    editBtn.titleLabel.font = [UIFont systemFontOfSize:16];
//    [editBtn setTitle:@"编辑" forState:UIControlStateNormal];
//    [editBtn addTarget:self action:@selector(edit:) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *editBtnBarBtn = [[UIBarButtonItem alloc] initWithCustomView:editBtn];
//    self.navigationItem.rightBarButtonItem = editBtnBarBtn;

    [self.imgsCollectionView registerNib:[UINib nibWithNibName:@"AlbumListCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:AlbumListCell];
//    [self.myCollectionView registerNib:[UINib nibWithNibName:@"AddPicFooterCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
    
    _imgsArray = [[NSMutableArray alloc] init];
    if (self.localImgsArray) {
        [_imgsArray addObjectsFromArray:self.localImgsArray];
    }
    self.imageDataArr = [[NSMutableArray alloc] init];
    
    if (! self.maxCount) {
        self.maxCount = 3;
    }
    //图片占位
    for (int i = 0; i < self.maxCount; i ++) {
        UIImageView *dashView = [[UIImageView alloc] initWithFrame:CGRectMake(i * 100 + 10, 10, 80, 80)];
        dashView.image = IMG(@"Add_Pic");
        [self.upImageView addSubview:dashView];
    }
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectImgAction:)];
    [self.upImageView addGestureRecognizer:tap];
    
    //初始化表格布局
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing                                   = 0;
    layout.minimumInteritemSpacing                              = 0;
    layout.itemSize                                             = CGSizeMake(100, 100);
    layout.sectionInset                                         = UIEdgeInsetsMake(0, 0, 0, 0);
    
    self.myCollectionView.backgroundColor                 = [UIColor clearColor];
    self.myCollectionView.delegate                        = self;
    self.myCollectionView.dataSource                      = self;
    self.myCollectionView.showsHorizontalScrollIndicator  = NO;
    self.myCollectionView.scrollEnabled                   = NO;
    //self.recommedCollectionView.pagingEnabled                   = YES;//是否分页
    self.myCollectionView.collectionViewLayout            = layout;
    //self.recommedCollectionView.contentSize                     = CGSizeMake(50 * [self.channelArr count], 30);
    //注册表格
    [self.myCollectionView registerClass:[ImageCollectionViewCell class] forCellWithReuseIdentifier:@"CELL"];

}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (! _hud) {
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_hud];
    }
    if (!_networkConditionHUD) {
        AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        _networkConditionHUD = [[MBProgressHUD alloc] initWithView:app.window];
        [app.window addSubview:_networkConditionHUD];
        _networkConditionHUD.mode = MBProgressHUDModeText;
        _networkConditionHUD.yOffset = APP_HEIGHT/2 - HUDBottomH;
        _networkConditionHUD.margin = HUDMargin;
    }
}

-(void)save:(UIBarButtonItem *)rightItem {
    if (_imgsArray.count) {
        self.GoBackUpdate(_imgsArray);
    } else {
        _hud.labelText = @"你还没有上传任何照片哦！";
        [_hud show:YES];
        [_hud hide:YES afterDelay:HUDDelay];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)cancel {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark --UICollectionViewDataSource
//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == self.imgsCollectionView) {
        return [_imgsArray count];
    }
    return self.imageDataArr.count;
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.imgsCollectionView) {
        NSDictionary *dic = _imgsArray [indexPath.item];
        AlbumListCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:AlbumListCell forIndexPath:indexPath];
        cell.titleL.text = @"";
//        if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"编辑"]) {
//            cell.deleBtn.hidden = YES;
//        }
//        else {
//            cell.deleBtn.hidden = NO;
//        }
//        cell.deleBtn.tag = indexPath.item + 1000;
//        [cell.deleBtn addTarget:self action:@selector(deleImage:) forControlEvents:UIControlEventTouchUpInside];
        //让图片不变形，以适应按钮宽高，按钮中图片部分内容可能看不到
        cell.AlbumBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
        cell.AlbumBtn.clipsToBounds = YES;
        cell.AlbumBtn.contentHorizontalAlignment= UIControlContentHorizontalAlignmentFill;
        cell.AlbumBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
        
        [cell.AlbumBtn sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(dic[@"relativePath"])] forState:UIControlStateNormal placeholderImage:IMG(@"placeholderPictureSquare")];
        cell.AlbumBtn.tag = indexPath.item + 2000;
        
        [cell.AlbumBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
    
    ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CELL" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    //    cell.layer.borderColor = [UIColor grayColor].CGColor;
    //    cell.layer.borderWidth = 1;
    cell.indexPath = indexPath;
    cell.delegate = self;
    ImageObject *obj = [self.imageDataArr objectAtIndex:indexPath.row];
    [cell setCellContentWithImageObject:obj];
    return cell;
}

#pragma mark --UICollectionViewDelegate

//-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    NSLog(@"您选中了----%ld",(long)indexPath.row);
//    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
//}


#pragma mark --UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.imgsCollectionView) {
        return CGSizeMake((SCREEN_WIDTH-20) / 3 - 4, (SCREEN_WIDTH-20) / 3 - 4);
    }
    return CGSizeMake(100, 100);
}

//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
//{
//    if (collectionView != self.myCollectionView) {
//        AddPicFooterCollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"AddPicFooter" forIndexPath:indexPath];
//        
//        //图片占位
//        for (int i = 0; i < UpLoafImagesCount; i ++) {
//            UIImageView *dashView = [[UIImageView alloc] initWithFrame:CGRectMake(i * 100 + 10, 10, 80, 80)];
//            dashView.image = IMG(@"Add_Pic");
//            [footerView.upImageView addSubview:dashView];
//        }
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectImgAction:)];
//        [footerView.upImageView addGestureRecognizer:tap];
//        
//        //初始化表格布局
//        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
//        layout.minimumLineSpacing                                   = 0;
//        layout.minimumInteritemSpacing                              = 0;
//        layout.itemSize                                             = CGSizeMake(100, 100);
//        layout.sectionInset                                         = UIEdgeInsetsMake(0, 0, 0, 0);
//        
//        footerView.myCollectionView.backgroundColor                 = [UIColor clearColor];
//        footerView.myCollectionView.delegate                        = self;
//        footerView.myCollectionView.dataSource                      = self;
//        footerView.myCollectionView.showsHorizontalScrollIndicator  = NO;
//        footerView.myCollectionView.scrollEnabled                   = NO;
//        //self.recommedCollectionView.pagingEnabled                   = YES;//是否分页
//        footerView.myCollectionView.collectionViewLayout            = layout;
//        //self.recommedCollectionView.contentSize                     = CGSizeMake(50 * [self.channelArr count], 30);
//        //注册表格
//        [footerView.myCollectionView registerClass:[ImageCollectionViewCell class] forCellWithReuseIdentifier:@"CELL"];
//        
//        return footerView;
//    }
//    return nil;
//}
//
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
//    if (collectionView != self.myCollectionView) {
//        return CGSizeMake(SCREEN_WIDTH, 150);
//    }
//    return CGSizeZero;
//}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (collectionView == self.imgsCollectionView) {
        return UIEdgeInsetsMake(10, 0, 10, 0);
    }
    return UIEdgeInsetsMake(0, 0, 0, 0);
}


////itemCell间隔
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
//{
//    return 10;
//}


- (void)buttonClick:(UIButton *)button
{
//    NSArray *imgAry = myInfoDic [@"images"];
//    NSDictionary *dic = imgAry [button.tag - 2000];
    NSLog(@"tag: %d",(int)button.tag - 2000);
    //启动图片浏览器
    HZPhotoBrowser *browserVC = [[HZPhotoBrowser alloc] init];
    browserVC.sourceImagesContainerView = self.imgsCollectionView; // 原图的父控件
    browserVC.imageCount = _imgsArray.count; // 图片总数
    browserVC.currentImageIndex = (int)button.tag - 2000;
    browserVC.currentImageTitle = @"";
    browserVC.delegate = self;
    [browserVC show];
}

#pragma mark - photobrowser代理方法
- (UIImage *)photoBrowser:(HZPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
    NSIndexPath *path = [NSIndexPath indexPathForItem:index inSection:0];
    AlbumListCollectionViewCell * cell = (AlbumListCollectionViewCell *)[self.imgsCollectionView cellForItemAtIndexPath:path];
    return [cell.AlbumBtn currentImage];
}

- (NSURL *)photoBrowser:(HZPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index
{
//    NSArray *imgAry = myInfoDic [@"images"];
//    NSDictionary *dic = imgAry [index];
    NSDictionary *dic = _imgsArray [index];
    NSString *urlStr = UrlPrefix(dic[@"relativePath"]);
    return [NSURL URLWithString:urlStr];
}

- (NSString *)photoBrowser:(HZPhotoBrowser *)browser titleStringForIndex:(NSInteger)index {
    //    NSDictionary *dic = _typeImgsArray [index];
    //    NSString *titleStr = dic [@"content"];
    return @"";
}


- (void)selectImgAction:(id)sender {    //获取照片方式
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
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    }
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        //设置导航栏背景颜色
        picker.navigationBar.barTintColor = [UIColor whiteColor];
        //设置右侧取消按钮的字体颜色
        picker.navigationBar.tintColor = [UIColor blackColor];
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
        ALAssetsLibraryWriteImageCompletionBlock completeBlock = ^(NSURL *assetURL, NSError *error){
            if (!error) {
#pragma mark get image url from camera capture.
                //imageURL = [NSString stringWithFormat:@"%@",assetURL];
                
                //总是覆盖第一个
                ImageObject *obj = [[ImageObject alloc] init];
                obj.imageUrl = assetURL;
                obj.imageStorePath = nil;
                obj.uploadStatus = ImageUploadingStatusDefault;
                if (self.imageDataArr.count >= self.maxCount) {
                    [self.imageDataArr removeObjectAtIndex:0];
                    //[self.myCollectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:0 inSection:0]]];
                }
                [self.imageDataArr addObject:obj];
                //                [self.myCollectionView insertItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:self.imageDataArr.count - 1 inSection:0]]];
                [self.myCollectionView reloadData];
            } else {
                NSLog(@"%@",error.description);
            }
        };
        if(image){
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            [library writeImageToSavedPhotosAlbum:[image CGImage]
                                      orientation:(ALAssetOrientation)[image imageOrientation]
                                  completionBlock:completeBlock];
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
    NSMutableOrderedSet *orderedSet = [[NSMutableOrderedSet alloc] init];
    for (ImageObject *obj in self.imageDataArr) {
        [orderedSet addObject:obj.imageUrl];
    }
    
    QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
    imagePickerController.selectedAssetURLs = orderedSet;
    imagePickerController.delegate = self;
    imagePickerController.allowsMultipleSelection = 1;
    imagePickerController.maximumNumberOfSelection = self.maxCount;
    imagePickerController.minimumNumberOfSelection = 0;
    
    self.imagePickerNavC = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
    self.imagePickerNavC.delegate = self;
    [self presentViewController:self.imagePickerNavC animated:YES completion:NULL];
}

#pragma mark -
#pragma QBImagePickerControllerDelegate
////把选中的图片放到这里
- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didSelectAssets:(NSArray *)assets
{
    [self dismissImagePickerController];
    imagePickerController.delegate = nil;
    
    NSMutableArray *imageUrlArr = [[NSMutableArray alloc] init];
    for (ImageObject *obj in self.imageDataArr) {
        [imageUrlArr addObject:obj.imageUrl];
    }
    
    NSArray *newImageDataArr = [[NSArray alloc] initWithArray:self.imageDataArr];
    
    [self.imageDataArr removeAllObjects];
    
    for (int i=0; i<assets.count; i++) {
        ALAsset *asset = assets[i];
        NSURL *url = [asset valueForProperty:ALAssetPropertyAssetURL];
        ImageObject *imageObj = [[ImageObject alloc] init];
        imageObj.imageUrl = url;
        if ([imageUrlArr containsObject:url]) {
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"imageUrl = %@",url];
            ImageObject *obj = [[newImageDataArr filteredArrayUsingPredicate:predicate] firstObject];
            imageObj.imageStorePath = obj.imageStorePath;
            imageObj.uploadStatus = obj.uploadStatus;
        } else {
            imageObj.uploadStatus = ImageUploadingStatusDefault;
            imageObj.imageStorePath = nil;
        }
        [self.imageDataArr addObject:imageObj];
    }
    
    [self.myCollectionView reloadData];
}

//取消视图
//取消视图方法
- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController
{
    [imagePickerController dismissViewControllerAnimated:YES completion:nil];
    imagePickerController.delegate = nil;
    [self dismissImagePickerController];
}

- (void)dismissImagePickerController
{
    if (self.presentedViewController) {
        [self dismissViewControllerAnimated:YES completion:NULL];
        self.imagePickerNavC.delegate = nil;
    } else {
        [self.navigationController popToViewController:self animated:YES];
    }
}

#pragma mark -
#pragma ImageCollectionViewCellDelegate
-(void)cellDidDeleteWithIndexPath:(NSIndexPath *)indexPath{
    [self.imageDataArr removeObjectAtIndex:indexPath.row];
    [self.myCollectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
    
    //[[RequestManager sharedRequestManager] cancelRequestWithObject:nil];
    for (int i = 0; i < self.imageDataArr.count; i ++) {
        ImageCollectionViewCell *cell = (ImageCollectionViewCell *)[self.myCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        [cell changeIndex:i];
    }
}

-(void)deleImage:(UIButton *)btn {
    int row = (int)btn.tag - 1000;
//    NSArray *imgAry = myInfoDic [@"images"];
//    NSDictionary *dic = imgAry [row];
//   NSDictionary *dic = _imgsArray [row];
    NSLog(@"row: %d",row);
    [_imgsArray removeObjectAtIndex:row];
   [self.myCollectionView reloadData];
}

- (void)uploadAction:(id)sender {
    if (self.imageDataArr.count == 0) {
        _networkConditionHUD.labelText = @"您还没有添加图片";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
    } else {
        [_hud show:YES];
        [_imgsArray removeAllObjects];      //清空之前的图片
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:UploadImgFile object:nil];
        for (int i = 0; i < self.imageDataArr.count; i++) {
            ImageObject *obj = self.imageDataArr[i];
            ImageCollectionViewCell *cell = (ImageCollectionViewCell *)[self.myCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
            if (!obj.imageStorePath && obj.uploadStatus == ImageUploadingStatusDefault) {
                [cell changeUploadStatus:ImageUploadingStatusUploading];
                obj.uploadStatus = ImageUploadingStatusUploading;
//                [cell.imageView setCurrentProgress:0.0];
//                [cell.imageView setCircleProgressViewHidden:NO];
                [cell uploadImage:self andTargetId:nil andTargetType:nil]; 
                
                //break;
            }
        }
    }
}

#pragma mark - 网络请求结果数据
-(void) didFinishedRequestData:(NSNotification *)notification{
//    [_hud hide:YES];
    NSIndexPath *indexPath = [notification.userInfo objectForKey:@"indexPath"];
    ImageCollectionViewCell *cell = nil;
    if (indexPath) {
        cell = (ImageCollectionViewCell *)[self.myCollectionView cellForItemAtIndexPath:indexPath];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [cell.imageView setCircleProgressViewHidden:YES];
            return ;
        });
    }
    
    if ([[notification.userInfo valueForKey:@"RespResult"] isEqualToString:ERROR]) {
        _networkConditionHUD.labelText = [notification.userInfo valueForKey:@"ContentResult"];
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    NSDictionary *responseObject = [[NSDictionary alloc] initWithDictionary:[notification.userInfo objectForKey:@"RespData"]];
    
    if ([notification.name isEqualToString:UploadImgFile]) {
        //[[NSNotificationCenter defaultCenter] removeObserver:self name:REQUEST_GET_PubImage object:nil];
        ImageObject *obj = [self.imageDataArr objectAtIndex:indexPath.row];
        
        NSString *path = [NSString stringWithFormat:@"%@%@",responseObject[@"relativePath"],responseObject[@"name"]];
        NSDictionary *dic = @{@"relativePath":path};
        [_imgsArray addObject:dic];
        
        obj.imageStorePath = path;
        obj.uploadStatus = ImageUploadingStatusFinished;
        [cell changeUploadStatus:ImageUploadingStatusFinished];
        
        BOOL isComplete = YES;
        for (ImageObject *obj in self.imageDataArr) {
            if (!obj.imageStorePath && obj.uploadStatus != ImageUploadingStatusFinished && obj.imageUrl) {
                isComplete = NO;
            }
        }
        if (isComplete) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UploadImgFile object:nil];
            
            NSLog(@"jj:%@",self.imageDataArr.description);
            
            _networkConditionHUD.labelText = @"上传成功";
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            
             [self performSelector:@selector(toPopVC:) withObject:responseObject[@"data"] afterDelay:HUDDelay];
//            [self.imageDataArr removeAllObjects];
//            NSLog(@"_imgsArray: %@",_imgsArray);
//            [self.imgsCollectionView reloadData];
//            [self.myCollectionView reloadData];
            
            [_hud hide:YES];
        }
    }

}

- (void)toPopVC:(NSString *)carId {
    self.GoBackUpdate(_imgsArray);
    [self.navigationController popViewControllerAnimated:YES]; //返回首页
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
