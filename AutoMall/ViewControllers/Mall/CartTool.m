//
//  CartTool.m
//  AutoMall
//
//  Created by 李俊阳 on 2017/11/3.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "CartTool.h"
#import "FMDB.h"

static NSString * const dbName = @"location.db";
static NSString * const locationTabbleName = @"CartTabble";

@interface CartTool ()
//@property (nonatomic,strong) NSMutableArray * dataArray;
@property (nonatomic, strong) FMDatabase *fmdb;
@end

@implementation CartTool

static CartTool *shareInstance = nil;

#pragma mark - Singleton
+ (CartTool *)sharedManager
{
    @synchronized (self) {
        if (shareInstance == nil) {
            shareInstance = [[self alloc] init];
        }
    }
    return shareInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    @synchronized (self) {
        if (shareInstance == nil) {
            shareInstance = [super allocWithZone:zone];
        }
    }
    return shareInstance;
}

- (id)copy
{
    return shareInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self creatDB];
    }
    return self;
}

- (void)creatDB
{
    
    NSString *dbPath = [self pathForName:dbName];
    self.fmdb = [FMDatabase databaseWithPath:dbPath];
}
- (void)deleteDB
{
    NSString *dbPath = [self pathForName:dbName];
    [[NSFileManager defaultManager] removeItemAtPath:dbPath error:nil];
}

//获得指定名字的文件的全路径
- (NSString *)pathForName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths lastObject];
    NSString *dbPath = [documentDirectory stringByAppendingPathComponent:name];
    return dbPath;
}

// 判断是否存在表
- (BOOL) isTableOK
{
    BOOL openSuccess = [self.fmdb open];
    if (!openSuccess) {
        NSLog(@"地址数据库打开失败");
    } else {
        NSLog(@"地址数据库打开成功");
        FMResultSet *rs = [self.fmdb executeQuery:@"SELECT count(*) as 'count' FROM sqlite_master WHERE type ='table' and name = ?", locationTabbleName];
        while ([rs next])
        {
            // just print out what we've got in a number of formats.
            NSInteger count = [rs intForColumn:@"count"];
            if (0 == count)
            {
                [self.fmdb close];
                return NO;
            }
            else
            {
                [self.fmdb close];
                return YES;
            }
        }
    }
    [self.fmdb close];
    return NO;
}

//往表插入数据
- (void)insertRecordsWithItem:(CartItem *)item{
    if (! [self isTableOK]) {
        BOOL creat = [self createTable];
    }
    NSDate *startTime = [NSDate date];
    // 开启事务
    if ([self.fmdb open] && [self.fmdb beginTransaction]) {
        
        BOOL isRollBack = NO;
        @try
        {
            //pId  pName  aid  name  stateIndex  stateName
            NSString *insertSql= [NSString stringWithFormat:
                                  @"INSERT INTO %@ ('cartId','cartDic','orderCont','minimum') VALUES ('%@','%@','%@','%@')",
                                  locationTabbleName,item.cartId,item.cartDic,item.orderCont,item.minimum];
            BOOL a = [self.fmdb executeUpdate:insertSql];
            if (!a)
            {
                NSLog(@"插入购物车数据失败");
            }
            else
            {
                NSLog(@"批量插入购物车数据成功！");
            }
            NSDate *endTime = [NSDate date];
            NSTimeInterval a1 = [endTime timeIntervalSince1970] - [startTime timeIntervalSince1970];
            NSLog(@"使用事务地址信息用时%.3f秒",a1);
        }
        @catch (NSException *exception)
        {
            isRollBack = YES;
            [self.fmdb rollback];
        }
        @finally
        {
            if (!isRollBack)
            {
                [self.fmdb commit];
            }
        }
        [self.fmdb close];
        
    } else {
        [self insertRecordsWithItem:item];
    }
}


//创建表
- (BOOL)createTable{
    
    BOOL result = NO;
    BOOL openSuccess = [self.fmdb open];
    if (!openSuccess) {
        NSLog(@"地址数据库打开失败");
    } else {
        NSLog(@"地址数据库打开成功");
        //pId  pName  aid  name  stateIndex  stateName
        NSString *sql = [NSString stringWithFormat:@"create table if not exists %@ (cartId text primary key,cartDic text,orderCont text,minimum text);",locationTabbleName];
        result = [self.fmdb executeUpdate:sql];
        if (!result) {
            NSLog(@"创建地址表失败");
            
        } else {
            NSLog(@"创建地址表成功");
        }
    }
    [self.fmdb close];
    return result;
}

//根据areaLevel 查询
- (NSMutableArray *)queryAllCart
{
    if ([self.fmdb  open]) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@", locationTabbleName];
        FMResultSet *result = [self.fmdb  executeQuery:sql];
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
        while ([result next]) {
            CartItem *model = [[CartItem alloc] init];
            model.cartDic = [result stringForColumn:@"cartDic"];
            model.cartId = [result stringForColumn:@"cartId"];
            model.orderCont = [result stringForColumn:@"orderCont"];
            model.minimum = [result stringForColumn:@"minimum"];
            [array addObject:model];
        }
        [self.fmdb close];
        return array;
    }
    return nil;
}

-(void)UpdateContentItemWithItem:(CartItem *)item {     //修改
    // 开启事务
    if ([self.fmdb open] && [self.fmdb beginTransaction]) {
        
        BOOL isRollBack = NO;
        @try
        {
            NSString *updateSql = [NSString stringWithFormat:@"UPDATE %@ SET cartDic = '%@', orderCont = '%@', minimum = '%@' WHERE cartId = '%@'",locationTabbleName, item.cartDic, item.orderCont, item.minimum , item.cartId];
            BOOL a = [self.fmdb executeUpdate:updateSql];
            if (!a)
            {
                NSLog(@"购物车修改数据失败");
            }
            else
            {
                NSLog(@"购物车修改数据成功！");
            }
        }
        @catch (NSException *exception)
        {
            isRollBack = YES;
            [self.fmdb rollback];
        }
        @finally
        {
            if (!isRollBack)
            {
                [self.fmdb commit];
            }
        }
        [self.fmdb close];
        
    } else {
        NSLog(@"更新数据时数据库打开失败");
    }
}

-(void)deleteItemWithId:(NSString *)cid {   //删除数据
    // 开启事务
    if ([self.fmdb open] && [self.fmdb beginTransaction]) {
        
        BOOL isRollBack = NO;
        @try
        {
            NSString *updateSql = [NSString stringWithFormat:@"DELETE  FROM %@ WHERE cartId = '%@'",locationTabbleName, cid];
            BOOL a = [self.fmdb executeUpdate:updateSql];
            if (!a)
            {
                NSLog(@"删除数据失败");
            }
            else
            {
                NSLog(@"删除数据成功！");
            }
        }
        @catch (NSException *exception)
        {
            isRollBack = YES;
            [self.fmdb rollback];
        }
        @finally
        {
            if (!isRollBack)
            {
                [self.fmdb commit];
            }
        }
        [self.fmdb close];
        
    } else {
        NSLog(@"删除数据时数据库打开失败");
    }
}

-(void)removeAllCartItems {
    // 开启事务
    if ([self.fmdb open] && [self.fmdb beginTransaction]) {
        
        BOOL isRollBack = NO;
        @try
        {
            NSString *delSql = [NSString stringWithFormat:@"DELETE FROM '%@'",locationTabbleName];
            BOOL a = [self.fmdb executeUpdate:delSql];
            if (!a)
            {
                NSLog(@"删除数据失败");
            }
            else
            {
                NSLog(@"删除数据成功！");
            }
        }
        @catch (NSException *exception)
        {
            isRollBack = YES;
            [self.fmdb rollback];
        }
        @finally
        {
            if (!isRollBack)
            {
                [self.fmdb commit];
            }
        }
        [self.fmdb close];
        
    } else {
        NSLog(@"更新数据时数据库打开失败");
    }
}

@end

