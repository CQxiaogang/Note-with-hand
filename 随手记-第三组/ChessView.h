//
//  ChessView.h
//  OC-黑白棋
//
//  Created by lanou3g on 16/6/13.
//  Copyright © 2016年 ezor. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum WinKind{
    BlackWin,
    WhiteWin,
    Equal,
    NoOneWinNow
}WinKind;
@interface ChessView : UIView

@property (nonatomic , assign) NSInteger blackCount;

@property (nonatomic , assign) NSInteger whiteCount;

@property (nonatomic , assign) WinKind winKind;

- (void)judgeCanChess;

- (void)getAllChess;
@end
