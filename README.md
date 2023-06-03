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

* 完成LCD1602的理论开发，准备调试

## lcd_data_trans说明
    实现将time_float的时间信息转化为LCD1602可识别的数据编码
    实现自定义星期的调整，且由key_control控制

## lcd_drive说明
    根据写操作时序图及命令编写刷新显示，将lcd_data_trans中的数据不断写出