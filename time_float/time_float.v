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

//年4位均为十进制，且无限制4-3-2-1
reg year_4_clkin;
reg year_4_clrin;
always @(*) begin
    if(adjust)
        begin
            year_4_clkin <= year_3_rco;     //在下面year_3的实例化引出
            year_4_clrin <= 0;
        end
    else
        begin
            year_4_clkin <=add && selectToOther[15];
            year_4_clrin <= clr && selectToOther[15];
        end
end
wire[3:0] year_4_out;
always @(*) begin
    year_h[7:4] <= year_4_out;      //对应高两年的高位
end
counter10 year_4(
    .clk(year_4_clkin),
    .clr(year_4_clrin),
    .data(year_4_out),
    //.rco(year_4_rco)      无需rco，若到一万年，人类还会使用数电吗？
);

//年3 xOxx
reg year_3_clkin;
reg year_3_clrin;
always @(*) begin
    if(adjust)
        begin
            year_3_clkin <= year_2_rco;     //在下面year_2的实例化引出
            year_3_clrin <= 0;
        end
    else
        begin
            year_3_clkin <=add && selectToOther[14];
            year_3_clrin <= clr && selectToOther[14];
        end
end
wire[3:0] year_3_out;
wire year_3_rco;
always @(*) begin
    year_h[3:0] <= year_3_out;      //对应高两年的低位
end
counter10 year_3(
    .clk(year_3_clkin),
    .clr(year_3_clrin),
    .data(year_3_out),
    .rco(year_3_rco)
);

//如法炮制年2 xxOx;
reg year_2_clkin;
reg year_2_clrin;
always @(*) begin
    if(adjust)
        begin
            year_2_clkin <= year_1_rco;     //在下面year_1的实例化引出
            year_2_clrin <= 0;
        end
    else
        begin
            year_2_clkin <=add && selectToOther[13];
            year_2_clrin <= clr && selectToOther[13];
        end
end
wire[3:0] year_2_out;
wire year_2_rco;
always @(*) begin
    year_l[7:4] <= year_2_out;      //对应低两年的高位
end
counter10 year_2(
    .clk(year_2_clkin),
    .clr(year_2_clrin),
    .data(year_2_out),
    .rco(year_2_rco)
);

//过的最快的年 xxxO
reg year_1_clkin;
reg year_1_clrin;
always @(*) begin
    if(adjust)
        begin
            year_1_clkin <= month_high_rco;     //需要月进行实例化引出，而且不是计数器的rco
            year_1_clrin <= 0;
        end
    else
        begin
            year_1_clkin <=add && selectToOther[12];
            year_1_clrin <= clr && selectToOther[12];
        end
end
wire[3:0] year_1_out;
wire year_1_rco;
always @(*) begin
    year_l[3:0] <= year_1_out;      //对应低两年的高位
end
counter10 year_1(
    .clk(year_1_clkin),
    .clr(year_1_clrin),
    .data(year_1_out),
    .rco(year_1_rco)
);

//月高位只有0、1，为了便利也使用模4计数器
//月低位可以有0-9，但每次高位清零后必须使计数器变为1，重新使用一个计数器
//重新定义month_high_rco，与 清零clr_12
reg clr_12;
always @(*) begin
    if((month > 6'b01_0001) && (month_high_clkin || month_low_clkin))
    begin
        clr_12 <= 1;
        month_high_rco <= 1;
    end
    else 
    begin
        clr_12 <= 0;
        month_high_rco <= 0;
    end
end
//月高位
reg month_high_clkin;
reg month_high_clrin;
reg month_high_rco;
always @(*) begin
    if(adjust)
        begin
            month_high_clkin <= month_low_rco;
            month_high_clrin <= clr_12;           //重定义清零
        end
    else
        begin
            month_high_clkin <= add && selectToOther[11];
            month_high_clrin <= (clr && selectToOther[11]) || clr_12;//防止调过
        end
end
wire[1:0] month_high_out;       //月高位使用的模4计数器，但只需要一位即可
always @(*) begin
    month[4] <= month_high_out[0];
end
counter4 month_high(
    .clk(month_high_clkin),
    .clr(month_high_clrin),
    .data(month_high_out),
    //.rco(month_high_rco)悬空
);
//月低位
reg month_low_clkin;
reg month_low_clrin;
reg month_low_rco;
always @(*) begin
    if(adjust)
        begin
            month_low_clkin <= day_high_rco;       //同样需要处理
            month_low_clrin <= clr_12;            //接入重定义的清零
        end
    else
        begin
            month_low_clkin <= add && selectToOther[10];
            month_low_clrin <= (clr && selectToOther[10]) || clr_12;//防止调过
        end
end
//wire[3:0] month_low_out;
//always @(*) begin
//    month[3:0] <= month_low_out;
//end
/*  此处不可再使用封装的计数器
    需要在接收到clr_12信号时，若高位为1，则清零，若高位为0，则置1
    根据上面防止调过的初衷，采用异步置数的方式
counter10 month_low(
    .clk(month_low_clkin),
    .clr(month_low_clrin),
    .data(month_low_out),
    .rco(month_low_rco)
);*/
//重写月低位计数如下
always @(posedge month_low_clkin, posedge month_low_clrin) begin
    if (month_low_clrin) begin
        if(!(month_high_out[0]==0)) begin
            month[3:0] <= 4'b0000;
            month_low_rco <= 0;
            end
        else begin
                month[3:0] <= 4'b0001;
                month_low_rco <= 0;
            end
        end
    else if (month[3:0] == 4'b1001) begin
        month[3:0] <= 4'b0000;
        month_low_rco <= 1;     //低位计满，进位清零
        end
    else    begin
        month[3:0] <= month[3:0] + 1;
        month_low_rco <= 0;
    end
end

//31天 1、3、5、7、8、10、12
//30天 4、6、9、11
//2月，又与年对应，因此仅仅需要重定义一个约束条件多的clr,与rco
//由于天数的特殊性，写俩always
//第一判断处于哪一种状态
//计数
reg varDay_clr;
reg day_high_rco;
always @(*) begin
    if (((month == 5'b0_0001) || (month == 5'b0_0011) || (month == 5'b0_0101) || (month == 5'b0_0111) || (month == 5'b0_1000) || (month == 5'b1_0000) || (month == 5'b1_0010))&&(day > 6'b11_0000)) begin
        varDay_clr <= 1;
        day_high_rco <= 1;
    end
    else if(((month == 5'b0_0100)||(month == 5'b0_0110)||(month == 5'b0_1001)||(month == 5'b1_0001))&&(day > 6'b10_1001)) begin
        varDay_clr <= 1;
        day_high_rco <= 1;
    end//下面是2月润不润问题，紧跟着的是闰月判断if，整百年能整除400 或 非整百年整除4
    //BCD码不能够判断4整除，需要转二进制-[7:0]BCD转[6:0]_2
    else if((month == 5'b0_0010)&&(((year_l==8'd0)&&(year_high_BIN[1:0]==2'd0))||((!(year_l==8'd0))&&(year_low_BIN[1:0]==2'd0)))&&(day > 6'b10_1000)) begin
        varDay_clr <= 1;
        day_high_rco <= 1;
    end //仅剩唯一情况2月不润
    else if((day > 6'b10_0111)) begin
        varDay_clr <= 1;
        day_high_rco <= 1;
    end
end

//将年高低位进行转换为二进制
wire[6:0] year_high_BIN;
wire[6:0] year_low_BIN;
BCDtoBIN BCDtoBIN_high(
    .a(year_h),
    .b(year_high_BIN)
);
BCDtoBIN BCDtoBIN_low(
    .a(year_l),
    .b(year_low_BIN)
);

//天 的进位与清零已解决，且不能出现0日的情况，也需要采用 月 处理方式
//日 高位
reg day_high_clkin;
reg day_high_clrin;
always @(*) begin
    if(adjust)
        begin
            day_high_clkin <= day_low_rco;
            day_high_clrin <= varDay_clr;           //重定义的清零
        end
    else
        begin
            day_high_clkin <= add && selectToOther[9];
            day_high_clrin <= (clr && selectToOther[9]) || varDay_clr;//防止调过
        end
end
wire[1:0] day_high_out;
always @(*) begin
    day[5:4] <= day_high_out;
end
counter4 day_high(
    .clk(day_high_clkin),
    .clr(day_high_clrin),
    .data(day_high_out),
    //.rco(day_high_rco)悬空  对应上面重定义
);

//日低位 与月低位类似，防止出现0日
//day_low的控制信号
reg day_low_clkin;
reg day_low_clrin;
reg day_low_rco;
always @(*) begin
    if(adjust)
        begin
            day_low_clkin <= hour_high_rco;       //与212行代码形成闭环
            day_low_clrin <= varDay_clr;            //接入重定义的清零
        end
    else
        begin
            day_low_clkin <= add && selectToOther[8];
            day_low_clrin <= (clr && selectToOther[8]) || varDay_clr;
        end
end
//day_low循环计数
always @(posedge day_low_clkin, posedge day_low_clrin) begin
    if (day_low_clrin) begin
        if(!(day_high_out == 0)) begin
                day[3:0] <= 4'b0000;
                day_low_rco <= 0;
            end
        else begin
                day[3:0] <= 4'b0001;
                day_low_rco <= 0;
            end
        end
    else if (day[3:0] == 4'b1001) begin
        day[3:0] <= 4'b0000;
        day_low_rco <= 1;
        end
    else    begin
        day[3:0] <= day[3:0] + 1;
        day_low_rco <= 0;
    end
end
endmodule