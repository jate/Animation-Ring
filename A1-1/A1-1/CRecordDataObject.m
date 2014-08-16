//
//  CRecordDataObject.m
//  A1-1
//
//  Created by JateXu on 8/13/14.
//  Copyright (c) 2014 JateXu. All rights reserved.
//

#import "CRecordDataObject.h"

#define CELL_IDENTIFIER         @"cellIdentifier"

@implementation CRecordDataObject





#pragma mark - TableView DataSource Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 12;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
    
    cell.textLabel.text = [NSString stringWithFormat:@"第 %d 条数据。", indexPath.row + 1];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"第 %d 条数据细节内容。", indexPath.row + 1];
    
    return cell;
}
   

@end
