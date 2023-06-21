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


## lcd_data_trans说明
    实现将time_float的时间信息转化为LCD1602可识别的数据编码
    实现自定义星期的调整，且由key_control控制

## lcd_drive说明
    根据写操作时序图及命令编写刷新显示，将lcd_data_trans中的数据不断写出

* 2023/6/5 今日测试，已改诸多问题，但仍存在部分week的'y'字母显示'9'；以及time_float中月份不正常

* 本次源码修改：(2023/6/19)
    1. 增加alarm功能

    2. 重新调整adjusttime的按键功能

    3. 但仍未发现月份不正常，星期不正常的原因

    4. 其中，实际LCD1602的背光无法正常使用，使用LDER[0]进行代替

* 今日发现，月份与日的问题已解决。此外，星期问题仍未知，干脆直接删掉后面的字母。另外发现alarm调整小时不闪烁
