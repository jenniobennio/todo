//
//  EditableCell.h
//  todo
//
//  Created by Jenny Kwan on 1/25/14.
//  Copyright (c) 2014 Jenny Kwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextView *todoTextView;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
@end
