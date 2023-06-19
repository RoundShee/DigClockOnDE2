/*
    仅仅使用4个按键实现对调时的控制
    同时为了仿真实现的可能，需要添加强制复位的操作
*/

module key_control (
    input CLOCK_50,         //配合寄存器，实现按键状态锁存
    input wire[3:0] KEY,    //对应开发板Push_button，低电平为有效

    output reg add,         //上升沿有效
    output reg clr,         //高电平有效
    output reg adjust,      //高电平自主流动，低电平按键调整
    output reg[3:0] select,  //16位的选择

    output reg adjust_week, //对LCD星期的控制 高电平调整
    output reg add_week,    //LCD星期加一
    output reg bl,          //LCD背光

    output reg adjust_alarm,//闹钟调整状态
    output reg flip_state,  //闹钟开 关
    output reg select_add,  //闹钟调整 位选择
    output reg alarm_add,         //选中位加1
    output reg alarm_clr          //选中位归零
);
//状态引出
wire[1:0] state_0;
wire[1:0] state_1;
wire[1:0] state_2;
wire[1:0] state_3;
button_state button0(
    .key(KEY[0]),
    .CLOCK_50(CLOCK_50),
    .state(state_0)
);
button_state button1(
    .key(KEY[1]),
    .CLOCK_50(CLOCK_50),
    .state(state_1)
);
button_state button2(
    .key(KEY[2]),
    .CLOCK_50(CLOCK_50),
    .state(state_2)
);
button_state button3(
    .key(KEY[3]),
    .CLOCK_50(CLOCK_50),
    .state(state_3)
);
always @(posedge CLOCK_50) begin
    if(adjust&&(!adjust_week)&&(!adjust_alarm)) begin    //走时状态
        if(state_3[1]) begin
            adjust <= 0;//进入调时状态
            select <= 0;//位选择归零
        end
        else if(state_0[1]) begin
            adjust_week <= 1;//进入LCD调整状态-星期
        end
        else if(state_1[1]) begin
            adjust_alarm <= 1;//进入闹钟调整状态
        end
        else if(state_0[0]) begin
            bl <= 1;//这是短脉冲
        end
        else begin
            bl <= 0;//背光使能信号复位
            adjust <= 1;//保持
            adjust_week <= 0;
            adjust_alarm <= 0;
        end 
    end
    else if(adjust&&adjust_week&&(!adjust_alarm)) begin  //LCD调整状态
        if(state_3[0]) begin
            adjust_week <= 0;//退出LCD调整状态
        end
        else if(state_1[0]) begin
            add_week <= 1;
        end
        else begin
            adjust_week <= 1;//保持当前状态
            add_week <= 0;//add_week复位
        end
    end
    else if((adjust==0)&&(!adjust_week)&&(!adjust_alarm)) begin  //调时状态
        if(state_3[0])
            adjust <= 1;//返回走时状态
        else if(state_0[0])
            select <= select + 1;
        else if(state_2[0])
            clr <= 1;
        else if(state_1[0])
            add <= 1;
        else begin
            clr <= 0;
            add <= 0;
        end
    end
    else if(adjust&&(!adjust_week)&&(adjust_alarm)) begin   //调星期状态
        if(state_3[0]) begin
            adjust_alarm <= 0;//退出调星期状态
        end
        else if(state_0[1]) begin //长按开启/关闭闹钟
            flip_state <= 1; //短脉冲
        end
        else if(state_0[0]) begin //短按 位选择
            select_add <= 1;
        end
        else if(state_1[0]) begin
            alarm_add <= 1;
        end
        else if(state_2[0]) begin
            alarm_clr <= 1;
        end
        else begin
            flip_state <= 0;
            select_add <= 0;
            alarm_add <= 0;
            alarm_clr <= 0;
        end
    end
end

endmodule