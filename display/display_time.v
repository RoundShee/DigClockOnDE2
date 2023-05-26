/*本模块是 time_float 显示模块


*/
module display_time (
    input CLOCK_50,     //用于计时分别使能两个显示状态切换 年月日 时分秒毫
    input adjust,       //用于判断是否为显示状态还是调时状态
    input wire[3:0] select,       //判断调时状态闪烁哪一位
    //将寄存器全部接收用于显示
    input wire[7:0] millisecond,
    input wire[6:0] second,
    input wire[6:0] minute,
    input wire[5:0] hour,
    input wire[5:0] day,
    input wire[4:0] month,
    input wire[7:0] year_l,
    input wire[7:0] year_h,
    //数码管共阳极
    output reg[6:0] HEX0,
    output reg[6:0] HEX1,
    output reg[6:0] HEX2,
    output reg[6:0] HEX3,
    output reg[6:0] HEX4,
    output reg[6:0] HEX5,
    output reg[6:0] HEX6,
    output reg[6:0] HEX7,
    //长亮对应走时状态，闪烁则调整
    output reg[1:0] LEDR
);
//t代表temp，中间存储
reg[3:0]        ms_tlow;
reg[3:0]        ms_thigh;
reg[3:0]        s_tlow;
reg[3:0]        s_thigh;
reg[3:0]        min_tlow;
reg[3:0]        min_thigh;
reg[3:0]        h_tlow;
reg[3:0]        h_thigh;
reg[7:0]       en;
//数码管接入
//定义中间线
wire[6:0] HEX0_wire;
wire[6:0] HEX1_wire;
wire[6:0] HEX2_wire;
wire[6:0] HEX3_wire;
wire[6:0] HEX4_wire;
wire[6:0] HEX5_wire;
wire[6:0] HEX6_wire;
wire[6:0] HEX7_wire;
always @(*) begin
    HEX0 <= HEX0_wire;
    HEX1 <= HEX1_wire;
    HEX2 <= HEX2_wire;
    HEX3 <= HEX3_wire;
    HEX4 <= HEX4_wire;
    HEX5 <= HEX5_wire;
    HEX6 <= HEX6_wire;
    HEX7 <= HEX7_wire;
end
//HEX0 对应年个位 或 毫秒 个位
HEX_drive to_HEX0(
    .en(en[0]),
    .a(ms_tlow),
    .b(HEX0_wire)
);
//HEX1 对应年的xxOx 或 0.1s
HEX_drive to_HEX1(
    .en(en[1]),
    .a(ms_thigh),
    .b(HEX1_wire)
);
//HEX2 对应年的xOxx 或1s
HEX_drive to_HEX2(
    .en(en[2]),
    .a(s_tlow),
    .b(HEX2_wire)
);
//HEX3 对应年的最高位Oxxx 或 10s
HEX_drive to_HEX3(
    .en(en[3]),
    .a(s_thigh),
    .b(HEX3_wire)
);
//HEX4 对应 日的低位 或 分钟低位
HEX_drive to_HEX4(
    .en(en[4]),
    .a(min_tlow),
    .b(HEX4_wire)
);
//HEX5 对应 日的高位 或 分钟高位
HEX_drive to_HEX5(
    .en(en[5]),
    .a(min_thigh),
    .b(HEX5_wire)
);
//HEX6对应 月的低位 或 小时低位
HEX_drive to_HEX6(
    .en(en[6]),
    .a(h_tlow),
    .b(HEX6_wire)
);
//HEX7对应 月的高位 或 小时高位
HEX_drive to_HEX7(
    .en(en[7]),
    .a(h_thigh),
    .b(HEX7_wire)
);

//4秒计时器 可以使用count_t4[24]来进行近似半秒闪烁 若实际观察不到改25
reg[27:0] count_t4;
always @(posedge CLOCK_50) begin
    if(count_t4 > 28'd200_000000)
        count_t4 <= 0;
    else count_t4 <= count_t4 + 1;
end
//为了进行调时下的闪烁。需要知道哪一个被调，按位与输出变闪烁
wire[15:0] selectToOther2;
MUX4_16 MUX4_16_2(
    .a(select),
    .b(selectToOther2)
);


always @(CLOCK_50) begin    //使用CLOCK_50不断进行刷新判断
    if(adjust) begin
        en <= 8'b1111_1111;
        if(count_t4 > 28'd100_000000) begin  //月日-年显示
            LEDR <= 2'b10;
            ms_tlow     <= year_l[3:0];
            ms_thigh    <= year_l[7:4];
            s_tlow      <= year_h[3:0];
            s_thigh     <= year_h[7:4];
            min_tlow    <= day[3:0];
            min_thigh   <= {1'b0,1'b0,day[5:4]};
            h_tlow      <= month[3:0];
            h_thigh     <= {1'b0,1'b0,1'b0,month[4]};
        end
        else begin          //时分秒毫显示
            LEDR <= 2'b01;
            ms_tlow     <= millisecond[3:0];
            ms_thigh    <= millisecond[7:4];
            s_tlow      <= second[3:0];
            s_thigh     <= {1'b0, second[6:4]};
            min_tlow    <= minute[3:0];
            min_thigh   <= {1'b0, minute[6:4]};
            h_tlow      <= hour[3:0];
            h_thigh     <= {1'b0,1'b0,hour[5:4]};
        end
    end
    else    begin
         if(select > 4'd7) begin  //对应月日-年区域 但被select选中需要闪烁
            LEDR <= {count_t4[24],1'b0};
            ms_tlow     <= year_l[3:0];
            ms_thigh    <= year_l[7:4];
            s_tlow      <= year_h[3:0];
            s_thigh     <= year_h[7:4];
            min_tlow    <= day[3:0];
            min_thigh   <= {1'b0,1'b0,day[5:4]};
            h_tlow      <= month[3:0];
            h_thigh     <= {1'b0,1'b0,1'b0,month[4]};
            en[0] <= (!selectToOther2[12] || (selectToOther2[12] && count_t4[24]));
            en[1] <= (!selectToOther2[13] || (selectToOther2[13] && count_t4[24]));
            en[2] <= (!selectToOther2[14] || (selectToOther2[14] && count_t4[24]));
            en[3] <= (!selectToOther2[15] || (selectToOther2[15] && count_t4[24]));
            en[4] <= (!selectToOther2[8] || (selectToOther2[8] && count_t4[24]));
            en[5] <= (!selectToOther2[9] || (selectToOther2[9] && count_t4[24]));
            en[6] <= (!selectToOther2[10] || (selectToOther2[10] && count_t4[24]));
            en[7] <= (!selectToOther2[11] || (selectToOther2[11] && count_t4[24]));
        end
    else begin              //显示时分秒毫的调时
            LEDR <= {1'b0,count_t4[24]};
            ms_tlow     <= millisecond[3:0];
            ms_thigh    <= millisecond[7:4];
            s_tlow      <= second[3:0];
            s_thigh     <= {1'b0, second[6:4]};
            min_tlow    <= minute[3:0];
            min_thigh   <= {1'b0, minute[6:4]};
            h_tlow      <= hour[3:0];
            h_thigh     <= {1'b0,1'b0,hour[5:4]};
            en[0] <= (!selectToOther2[0] || (selectToOther2[0] && count_t4[24]));
            en[1] <= (!selectToOther2[1] || (selectToOther2[1] && count_t4[24]));
            en[2] <= (!selectToOther2[2] || (selectToOther2[2] && count_t4[24]));
            en[3] <= (!selectToOther2[3] || (selectToOther2[3] && count_t4[24]));
            en[4] <= (!selectToOther2[4] || (selectToOther2[4] && count_t4[24]));
            en[5] <= (!selectToOther2[5] || (selectToOther2[5] && count_t4[24]));
            en[6] <= (!selectToOther2[6] || (selectToOther2[6] && count_t4[24]));
            en[7] <= (!selectToOther2[7] || (selectToOther2[7] && count_t4[24]));
        end
    end
end


    
endmodule

//共阳极驱动数码管模块
//则输出低电平为亮，高电平为灭
module HEX_drive (
    input en,
    input wire[3:0] a,
    output reg[6:0] b
);
always @(*) begin
    if(en) begin
    case (a)
        4'd0 : b <= 7'b1000000;
        4'd1 : b <= 7'b1111001;
        4'd2 : b <= 7'b0100100;//0010010
        4'd3 : b <= 7'b0110000;//0000110
        4'd4 : b <= 7'b0011001;//1001100
        4'd5 : b <= 7'b0010010;//0100100
        4'd6 : b <= 7'b0000010;//0100000
        4'd7 : b <= 7'b1111000;//0001111
        4'd8 : b <= 7'b0000000;
        4'd9 : b <= 7'b0010000;//0000100
    endcase
    end
    else b <= 7'b1111111;
end
endmodule