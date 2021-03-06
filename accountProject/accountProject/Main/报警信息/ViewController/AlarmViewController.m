//
//  AlarmViewController.m
//  accountProject
//
//  Created by 弘鼎 on 2017/12/29.
//  Copyright © 2017年 贺亚飞. All rights reserved.
//

#import "AlarmViewController.h"
#import "AlertTableViewCell.h"
#import "AlarmModel.h"
@interface AlarmViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView *tableview;
@property (nonatomic,strong) NSMutableArray *dataArr;
@property (nonatomic,assign) NSInteger pageStr;
@end

@implementation AlarmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"报警信息";
    self.navigationController.navigationBar.barTintColor = RGB(44, 50, 59);
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];

    _dataArr = [NSMutableArray arrayWithCapacity:0];
    self.view.backgroundColor = RGB(242, 242, 242);
    _pageStr = 0;
    [self tableview];
    [self creatDataLoadMore:NO];
}
- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    self.tabBarController.tabBar.hidden = NO;
    DWTabBarController *tabbarVC = (DWTabBarController *)[[UIApplication sharedApplication] keyWindow].rootViewController;
    [tabbarVC.tabBar.items[1] hidenBadge];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self sendMessageHasRead];
}
#pragma mark ---修改报警信息---
- (void)sendMessageHasRead{
    if (_dataArr.count>0) {
        NSMutableArray *idArr = [NSMutableArray arrayWithCapacity:0];
        for (AlarmModel *model in _dataArr) {
            [idArr addObject:model.smsId];
        }
        NSDictionary *pareDic = @{@"smsids":idArr};
        [[HttpRequest sharedInstance] postWithURLString:ChangeWarningMagUrl parameters:pareDic success:^(id responseObject) {
            
        } failure:^(NSError *error) {
            
        }];
    }
    
}
- (void)creatDataLoadMore:(BOOL) isLoadMore{
    if (!_tableview) {
        [self tableview];
    }else{
        [self.tableview reloadData];
    [self.tableview footerSetState:CoreFooterViewRefreshStateSuccessedResultDataShowing];
    }
    return;
    SingleUser *usermodel = [kAppdelegate getusermodel];
    NSDictionary *paraDic = @{@"account":usermodel.account,
                              @"selectDate":@"2016",
                              @"index":[NSString stringWithFormat:@"%li",(long)_pageStr],
                              @"pageSize":@"10"
                              };
    [[HttpRequest sharedInstance] postWithURLString:WarningListUrl parameters:paraDic success:^(id responseObject) {
        
        NSDictionary *Dic = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"-----%@",Dic);
        if ([Dic[@"success"] boolValue]) {
            NSArray *arr = [AlarmModel arrayOfModelsFromDictionaries:Dic[@"rows"] error:nil];;
            if (!isLoadMore) {
                [_dataArr removeAllObjects];
                
            }
            
            [_dataArr addObjectsFromArray:arr];
            NSLog(@"-----%@",_dataArr);


            

        }else{
          [SVProgressHUD showErrorWithStatus:Dic[@"msg"]];
        }
        
//        [self.tableview headerSetState:CoreHeaderViewRefreshStateSuccessedResultDataShowing];
//        [self.tableview footerSetState:CoreFooterViewRefreshStateSuccessedResultDataShowing
//         ];
        
    } failure:^(NSError *error) {
        
    }];
    [self tableview];
}
#pragma mark ---Getter---
- (UITableView *)tableview{
    
    if (!_tableview) {
        _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0,0, kScreenWidth, kScreenHeight-HYFTabBarAndBottomHeight-10)];
        [self.tableview registerNib:[UINib nibWithNibName:@"AlertTableViewCell" bundle:nil] forCellReuseIdentifier:@"AlarmCell"];
        _tableview.delegate = self;
        _tableview.dataSource = self;
        _tableview.backgroundColor = RGB(245, 245, 245);
        _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self refreshWidgetPrepare];

        [self.view addSubview:_tableview];
       

    }
    return _tableview;
}
#pragma mark  刷新控件准备
-(void)refreshWidgetPrepare{
    
//    [self.tableview headerSetState:CoreHeaderViewRefreshStateRefreshing];
    //添加顶部刷新控件
    [self.tableview addHeaderWithTarget:self action:@selector(headerRefresh)];
    
    
    //添加底部刷新
    [self.tableview addFooterWithTarget:self action:@selector(foorterRefresh)];
}



#pragma mark  顶部刷新
-(void)headerRefresh{
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableview headerSetState:CoreHeaderViewRefreshStateSuccessedResultDataShowing];
    });
    _pageStr=0;
    [self creatDataLoadMore:NO];
  
}


#pragma mark  底部刷新
-(void)foorterRefresh{
    NSLog(@"底部刷新。。。");
    _pageStr++;
    [self creatDataLoadMore:YES];
}
#pragma mark ---UItableviewDelegate---
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 20;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 20)];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AlertTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"AlarmCell"];
    if (cell == nil) {
        cell=[[[NSBundle mainBundle]loadNibNamed:@"AlertTableViewCell" owner:self options:nil] lastObject];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.BGView.layer.masksToBounds = YES;
    cell.BGView.layer.cornerRadius = 10.0f;
    cell.BGView.layer.borderWidth = 1;
    cell.BGView.layer.borderColor = RGB(235, 235, 235).CGColor;
    
    NSArray *dataArray = @[@"水能源",@"蒸汽能源",@"水能源",@"电能源",@"水能源"];
    cell.nameLB.text = [NSString stringWithFormat:@"%@发生警报",dataArray[indexPath.section]];
    cell.dateLB.text = @"2020-10-18";
    cell.titleLB.text = @"请立即赶往相应地点排查，必要时上报系统";
//    cell.numLB.text = model.numStr;
    if (indexPath.section==1||indexPath.section==3) {
        [cell.dateLB showBadge];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
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
