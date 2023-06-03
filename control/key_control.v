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
    output reg bl           //LCD背光
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
    if(adjust&&(!adjust_week)) begin    //走时状态
        if(state_3[1]) begin
            adjust <= 0;//进入调时状态
            select <= 0;//位选择归零
        end

        //*****这一小部分为LCD方面******
        else if(state_0[1]) begin
            adjust_week <= 1;//进入LCD调整状态
        end
        else if(state_0[0]) begin
            bl <= 1;//这是短脉冲
        end
        else bl <= 0;//背光使能信号复位
        //*****************************
    end
    else if(adjust&&adjust_week) begin  //LCD调整状态
        if(state_0[0]) begin
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
    else begin  //调时状态
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
end

endmodule