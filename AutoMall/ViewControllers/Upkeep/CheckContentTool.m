//
//  CheckContentTool.m
//  AutoMall
//
//  Created by 李俊阳 on 2017/10/5.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "CheckContentTool.h"
#import "FMDB.h"

static NSString * const dbName = @"location.db";
static NSString * const locationTabbleName = @"CheckContentTabble";

@interface CheckContentTool ()
//@property (nonatomic,strong) NSMutableArray * dataArray;
@property (nonatomic, strong) FMDatabase *fmdb;
@end

@implementation CheckContentTool

static CheckContentTool *shareInstance = nil;

#pragma mark - Singleton
+ (CheckContentTool *)sharedManager
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
- (void)insertRecordsWithAry:(NSArray *)ary{
    if (! [self isTableOK]) {
        BOOL creat = [self createTable];
    }
    NSDate *startTime = [NSDate date];
    // 开启事务
    if ([self.fmdb open] && [self.fmdb beginTransaction]) {
        
        BOOL isRollBack = NO;
        @try
        {
            for (CheckContentItem * item in ary) {
                //pId  pName  aid  name  stateIndex  stateName
                NSString *insertSql= [NSString stringWithFormat:
                                      @"INSERT INTO %@ ('pId','pName','aid','name','stateIndex', 'stateName', 'dPosition') VALUES ('%@','%@','%@','%@','%@','%@','%@')",
                                      locationTabbleName,item.pId, item.pName,item.aid,item.name ,item.stateIndex, item.stateName,item.dPosition];
                BOOL a = [self.fmdb executeUpdate:insertSql];
                if (!a)
                {
                    NSLog(@"插入地址信息数据失败");
                }
                else
                {
                    NSLog(@"批量插入地址信息数据成功！");
                }
            }
            NSDate *endTime = [NSDate date];
            NSTimeInterval a = [endTime timeIntervalSince1970] - [startTime timeIntervalSince1970];
            NSLog(@"使用事务地址信息用时%.3f秒",a);
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
        [self insertRecordsWithAry:ary];
    }
}


// 删除表
- (BOOL)deleteTable

{
    //    if (![self isTableOK]) {
    //        return YES;
    //    }
    
    BOOL openSuccess = [self.fmdb open];
    if (!openSuccess) {
        NSLog(@"地址数据库打开失败");
    } else {
        NSLog(@"地址数据库打开成功");
        NSString *sqlstr = [NSString stringWithFormat:@"DROP TABLE %@", locationTabbleName];
        
        if (![self.fmdb executeUpdate:sqlstr])
        {
            [self.fmdb close];
            return NO;
        }
    }
    [self.fmdb close];
    return YES;
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
        NSString *sql = [NSString stringWithFormat:@"create table if not exists %@ (aid text primary key,pId text,pName text,name text,stateIndex text,stateName text,dPosition text);",locationTabbleName];
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
- (NSMutableArray *)queryAllContent
{
    if ([self.fmdb  open]) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE level = 1", locationTabbleName];
        FMResultSet *result = [self.fmdb  executeQuery:sql];
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
        while ([result next]) {
            CheckContentItem *model = [[CheckContentItem alloc] init];
            model.pId = [result stringForColumn:@"pId"];
            model.pName = [result stringForColumn:@"pName"];
            model.aid = [result stringForColumn:@"aid"];
            model.name = [result stringForColumn:@"name"];
            model.stateIndex = [result stringForColumn:@"stateIndex"];
            model.stateName = [result stringForColumn:@"stateName"];
            model.dPosition = [result stringForColumn:@"dPosition"];
            [array addObject:model];
        }
        [self.fmdb close];
        return array;
    }
    return nil;
}


//根据部位Id 查询出该Id下所有的检查内容项目
- (NSMutableArray *)queryAllRecordWithBuweiID:(NSString *) buwei
{
    if ([self.fmdb  open]) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE pId = %@", locationTabbleName,buwei];
        FMResultSet *result = [self.fmdb  executeQuery:sql];
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
        //'code','sheng','di','xian','name', 'level'
        while ([result next]) {
            CheckContentItem *model = [[CheckContentItem alloc] init];
            model.pId = [result stringForColumn:@"pId"];
            model.pName = [result stringForColumn:@"pName"];
            model.aid = [result stringForColumn:@"aid"];
            model.name = [result stringForColumn:@"name"];
            model.stateIndex = [result stringForColumn:@"stateIndex"];
            model.stateName = [result stringForColumn:@"stateName"];
            model.dPosition = [result stringForColumn:@"dPosition"];
            [array addObject:model];
        }
        [self.fmdb close];
        return array;
    }
    return nil;
}

//根据检查内容Id 查询出该Id的数据
- (CheckContentItem *)queryRecordWithID:(NSString *) aId
{
    if ([self.fmdb  open]) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE aid = %@"  , locationTabbleName,aId];
        FMResultSet *result = [self.fmdb  executeQuery:sql];
        //'code','sheng','di','xian','name', 'level'
        CheckContentItem *model = [[CheckContentItem alloc] init];
        while ([result next]) {
            model.pId = [result stringForColumn:@"pId"];
            model.pName = [result stringForColumn:@"pName"];
            model.aid = [result stringForColumn:@"aid"];
            model.name = [result stringForColumn:@"name"];
            model.stateIndex = [result stringForColumn:@"stateIndex"];
            model.stateName = [result stringForColumn:@"stateName"];
            model.dPosition = [result stringForColumn:@"dPosition"];
        }
        [self.fmdb close];
        return model;
    }
    return nil;
}

-(void)UpdateContentItemWithItem:(CheckContentItem *)item {     //通过检查内容id修改
    // 开启事务
    if ([self.fmdb open] && [self.fmdb beginTransaction]) {
        
        BOOL isRollBack = NO;
        @try
        {
            NSLog(@" item.dPosition: %@", item.dPosition);
            NSString *updateSql = [NSString stringWithFormat:@"UPDATE %@ SET stateIndex = '%@', stateName = '%@', dPosition = '%@' WHERE aid = '%@'",locationTabbleName, item.stateIndex, item.stateName, item.dPosition, item.aid];
            BOOL a = [self.fmdb executeUpdate:updateSql];
            if (!a)
            {
                NSLog(@"修改数据失败");
            }
            else
            {
                NSLog(@"修改数据成功！");
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
