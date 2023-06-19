/*
    在此模块引出 时间设置接口 状态开启关闭转换接口
                时间显示接口 蜂鸣器接口
                LED呼吸灯接口
    alarm开启关闭及调整时间的逻辑：
            均在调整下进行
*/
module Alarm(
    input CLOCK_50,
    input adjust_alarm,     //此时 高电平为调整状态 只有显示不同 其他蜂鸣器及LED均保持正常逻辑
    input flip_state,       //调整模式下的 开启关闭闹钟状态反转信号     上升沿反转
    input select_add,       //仍然是位选择 但为上升沿控制加
    input add,              //还是它
    input clr,              //
    input wire[6:0] second,
    input wire[6:0] minute,
    input wire[5:0] hour,

    output reg beep,        //有源蜂鸣器，低电平触发
    output reg[8:0] ledg,   //状态指示呼吸灯
    output reg state,       //与lcd_data_trans的通信 高电平有效
    output reg[3:0] select_one, //闪烁哪一个
    output reg[5:0] alarm_hour,
    output reg[6:0] alarm_minute
);

//==================================================================
//闹钟自身时间逻辑
//闹钟中的时间不存在计时器驱动问题，单个位调节不进位，只需要消除非法时间24h以上即可
reg[1:0] select;
always @(posedge select_add) begin
    select <= select + 1;
end
always @(*) begin
    if(!adjust_alarm) begin
        select_one <= 4'd0;
    end
    else begin
    case (select)
    2'd0 : select_one <= 4'b0001;
    2'd1 : select_one <= 4'b0010;
    2'd2 : select_one <= 4'b0100;
    2'd3 : select_one <= 4'b1000;
    endcase
    end
end

wire[5:0] alarm_hour_wire;
wire[6:0] alarm_minute_wire;
always @(*) begin
    alarm_hour      <= alarm_hour_wire;
    alarm_minute    <= alarm_minute_wire;
end
//分钟低位
counter10 alarm_minute_low(
    .clk(add&&select_one[0]),
    .clr(clk&&select_one[0]),
    .data(alarm_minute_wire[3:0])
);
//分钟高位
counter6 alarm_minute_high(
    .clk(add&&select_one[1]),
    .clr(clk&&select_one[1]),
    .data(alarm_minute_wire[6:4])
);
//24h clr_alarm24
reg clr_alarm24;
always @(*) begin
    if((hour > 6'b10_0010) && ((add&&select_one[2]) || (add&&select_one[3]))) begin
        clr_alarm24 <= 1;
    end
    else begin
        clr_alarm24 <= 0;
    end
end
//小时低位
counter10 alarm_hour_low(
    .clk(add&&select_one[2]),
    .clr(clk&&select_one[2] || clr_alarm24),
    .data(alarm_hour_wire[3:0])
);
//小时高位
counter4 alarm_hour_high(
    .clk(add&&select_one[3]),
    .clr(clk&&select_one[3] || clr_alarm24),
    .data(alarm_hour_wire[5:4])
);

//状态转换
always @(posedge flip_state) begin
    state <= ~state;
end

//================================================
//闹钟开启等待时刻 LED呼吸效果
//
wire breath;    //这里需要整体二选一输出
reg[5:0] duty;
//占空比控制
reg[25:0] count_breath;
always @(posedge CLOCK_50) begin
    count_breath <= count_breath + 1;
end
always @(*) begin
    if(count_breath[25]) begin
        duty <= 6'd64 - count_breath[24:19];//占空比减小
    end
    else 
        duty <= count_breath[24:19];//占空比增加
end
PWM alarm_wait(
    .CLOCK_50(CLOCK_50),
    .en(state),
    .duty(duty),
    .pwm_wave(breath)
);
//LED二选一状态 --可根据秒 丰富变化
always @(*) begin
    if((alarm_hour==hour)&&(alarm_minute==minute)&&state) begin
        ledg <= {8'd0, count_breath[23]};
    end
    else begin
        ledg <= {8'd0, breath};
    end
end

//==========================================
//蜂鸣器部分
always @(*) begin
    if((alarm_hour==hour)&&(alarm_minute==minute)&&state) begin
        beep <= count_breath[22]&&count_breath[24];
    end
    else begin
        beep <= 1;
    end
end

endmodule
