/*
    时间流动模块，时钟和调时进行adjust选择驱动流动
    时间存储均以8421进行
    adjust为1时，为时钟驱动-----注意：逻辑上写反了
    adjust为0时，select进行选择修改，add增加，clr本位清零
    默认add,clk为按键输入，高电平有效 高电平，注意顶层连接取反 注意 注意 注意
*/

module time_float (
    input clk,add,
    input clr,
    input adjust,
    input wire[3:0] select,
    output reg[7:0] millisecond,
    output reg[6:0] second,
    output reg[6:0] minute,
    output reg[5:0] hour,
    output reg[5:0] day,
    output reg[4:0] month,
    output reg[7:0] year_l,
    output reg[7:0] year_h
);
wire[15:0] selectToOther;
MUX4_16 MUX4_16_1(
    .a(select),
    .b(selectToOther)
);
/*selectToOther的各线控制
0 毫秒低位
1 毫秒高位
2 秒低位
3 秒高位
4 分低位
5 分高位
6 时低位
7 时高位
8 日低位
9 日高位
10 月低位
11 月高位
12 年xxxO
13 年xxOx
14 年xOxx
15 年Oxxx
*/

//毫秒低位
reg millisecond_low_clkin;
reg millisecond_low_clrin;
wire millisecond_low_rco;
always @(*) begin
    if(adjust)
        begin
            millisecond_low_clkin <= clk;
            millisecond_low_clrin <= 0;
        end
    else
        begin
            millisecond_low_clkin <=add && selectToOther[0];
            millisecond_low_clrin <= clr && selectToOther[0];
        end
end
wire[3:0] millisecond_low_out;
always @(*) begin
    millisecond[3:0] <= millisecond_low_out;
end
counter10 millisecond_low(
    .clk(millisecond_low_clkin),
    .clr(millisecond_low_clrin),
    .data(millisecond_low_out),
    .rco(millisecond_low_rco)
);
//毫秒高位
reg millisecond_high_clkin;
reg millisecond_high_clrin;
wire millisecond_high_rco;
always @(*) begin
    if(adjust)
        begin
            millisecond_high_clkin <= millisecond_low_rco;
            millisecond_high_clrin <= 0;
        end
    else
        begin
            millisecond_high_clkin <= add && selectToOther[1];
            millisecond_high_clrin <= clr && selectToOther[1];
        end
end
wire[3:0] millisecond_high_out;
always @(*) begin
    millisecond[7:4] <= millisecond_high_out;
end
counter10 millisecond_high(
    .clk(millisecond_high_clkin),
    .clr(millisecond_high_clrin),
    .data(millisecond_high_out),
    .rco(millisecond_high_rco)
);

//秒低位
reg second_low_clkin;
reg second_low_clrin;
wire second_low_rco;
always @(*) begin
    if(adjust)
        begin
            second_low_clkin <= millisecond_high_rco;
            second_low_clrin <= 0;
        end
    else
        begin
            second_low_clkin <= add && selectToOther[2];
            second_low_clrin <= clr && selectToOther[2];
        end
end
wire[3:0] second_low_out;
always @(*) begin
    second[3:0] <= second_low_out;
end
counter10 second_low(
    .clk(second_low_clkin),
    .clr(second_low_clrin),
    .data(second_low_out),
    .rco(second_low_rco)
);

//秒高位-此时秒对应模6计数器，其余不变
reg second_high_clkin;
reg second_high_clrin;
wire second_high_rco;
always @(*) begin
    if(adjust)
        begin
            second_high_clkin <= second_low_rco;
            second_high_clrin <= 0;
        end
    else
        begin
            second_high_clkin <= add && selectToOther[3];
            second_high_clrin <= clr && selectToOther[3];
        end
end
wire[2:0] second_high_out;
always @(*) begin
    second[6:4] <= second_high_out;
end
counter6 second_high(
    .clk(second_high_clkin),
    .clr(second_high_clrin),
    .data(second_high_out),
    .rco(second_high_rco)
);

//分钟的高低两位与秒一致，只需修改变量名
//分钟低位
reg minute_low_clkin;
reg minute_low_clrin;
wire minute_low_rco;
always @(*) begin
    if(adjust)
        begin
            minute_low_clkin <= second_high_rco;
            minute_low_clrin <= 0;
        end
    else
        begin
            minute_low_clkin <= add && selectToOther[4];
            minute_low_clrin <= clr && selectToOther[4];
        end
end
wire[3:0] minute_low_out;
always @(*) begin
    minute[3:0] <= minute_low_out;
end
counter10 minute_low(
    .clk(minute_low_clkin),
    .clr(minute_low_clrin),
    .data(minute_low_out),
    .rco(minute_low_rco)
);

//分钟高位
reg minute_high_clkin;
reg minute_high_clrin;
wire minute_high_rco;
always @(*) begin
    if(adjust)
        begin
            minute_high_clkin <= minute_low_rco;
            minute_high_clrin <= 0;
        end
    else
        begin
            minute_high_clkin <= add && selectToOther[5];
            minute_high_clrin <= clr && selectToOther[5];
        end
end
wire[2:0] minute_high_out;
always @(*) begin
    minute[6:4] <= minute_high_out;
end
counter6 minute_high(
    .clk(minute_high_clkin),
    .clr(minute_high_clrin),
    .data(minute_high_out),
    .rco(minute_high_rco)
);

//小时处理需要注意，满23再接到分钟进位&&调时会导致本级清零进位
//低位仍用模10，高位使用模4,则高位计数器RCO另接，重新定义本级清零
//在检测23时，使用高位低位进位信号取或运算，防止高位调时出错
reg clr_24;
always @(*) begin
    if((hour > 6'b10_0010) && (hour_high_clkin || hour_low_clkin))
    begin
        clr_24 <= 1;
        hour_high_rco <= 1;
    end
    else 
    begin
        clr_24 <= 0;
        hour_high_rco <= 0;
    end
end

//小时低位
reg hour_low_clkin;
reg hour_low_clrin;
wire hour_low_rco;
always @(*) begin
    if(adjust)
        begin
            hour_low_clkin <= minute_high_rco;
            hour_low_clrin <= clr_24;            //接入重定义的清零
        end
    else
        begin
            hour_low_clkin <= add && selectToOther[6];
            hour_low_clrin <= (clr && selectToOther[6]) || clr_24;//防止调过
        end
end
wire[3:0] hour_low_out;
always @(*) begin
    hour[3:0] <= hour_low_out;
end
counter10 hour_low(
    .clk(hour_low_clkin),
    .clr(hour_low_clrin),
    .data(hour_low_out),
    .rco(hour_low_rco)
);

//小时高位
reg hour_high_clkin;
reg hour_high_clrin;
reg hour_high_rco;
always @(*) begin
    if(adjust)
        begin
            hour_high_clkin <= hour_low_rco;
            hour_high_clrin <= clr_24;           //重定义清零
        end
    else
        begin
            hour_high_clkin <= add && selectToOther[7];
            hour_high_clrin <= (clr && selectToOther[7]) || clr_24;//防止调过
        end
end
wire[1:0] hour_high_out;
always @(*) begin
    hour[5:4] <= hour_high_out;
end
counter4 hour_high(
    .clk(hour_high_clkin),
    .clr(hour_high_clrin),
    .data(hour_high_out),
    //.rco(hour_high_rco)悬空
);

//日day，和月份，年份有关
//日月不可为0，均为固定数
endmodule