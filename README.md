# 数电自主设计实验

* 目标：设计一个基础万年历；内部时间流动，花样显示；

## time_float说明
    time_float.v为从毫秒到年的流动，需要1ms时钟驱动，预留修改时间adjust，与选择
    counter.v为辅助time_float.v编写，其中由计数器，译码器，BCD码转BIN

## display_time说明
    display_time模块将time_float的内容以及控制情况显示出来
    adjust=0时，需要根据控制信号单位闪烁显示

## key_control说明
    配合button_state将KEY转化为长按和短按，根据按键情况进行输出

* 下一目标：调试以上模块，再利用LCD屏显示预先计算好的week情况。