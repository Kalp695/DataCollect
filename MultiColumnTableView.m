//
//  MultiColumnTableView.m
//  DataCollect
//
//  Created by liucc on 13-12-26.
//  Copyright (c) 2013年 liucc. All rights reserved.
//

#import "MultiColumnTableView.h"
#import "MultiColumnTableViewDefault.h"
#import "MultiColumnTableViewBGScrollView.h"
#import "UIView+MultiColumnTableView.h"
#import "CustomTextField.h"

#import "SearchCoreManager.h"
#import "AutoName.h"

#import "VtpViewController.h"

#define AddHeightTo(v,h) {CGRect f =v.frame;f.size.height +=h;v.frame=f;}

typedef NS_ENUM(NSUInteger, MultiColumnSortType) {
    MultiColumnSortTypeAsc ,
    MultiColumnSortTypeDesc,
    MultiColumnSortTypeNone
};


@interface MultiColumnTableView ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UITextFieldDelegate>



-(void)reset;
-(void)adjustView;
-(void)setUpTopHeaderScrollView;
-(void)accessColumnPointCollection;
-(void)buildSectionFoledStatus:(NSInteger)section;

-(CGFloat)accessContentTableViewCellWidth:(NSUInteger)column;
-(UITableViewCell *)leftHeaderTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
-(UITableViewCell *)contentTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

//method of searchCore 自动提示
@property(nonatomic,strong)NSMutableDictionary *autoNameDic;
@property(nonatomic,strong)NSMutableArray *searchByName;



@end

@implementation MultiColumnTableView{
    MultiColumnTableViewBGScrollView *topHeaderScrollView;
    MultiColumnTableViewBGScrollView *contentScrollView;
    UITableView *leftHeaderTableView;
    UITableView *contentTableView;
    UIView *vertexView;
    
    NSMutableDictionary *sectionFolderStatus;
    NSArray *columnPointCollection;
    
    NSMutableArray *leftHeaderDataArray;
    NSMutableArray *contentDataArray;
    
    NSMutableDictionary *columnTapViewDict;
    
    NSMutableDictionary *columnSortedTapFlags;
    
    BOOL responseToNumberSections;
    BOOL responseContentTableCellWidth;
    BOOL responseNumberofContentColumns;
    BOOL responseCellHeight;
    BOOL responseTopHeaderHeight;
    BOOL responseBgColorForColumn;
    BOOL responseHeaderBgColorForColumn;
    
    
    CustomTextField *bufferTextField;
    UITableView *selectTabelView;
  
}

@synthesize cellWidth,cellHeight,topHeaderHeight,leftHeaderWidth,sectionHeaderHeight,boldSeperatorLineWidth,normalSeperatorLineWidth;
@synthesize boldSeperatorLineColor,normalSeperatorLineColor;
@synthesize leftHeaderEnable;
@synthesize dataSource;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderColor=[[UIColor colorWithWhite:MultiColumnTableView_BorderColorGray alpha:1.0f]CGColor];
        self.layer.cornerRadius=MultiColumnTableView_CornerRadius;
        self.layer.borderWidth=MultiColumnTableView_BorderWidth;
        self.clipsToBounds=YES;
        self.backgroundColor=[UIColor clearColor];
        self.contentMode=UIViewContentModeRedraw;
        
        self.autoresizingMask=UIViewAutoresizingFlexibleHeight |UIViewAutoresizingFlexibleWidth;
        
        cellWidth=MultiColumnTableView_DefaultCellWidth;
        cellHeight=MultiColumnTableView_DefaultCellHeight;
        topHeaderHeight=MultiColumnTableView_DefaultTopHeaderHeight;
        leftHeaderWidth=MultiColumnTableView_DefaultLeftHeaderWidth;
        sectionHeaderHeight=MultiColumnTableView_DefaultSectionHeaderHeight;
        
        boldSeperatorLineWidth=MultiColumnTableView_DefaultBoldLineWidth;
        normalSeperatorLineWidth=MultiColumnTableView_DefaultNormalLineWidth;
        
        boldSeperatorLineColor = [UIColor colorWithWhite:MultiColumnTableView_DefaultLineGray alpha:1.0];
        normalSeperatorLineColor = [UIColor colorWithWhite:MultiColumnTableView_DefaultLineGray alpha:1.0];
        
        vertexView=[[UIView alloc]initWithFrame:CGRectZero];
        vertexView.backgroundColor=[UIColor clearColor];
        vertexView.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:vertexView];
        
        topHeaderScrollView =[[MultiColumnTableViewBGScrollView alloc]initWithFrame:CGRectZero];
        topHeaderScrollView.backgroundColor=[UIColor clearColor];
        topHeaderScrollView.parent=self;
        topHeaderScrollView.delegate=self;
        topHeaderScrollView.showsHorizontalScrollIndicator=NO;
        topHeaderScrollView.showsVerticalScrollIndicator=NO;
        topHeaderScrollView.autoresizingMask=UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:topHeaderScrollView];
        
        leftHeaderTableView=[[UITableView alloc]initWithFrame:CGRectZero];
        leftHeaderTableView.dataSource=self;
        leftHeaderTableView.delegate=self;
        leftHeaderTableView.autoresizingMask=UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleHeight;
        leftHeaderTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        leftHeaderTableView.backgroundColor=[UIColor clearColor];
        [self addSubview:leftHeaderTableView];
        
        contentScrollView = [[MultiColumnTableViewBGScrollView alloc]initWithFrame:CGRectZero];
        contentScrollView.backgroundColor=[UIColor clearColor];
        contentScrollView.parent=self;
        contentScrollView.delegate=self;
        contentScrollView.autoresizingMask=UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight;
        [self addSubview:contentScrollView];
        
        contentTableView =[[UITableView alloc]initWithFrame:contentScrollView.bounds];
        contentTableView.dataSource=self;
        contentTableView.delegate=self;
        contentTableView.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        contentTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        contentTableView.backgroundColor=[UIColor clearColor];
        [contentScrollView addSubview:contentTableView];
        
        bufferTextField=[[CustomTextField alloc]initWithFrame:CGRectZero];
        selectTabelView=[[UITableView alloc]initWithFrame:CGRectMake(self.frame.origin.x+150, self.frame.origin.y+420, 170, 230)];
        selectTabelView.dataSource=self;
        selectTabelView.delegate=self;
        selectTabelView.hidden=YES;
//        [self addSubview:selectTabelView];
        [contentScrollView addSubview:selectTabelView];
        
        
        
        self.autoNameDic=[[NSMutableDictionary alloc]init];
        self.searchByName=[[NSMutableArray alloc]init];
        NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
        self.autoNameDic=dic;
        NSMutableArray *nameIDArray=[[NSMutableArray alloc]init];
        self.searchByName=nameIDArray;
        [self addAutoName];
        
  
    }
    return self;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat superWidth=self.bounds.size.width;
    CGFloat superHeight=self.bounds.size.height;
    if (leftHeaderEnable) {
        vertexView.frame=CGRectMake(0, 0, leftHeaderWidth, topHeaderHeight);
        topHeaderScrollView.frame=CGRectMake(leftHeaderWidth+boldSeperatorLineWidth, 0, superWidth-leftHeaderWidth-boldSeperatorLineWidth, topHeaderHeight);
        leftHeaderTableView.frame=CGRectMake(0, topHeaderHeight+boldSeperatorLineWidth, leftHeaderWidth, superHeight-topHeaderHeight-boldSeperatorLineWidth);
        contentScrollView.frame=CGRectMake(leftHeaderWidth +boldSeperatorLineWidth, topHeaderHeight+boldSeperatorLineWidth, superWidth -leftHeaderWidth-boldSeperatorLineWidth, superHeight-topHeaderHeight-boldSeperatorLineWidth);
    }
    [self adjustView];
}
-(void)reloadData{
    [self reset];
    [leftHeaderTableView reloadData];
    [contentTableView reloadData];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
 */

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    [super drawRect:rect];
    
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, boldSeperatorLineWidth );
    CGContextSetAllowsAntialiasing(context, false);
    CGContextSetStrokeColorWithColor(context, [boldSeperatorLineColor CGColor]);
    
    if (leftHeaderEnable) {
        CGFloat x=leftHeaderWidth +boldSeperatorLineWidth/2.0f;
        CGContextMoveToPoint(context, x, 0.0f);
        CGContextAddLineToPoint(context, x, self.bounds.size.height);
        CGFloat y=topHeaderHeight + boldSeperatorLineWidth/2.0f;
        CGContextMoveToPoint(context, 0.0f, y);
        CGContextAddLineToPoint(context, self.bounds.size.width, y);
    }else{
        CGFloat y= topHeaderHeight +boldSeperatorLineWidth/2.0f;
        CGContextMoveToPoint(context, 0.0f, y);
        CGContextAddLineToPoint(context, self.bounds.size.width, y);
    }
    CGContextStrokePath(context);
    
}

-(void)dealloc{
    topHeaderScrollView=nil;
    contentScrollView=nil;
    leftHeaderTableView=nil;
    contentTableView=nil;
    vertexView=nil;
    columnPointCollection=nil;
}

#pragma mark -property
-(void)setDataSource:(id<MultiTableViewDataSource>)dataSource_{
    if (dataSource!=dataSource_) {
        dataSource=dataSource_;
        
        responseToNumberSections = [dataSource_ respondsToSelector:@selector(numberOfSectionsInTableView:)];
        responseContentTableCellWidth = [dataSource_ respondsToSelector:@selector(tableView:contentTableCellWidth:)];
        responseNumberofContentColumns = [dataSource_ respondsToSelector:@selector(arrayDataForTopHeaderInTableView:)];
//        responseCellHeight = [dataSource_ respondsToSelector:@selector(tableView:cellHeightInRow:InSection:)];
        responseCellHeight=[dataSource_ respondsToSelector:@selector(tableview:cellHeightInRow:InSection:)];
        responseTopHeaderHeight = [dataSource_ respondsToSelector:@selector(topHeaderHeightInTableView:)];
//        responseBgColorForColumn = [dataSource_ respondsToSelector:@selector(tableView:bgColorInSection:InRow:InColumn:)];
        responseBgColorForColumn=[dataSource_ respondsToSelector:@selector(tableView:bgColorInSection:Inrow:InColumn:)];
        responseHeaderBgColorForColumn = [dataSource_ respondsToSelector:@selector(tableView:headerBgColorInColumn:)];
        [self reset];
    }
}
-(NSMutableArray *)bufferArray{
    if (!_bufferArray) {
        _bufferArray=[[NSMutableArray alloc]initWithCapacity:11];
        for (int i=0;  i<11; i++) {
            [_bufferArray addObject:[NSNumber numberWithInt:i]];
        }
    }
    return _bufferArray;
}
-(NSMutableArray *)holderArray{
    NSUInteger VCount=[[leftHeaderDataArray objectAtIndex:0]count];
    NSUInteger Hcount=[dataSource arrayDataForTopHeaderInTableView:self].count;
    if (!_holderArray) {
        _holderArray=[[NSMutableArray alloc]init];
        for (int i=0; i<VCount;i++ ) {
            NSMutableArray *horizonArray;
            horizonArray=[[NSMutableArray alloc]init];
            for (int j=0; j<Hcount; j++) {
                NSString *holderString=@"-1";
                [horizonArray addObject:holderString];
            }
            [_holderArray addObject:horizonArray];
        }
    }
    return _holderArray;
}


#pragma mark -UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView==selectTabelView) {
        UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
        bufferTextField.text=cell.textLabel.text;
    }else{
        UITableView *target=nil;
        if (tableView==leftHeaderTableView) {
            target=contentTableView;
        }else if (tableView==contentTableView){
            target=leftHeaderTableView;
        }else{
            target=nil;
        }
        [target selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }

}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, [tableView rectForHeaderInSection:section].size.height)];
    if (tableView ==leftHeaderTableView) {
        UITapGestureRecognizer *leftRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(leftHeaderTap:)];
        view.backgroundColor=[UIColor yellowColor];
        view.tag=section;
        [view addGestureRecognizer:leftRecognizer];
    }else{
        NSUInteger count=[dataSource arrayDataForTopHeaderInTableView:self].count;
        for (int i=0; i<count; i++) {
            CGFloat cellW=[self accessContentTableViewCellWidth:i];
            CGFloat cellH=[tableView rectForHeaderInSection:section].size.height;
            
            CGFloat width=[[columnPointCollection objectAtIndex:i]floatValue];
            
            UIView *subView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, cellW, cellH)];
            subView.center=CGPointMake(width, cellH/2.0f);
            subView.clipsToBounds=YES;
            if (i==1) {
                subView.backgroundColor=[UIColor clearColor];
            }else{
                subView.backgroundColor=[UIColor clearColor];
            }
            
            NSString *tagStr=[NSString stringWithFormat:@"%d_%d",section,i];
            subView.tag=(int)tagStr;
            
            NSString *columnStr=[NSString stringWithFormat:@"%d_%d",section,i];
            [columnTapViewDict setObject:subView forKey:columnStr];
            
            if ([columnSortedTapFlags objectForKey:columnStr]==nil) {
                [columnSortedTapFlags setObject:[NSNumber numberWithInt:MultiColumnSortTypeNone] forKey:columnStr ];
            }
            
            UITapGestureRecognizer *contentHeaderRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(contentHeaderTap:)];
            
            [subView addGestureRecognizer:contentHeaderRecognizer];
            [view addSubview:subView];
        }
    }
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (tableView==selectTabelView) {
        return 0;
    }else{
//        return 20.0f;
        return 0.0;
        
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView==selectTabelView) {
        return 44.0f;
    }else{
    return [self cellHeightInIndex:indexPath];
    }
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView==selectTabelView) {
        if ([bufferTextField.text length]<=0) {
            return [self.autoNameDic count];
        }else{
            return [self.searchByName count];
        }
    }
    else{
        
        NSUInteger rows=0;
        if (![self foldedInSection:section]) {
            rows=[self rowsInSection:section];
        }
        return rows;
    }
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self numberOfSections];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView==leftHeaderTableView) {
        return [self leftHeaderTableView:tableView cellForRowAtIndexPath:indexPath];
    }else if(tableView==contentTableView){
        return [self contentTableView:tableView cellForRowAtIndexPath:indexPath];
    }else{
        static NSString *identifier=@"cell";
        UITableViewCell *cell=(UITableViewCell *)[selectTabelView dequeueReusableCellWithIdentifier:identifier];
        if (cell==nil) {
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
            cell.selectionStyle=UITableViewCellSelectionStyleBlue;
        }
//        NSString *test=[NSString stringWithFormat:@"test%d",indexPath.row];
//        cell.textLabel.text=test;
        
        if ([bufferTextField.text length] <= 0) {
            AutoName *contact = [[self.autoNameDic allValues] objectAtIndex:indexPath.row];
            cell.textLabel.text = contact.name;
            cell.detailTextLabel.text = @"";
            return cell;
        }
        
        NSNumber *localID = nil;
        NSMutableString *matchString = [NSMutableString string];
        NSMutableArray *matchPos = [NSMutableArray array];
        if (indexPath.row < [_searchByName count]) {
            localID = [self.searchByName objectAtIndex:indexPath.row];
            
            //姓名匹配 获取对应匹配的拼音串 及高亮位置
            if ([bufferTextField.text length]) {
                [[SearchCoreManager share] GetPinYin:localID pinYin:matchString matchPos:matchPos];
            }
        } else {
//            localID = [self.searchByPhone objectAtIndex:indexPath.row-[searchByName count]];
//            NSMutableArray *matchPhones = [NSMutableArray array];
//            
//            //号码匹配 获取对应匹配的号码串 及高亮位置
//            if ([self.searchBar.text length]) {
//                [[SearchCoreManager share] GetPhoneNum:localID phone:matchPhones matchPos:matchPos];
//                [matchString appendString:[matchPhones objectAtIndex:0]];
//            }
        }
        AutoName *contact = [self.autoNameDic objectForKey:localID];
        
        cell.textLabel.text = contact.name;
        cell.detailTextLabel.text = matchString;
        
        
        return cell;
    }
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    UIScrollView *target=nil;
    if (scrollView == leftHeaderTableView) {
        target=contentTableView;
    }else if (scrollView==contentTableView){
        target=leftHeaderTableView;
    }else if (scrollView == contentScrollView){
        target=topHeaderScrollView;
    }else if (scrollView==topHeaderScrollView){
        target=contentScrollView;
    }
    target.contentOffset =scrollView.contentOffset;
}

#pragma mark - private method
-(void)reset{
    columnTapViewDict =[NSMutableDictionary dictionary];
    columnSortedTapFlags=[NSMutableDictionary dictionary];
    
    [self accessDataSourceData];
    
    vertexView.backgroundColor= [self headerBgColorColumn:-1];
    [self accessColumnPointCollection];
    [self buildSectionFoledStatus:-1];
    [self setUpTopHeaderScrollView];
    [contentScrollView reDraw];
}

-(void)adjustView{
    CGFloat width=0.0f;
    NSUInteger count=[dataSource arrayDataForTopHeaderInTableView:self].count;
    for (int i=1 ; i<count+1; i++) {
        if (i==count +1) {
            width +=normalSeperatorLineWidth;
        }else{
            width +=normalSeperatorLineWidth +[self accessContentTableViewCellWidth:i-1];

        }
    }
    topHeaderScrollView.contentSize=CGSizeMake(width, topHeaderHeight);
    contentScrollView.contentSize=CGSizeMake(width, self.bounds.size.height-topHeaderHeight-boldSeperatorLineWidth);
    contentTableView.frame=CGRectMake(0.0f, 0.0f, width, self.bounds.size.height-topHeaderHeight-boldSeperatorLineWidth);
}

- (void)buildSectionFoledStatus:(NSInteger)section {
    if (sectionFolderStatus == nil) sectionFolderStatus = [NSMutableDictionary dictionary];
    
    NSUInteger sections = [self numberOfSections];
    for (int i = 0; i < sections; i++) {
        if (section == -1) {
            [sectionFolderStatus setObject:[NSNumber numberWithBool:NO] forKey:[self sectionToString:i]];
        }else if (i == section) {
            if ([self foldedInSection:section]) {
                [sectionFolderStatus setObject:[NSNumber numberWithBool:NO] forKey:[self sectionToString:section]];
            }else {
                [sectionFolderStatus setObject:[NSNumber numberWithBool:YES] forKey:[self sectionToString:section]];
            }
            break;
        }
    }
}

-(void)setUpTopHeaderScrollView{
    NSUInteger count = [dataSource arrayDataForTopHeaderInTableView:self].count;
    for (int i = 0; i < count; i++) {
        
        CGFloat topHeaderW = [self accessContentTableViewCellWidth:i];
        CGFloat topHeaderH = [self accessTopHeaderHeight];
        
        CGFloat widthP = [[columnPointCollection objectAtIndex:i] floatValue];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, topHeaderW, topHeaderH)];
        view.clipsToBounds = YES;
        view.center = CGPointMake(widthP, topHeaderH / 2.0f);
        view.tag = i;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.text = [[dataSource arrayDataForTopHeaderInTableView:self] objectAtIndex:i];
        
        [label sizeToFit];
        label.center = CGPointMake(topHeaderW / 2.0f, topHeaderH / 2.0f);
        
        UIColor *color = [self headerBgColorColumn:i];
        view.backgroundColor = color;
        label.backgroundColor = color;
        
        [view addSubview:label];
        
        
        UITapGestureRecognizer *topHeaderGecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentHeaderTap:)];
        
        [view addGestureRecognizer:topHeaderGecognizer];
        
        NSString *columnStr = [NSString stringWithFormat:@"-1_%d", i];
        [columnTapViewDict setObject:view forKey:columnStr];
        
        if ([columnSortedTapFlags objectForKey:columnStr] == nil) {
            [columnSortedTapFlags setObject:[NSNumber numberWithInt:MultiColumnSortTypeNone] forKey:columnStr];
        }
        
        [topHeaderScrollView addSubview:view];
    }
    
    [topHeaderScrollView reDraw];

    
}
- (void)accessColumnPointCollection {
    NSUInteger columns = responseNumberofContentColumns ? [dataSource arrayDataForTopHeaderInTableView:self].count : 0;
    if (columns == 0) @throw [NSException exceptionWithName:nil reason:@"number of content columns must more than 0" userInfo:nil];
    NSMutableArray *tmpAry = [NSMutableArray array];
    CGFloat widthColumn = 0.0f;
    CGFloat widthP = 0.0f;
    for (int i = 0; i < columns; i++) {
        CGFloat columnWidth = [self accessContentTableViewCellWidth:i];
        widthColumn += (normalSeperatorLineWidth + columnWidth);
        widthP = widthColumn - columnWidth / 2.0f;
        [tmpAry addObject:[NSNumber numberWithFloat:widthP]];
    }
    columnPointCollection = [tmpAry copy];
}

- (CGFloat)accessContentTableViewCellWidth:(NSUInteger)column {
    return responseContentTableCellWidth ? [dataSource tableView:self contentTableCellWidth:column] : cellWidth;
}
-(UITableViewCell *)leftHeaderTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *inde = @"leftHeaderTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:inde];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:inde];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell addBottomLineWithWidth:normalSeperatorLineWidth bgColor:normalSeperatorLineColor];
    }
    
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat cellH = [self cellHeightInIndex:indexPath];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, leftHeaderWidth, cellH)];
    view.clipsToBounds = YES;
    
    UILabel *label =  [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = [[leftHeaderDataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [label sizeToFit];
    label.center = CGPointMake(leftHeaderWidth / 2.0f, cellH / 2.0f);
    
    UIColor *color = [self bgColorInSection:indexPath.section InRow:indexPath.row InColumn:-1];
    view.backgroundColor = color;
    label.backgroundColor = color;
    
    [view addSubview:label];
    
    [cell.contentView addSubview:view];
    
    AddHeightTo(cell, normalSeperatorLineWidth);
    
    return cell;

}

- (UITableViewCell *)contentTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger count = [dataSource arrayDataForTopHeaderInTableView:self].count;
    static NSString *cellID = @"contentTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell addBottomLineWithWidth:normalSeperatorLineWidth bgColor:normalSeperatorLineColor];
    }
    
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
//    NSMutableArray *ary = [[contentDataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    NSLog(@"row=%d这是一个ary%@\n",indexPath.row,ary);
    
    for (int i = 0; i < count; i++) {
        
        CGFloat cellW = [self accessContentTableViewCellWidth:i];
        CGFloat cellH = [self cellHeightInIndex:indexPath];
        
        CGFloat width = [[columnPointCollection objectAtIndex:i] floatValue];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cellW, cellH)];
        view.center = CGPointMake(width, cellH / 2.0f);
        view.clipsToBounds = YES;
        
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
//        label.text = [NSString stringWithFormat:@"%@", [ary objectAtIndex:i]];
//        [label sizeToFit];
//        label.center = CGPointMake(cellW / 2.0f, cellH / 2.0f);
        UIColor *color = [self bgColorInSection:indexPath.section InRow:indexPath.row InColumn:i];
        
        view.backgroundColor = color;
//        label.backgroundColor = color;
        
        CustomTextField *textField=[[CustomTextField alloc]initWithFrame:CGRectZero];
        textField.inputType=InputTypeByString;
        textField.idenHorizon=i;
        [self setTextFiledType:textField idenHorizon:i];
        textField.idenVertical=indexPath.row;
        
        textField.indexPath=indexPath;
        
        [textField sizeToFit];
        textField.placeholder=@"place holder";
        if (![[[self.holderArray objectAtIndex:indexPath.row]objectAtIndex:i]isEqualToString:@"-1"]) {
            textField.text=[[self.holderArray objectAtIndex:indexPath.row]objectAtIndex:i];
        }
        textField.center=CGPointMake(cellW/2.0f, cellH/2.0f);
        CGRect frame=textField.frame;
        frame.size.width+=150;
        textField.frame=frame;
        textField.delegate=self;
        textField.userInteractionEnabled=YES;
        [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        
        
        
//        [view addSubview:label];
        [view addSubview:textField];
        
        [cell.contentView addSubview:view];
    }
    
    AddHeightTo(cell, normalSeperatorLineWidth);
    
    return cell;
}
-(void)setTextFiledType:(CustomTextField *)textField idenHorizon:(int)i{
    NSMutableArray *headArray=[@[]mutableCopy];
    if (self.gridType==GridTypeOfPlant) {
        NSMutableArray *templateArray=[[GetTemplateInfo templateAccess]getTemInfoFromTp];
        for (TemplateInfo *data in templateArray) {
            if (data.ifDisplay) {
                [headArray addObject:data];
            }
        }
        TemplateInfo *data=[headArray objectAtIndex:i];
        if ([data.attribute isEqualToString:@"float"]||[data.attribute isEqualToString:@"int"]) {
            textField.keyboardType=UIKeyboardTypeNumberPad;
        }
    }else{
        
        
        NSMutableArray *templateArray=[[GetTemplateInfo templateAccess]getAnidTemInfoFromTp];
        for (TemplateInfo *data in templateArray) {
            if (data.ifDisplay) {
                [headArray addObject:data];
            }
        }
        TemplateInfo *data=[headArray objectAtIndex:i];
        if ([data.attribute isEqualToString:@"float"]||[data.attribute isEqualToString:@"int"]) {
            textField.keyboardType=UIKeyboardTypeNumberPad;
        }
    }
}




#pragma mark - GestureRecognizer
-(void)leftHeaderTap:(UITapGestureRecognizer *)recognizer{
    @synchronized(self) {
        NSUInteger section = recognizer.view.tag;
        [self buildSectionFoledStatus:section];
        
        [leftHeaderTableView beginUpdates];
        [contentTableView beginUpdates];
        
        NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:10];
        for (int i = 0; i < [self rowsInSection:section]; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:section]];
        }
        
        if ([self foldedInSection:section]) {
            [leftHeaderTableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
            [contentTableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        }else {
            [leftHeaderTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
            [contentTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        }
        
        [leftHeaderTableView endUpdates];
        [contentTableView endUpdates];
    }
    
}
-(void)contentHeaderTap:(UIGestureRecognizer *)recognizer{
    UIView *view = recognizer.view;
    
    NSIndexPath *indexPath = [self accessUIViewVirtualTag:view];
    
    NSUInteger length = [indexPath length];
    
    if (length != 2) return;
    
    NSInteger section = indexPath.section;
    NSInteger column = indexPath.row;
    
    NSString *columnStr = [NSString stringWithFormat:@"%d_%d", section, column];
    
    NSInteger columnFlag = [[columnSortedTapFlags objectForKey:columnStr] integerValue];
    
    if (section == -1) {
        NSUInteger rows = [self numberOfSections];
        
        MultiColumnSortType newType = MultiColumnSortTypeNone;
        
        if (columnFlag == MultiColumnSortTypeNone || columnFlag == MultiColumnSortTypeDesc) {
            newType = MultiColumnSortTypeAsc;
        }else {
            newType = MultiColumnSortTypeDesc;
        }
        
        for (int i = 0; i < rows; i++) {
            NSIndexPath *iPath = [NSIndexPath indexPathForRow:column inSection:i];
            
            NSString *str = [NSString stringWithFormat:@"%d_%d", iPath.section, iPath.row];
            [columnSortedTapFlags setObject:[NSNumber numberWithInt:columnFlag] forKey:str];
            
            [self singleHeaderClick:iPath];
        }
        [columnSortedTapFlags setObject:[NSNumber numberWithInt:newType] forKey:columnStr];
        
    }else {
        [self singleHeaderClick:indexPath];
    }
    
    
    [leftHeaderTableView reloadData];
    [contentTableView reloadData];

    
}
- (void)singleHeaderClick:(NSIndexPath *)indexPath {
    
    NSInteger section = indexPath.section;
    NSInteger column = indexPath.row;
    
    NSString *columnStr = [NSString stringWithFormat:@"%d_%d", section, column];
    NSInteger columnFlag = [[columnSortedTapFlags objectForKey:columnStr] integerValue];
    
    NSArray *leftHeaderDataInSection = [leftHeaderDataArray objectAtIndex:section];
    NSArray *contentDataInSection = [contentDataArray objectAtIndex:section];
    
    NSArray *sortContentData = [contentDataInSection sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        NSComparisonResult result =  [[obj1 objectAtIndex:column] compare:[obj2 objectAtIndex:column]];
        
        return result;
    }];
    
    NSMutableArray *sortIndexAry = [NSMutableArray array];
    for (int i = 0; i < sortContentData.count; i++) {
        id objI = [sortContentData objectAtIndex:i];
        for (int j = 0; j < contentDataInSection.count; j++) {
            id objJ = [contentDataInSection objectAtIndex:j];
            if (objI == objJ) {
                [sortIndexAry addObject:[NSNumber numberWithInt:j]];
                break;
            }
        }
    }
    
    NSMutableArray *sortLeftHeaderData = [NSMutableArray array];
    for (id index in sortIndexAry) {
        int i = [index intValue];
        [sortLeftHeaderData addObject:[leftHeaderDataInSection objectAtIndex:i]];
    }
    
    if (columnFlag == MultiColumnSortTypeNone || columnFlag == MultiColumnSortTypeDesc) {
        columnFlag = MultiColumnSortTypeAsc;
    }else {
        columnFlag = MultiColumnSortTypeDesc;
        NSEnumerator *leftReverseEnumerator = [sortLeftHeaderData reverseObjectEnumerator];
        NSEnumerator *contentReverseEvumerator = [sortContentData reverseObjectEnumerator];
        sortLeftHeaderData = [NSMutableArray arrayWithArray:[leftReverseEnumerator allObjects]];
        sortContentData = [NSArray arrayWithArray:[contentReverseEvumerator allObjects]];
    }
    
    [leftHeaderDataArray replaceObjectAtIndex:section withObject:sortLeftHeaderData];
    [contentDataArray replaceObjectAtIndex:section withObject:sortContentData];
    
    [columnSortedTapFlags setObject:[NSNumber numberWithInt:columnFlag] forKey:columnStr];
    
}


#pragma mark - other method
-(NSUInteger)rowsInSection:(NSUInteger)section{
    return [[leftHeaderDataArray objectAtIndex:section]count];
}

-(NSUInteger)numberOfSections{
    NSUInteger sections=responseToNumberSections ? [dataSource numberOfSectionsInTableView:self]:1;
    return sections<1? 1:sections;
}

-(NSString *)sectionToString:(NSUInteger)section{
    return [NSString stringWithFormat:@"%d",section];
}

-(BOOL)foldedInSection:(NSUInteger)section{
    return [[sectionFolderStatus objectForKey:[self sectionToString:section]]boolValue];
}
-(CGFloat)cellHeightInIndex:(NSIndexPath *)indexPath{
    return responseCellHeight ? [dataSource tableview:self cellHeightInRow:indexPath.row InSection:indexPath.section] : cellHeight;
}
-(CGFloat)accessTopHeaderHeight{
    return responseTopHeaderHeight ? [dataSource topHeaderHeightInTableView:self] : topHeaderHeight;
}
-(UIColor *)bgColorInSection:(NSUInteger)section InRow:(NSUInteger)row InColumn:(NSUInteger)column{
    return responseBgColorForColumn ? [dataSource tableView:self bgColorInSection:section Inrow:row
                                                   InColumn:column] : [UIColor clearColor];
}

- (UIColor *)headerBgColorColumn:(NSUInteger)column {
    return responseHeaderBgColorForColumn ? [dataSource tableView:self headerBgColorInColumn:column] : [UIColor clearColor];
}
-(void)accessDataSourceData{
    leftHeaderDataArray=[NSMutableArray array];
    contentDataArray =[NSMutableArray array];
    NSUInteger sections=[dataSource numberOfSectionsInTableView:self];
    for (int i=0; i<sections; i++) {
        [leftHeaderDataArray addObject:[dataSource arrayDataForLeftHeaderInTableView:self InSection:i]];
        [contentDataArray addObject:[dataSource arrayDataForContentInTableView:self InSection:i]];
    }
}
-(NSIndexPath *)accessUIViewVirtualTag:(UIView *)view{
    for (NSString *key in [columnTapViewDict allKeys]) {
        UIView *vi=[columnTapViewDict objectForKey:key];
        if (vi==view) {
            NSArray *sep=[key componentsSeparatedByString:@"_"];
            NSUInteger section=[[sep objectAtIndex:0]integerValue];
            NSUInteger row= [[sep objectAtIndex:1]integerValue];
            return [NSIndexPath indexPathForRow:row inSection:section];
        }
    }
    return nil;
}



#pragma mark - UITextfieldDelegate



-(void)textFieldDidEndEditing:(CustomTextField *)textField{
    
    textField=(CustomTextField *)textField;
    NSInteger i=textField.idenVertical;
    NSInteger j=textField.idenHorizon;
    [[self.holderArray objectAtIndex:i]replaceObjectAtIndex:j withObject:textField.text];
    [self hideSelectTable];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidChange:(id)sender{
    CustomTextField *textField=(CustomTextField *)sender;
    NSLog(@"%@\n",textField.text);
    
    [[SearchCoreManager share] Search:textField.text searchArray:nil nameMatch:self.searchByName phoneMatch:nil];
    
    [selectTabelView reloadData];

    
}
-(void)textFieldDidBeginEditing:(CustomTextField *)textField{
    bufferTextField=textField;
    
    if (textField.idenHorizon==0) {
        [self updateSelectTable:textField];
        [self showSelectTable];
    }
    
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    VtpViewController *vtp=(VtpViewController *)self.dataSource;
    if (vtp.isUploaded) {
        return NO;
    }
    return YES;
    
}



-(void)showSelectTable{
    selectTabelView.hidden=NO;
    
}
-(void)hideSelectTable{
    selectTabelView.hidden=YES;
}

-(void)updateSelectTable:(CustomTextField *)textField{
    UITableViewCell *cell=[contentTableView cellForRowAtIndexPath:textField.indexPath];
    CGRect frame4=cell.frame;
    frame4.size.height=230;
    frame4.size.width=170;
    frame4.origin.x=textField.idenHorizon*170+35;
    frame4.origin.y +=54;
    [selectTabelView setFrame:frame4];
    [selectTabelView reloadData];
}

#pragma mark -AUTOCOMPLETE NAME
-(void)addAutoName{
    NSString *filePath;
    switch (self.gridType) {
        case GridTypeOfPlant:
             filePath=[[NSBundle mainBundle]pathForResource:@"plantName" ofType:@"txt"];

            break;
        case GridTypeOfAnimal:
             filePath=[[NSBundle mainBundle]pathForResource:@"animalName" ofType:@"txt"];
            break;
        default:
            break;
    }
    NSString *nameSource=[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSArray *nameSourceArray=[nameSource componentsSeparatedByString:@"\n"];
    NSMutableArray *animalNameArray=[[NSMutableArray alloc]init];
    for (NSString *line in nameSourceArray) {
        NSArray *lineStringArray=[line componentsSeparatedByString:@"\t"];
        NSString *singleName=[lineStringArray firstObject];
        [animalNameArray addObject:singleName];
    }
    
    for (int i=0; i<animalNameArray.count; i++) {
        AutoName *autoName=[[AutoName alloc]init];
        autoName.localID=[NSNumber numberWithInt:i];
        autoName.name=[animalNameArray objectAtIndex:i];
        [[SearchCoreManager share]AddContact:autoName.localID name:autoName.name phone:autoName.phoneArray];
        [self.autoNameDic setObject:autoName forKey:autoName.localID ];
    }
}






@end
