//
//  UITableViewCell+NMUI.m
//  Nemo
//
//  Created by Hunt on 2019/10/18.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "UITableViewCell+NMUI.h"
#import "NMBCore.h"

@implementation UITableViewCell (NMUI)

NMBFSynthesizeIdCopyProperty(nmui_setHighlightedBlock, setNmui_setHighlightedBlock)
NMBFSynthesizeIdCopyProperty(nmui_setSelectedBlock, setNmui_setSelectedBlock)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NMBFExtendImplementationOfVoidMethodWithTwoArguments([UITableViewCell class], @selector(setHighlighted:animated:), BOOL, BOOL, ^(UITableViewCell *selfObject, BOOL highlighted, BOOL animated) {
            if (selfObject.nmui_setHighlightedBlock) {
                selfObject.nmui_setHighlightedBlock(highlighted, animated);
            }
        });
        
        NMBFExtendImplementationOfVoidMethodWithTwoArguments([UITableViewCell class], @selector(setSelected:animated:), BOOL, BOOL, ^(UITableViewCell *selfObject, BOOL selected, BOOL animated) {
            if (selfObject.nmui_setSelectedBlock) {
                selfObject.nmui_setSelectedBlock(selected, animated);
            }
        });
    });
}

- (UITableView *)nmui_tableView {
    return [self valueForKey:@"tableView"];
}

static char kAssociatedObjectKey_selectedBackgroundColor;
- (void)setNmui_selectedBackgroundColor:(UIColor *)nmui_selectedBackgroundColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_selectedBackgroundColor, nmui_selectedBackgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (nmui_selectedBackgroundColor) {
        // 系统默认的 selectedBackgroundView 是 UITableViewCellSelectedBackground，无法修改自定义背景色，所以改为用普通的 UIView
        if ([NSStringFromClass(self.selectedBackgroundView.class) hasPrefix:@"UITableViewCell"]) {
            self.selectedBackgroundView = [[UIView alloc] init];
        }
        self.selectedBackgroundView.backgroundColor = nmui_selectedBackgroundColor;
    }
}

- (UIColor *)nmui_selectedBackgroundColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_selectedBackgroundColor);
}

- (UIView *)nmui_accessoryView {
    if (self.editing) {
        if (self.editingAccessoryView) {
            return self.editingAccessoryView;
        }
        return [self nmbf_valueForKey:@"_editingAccessoryView"];
    }
    if (self.accessoryView) {
        return self.accessoryView;
    }
    return [self nmbf_valueForKey:@"_accessoryView"];
}

@end

@implementation UITableViewCell (NMUI_Styled)

- (void)nmui_styledAsNMUITableViewCell {
    
    self.textLabel.font = UIFontMake(16);
    self.textLabel.backgroundColor = UIColorClear;
    UIColor *textLabelColor = self.nmui_styledTextLabelColor;
    if (textLabelColor) {
        self.textLabel.textColor = textLabelColor;
    }
    
    self.detailTextLabel.font = UIFontMake(15);
    self.detailTextLabel.backgroundColor = UIColorClear;
    UIColor *detailLabelColor = self.nmui_styledDetailTextLabelColor;
    if (detailLabelColor) {
        self.detailTextLabel.textColor = detailLabelColor;
    }
    
    UIColor *backgroundColor = self.nmui_styledBackgroundColor;
    if (backgroundColor) {
        self.backgroundColor = backgroundColor;
    }
    
    UIColor *selectedBackgroundColor = self.nmui_styledSelectedBackgroundColor;
    if (selectedBackgroundColor) {
        self.nmui_selectedBackgroundColor = selectedBackgroundColor;
    }
}

- (BOOL)_isGroupedStyle {
    return self.nmui_tableView && self.nmui_tableView.style == UITableViewStyleGrouped;
}

- (UIColor *)nmui_styledTextLabelColor {
    return self._isGroupedStyle ? TableViewGroupedCellTitleLabelColor : TableViewCellTitleLabelColor;
}

- (UIColor *)nmui_styledDetailTextLabelColor {
    return self._isGroupedStyle ? TableViewGroupedCellDetailLabelColor : TableViewCellDetailLabelColor;
}

- (UIColor *)nmui_styledBackgroundColor {
    return self._isGroupedStyle ? TableViewGroupedCellBackgroundColor : TableViewCellBackgroundColor;
}

- (UIColor *)nmui_styledSelectedBackgroundColor {
    return self._isGroupedStyle ? TableViewGroupedCellSelectedBackgroundColor : TableViewCellSelectedBackgroundColor;
}

- (UIColor *)nmui_styledWarningBackgroundColor {
    return self._isGroupedStyle ? TableViewGroupedCellWarningBackgroundColor : TableViewCellWarningBackgroundColor;
}
@end
