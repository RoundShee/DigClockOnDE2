/*
    两个任务
    星期处理
    数据转换
*/
module lcd_data_trans (
    input CLOCK_50,
    input adjust_week,  //高电平手动调整
    input add_week,     //在上面高电平下才有效
    input bl,           //背光开关
    input wire[6:0] second,
    input wire[6:0] minute,
    input wire[5:0] hour,
    input wire[5:0] day,
    input wire[4:0] month,
    input wire[7:0] year_l,
    input wire[7:0] year_h,

    //output reg[255:0] data_in,
    output reg[199:0] data_in,
    output reg bl_en    //背光输出 对接drive的bl_in
);
//LCD1602第一行数据转换
always @(*) begin
    data_in[7:0]    <= {4'b0011,year_h[7:4]};
    data_in[15:8]   <= {4'b0011,year_h[3:0]};
    data_in[23:16]  <= {4'b0011,year_l[7:4]};
    data_in[31:24]  <= {4'b0011,year_l[3:0]};
    data_in[39:32]  <= 8'b0010_1111;
    data_in[47:40]  <= {7'b0011_000,month[4]};
    data_in[55:48]  <= {4'b0011,month[3:0]};
    data_in[63:56]  <= 8'b0010_1111;
    data_in[71:64]  <= {6'b0011_00,day[5:4]};
    data_in[79:72]  <= {4'b0011,day[3:0]};
    data_in[87:80]  <= 8'b0010_0000;
    data_in[95:88]  <= {6'b0011_00,hour[5:4]};
    data_in[103:96] <= {4'b0011,hour[3:0]};
    if(second[0]==0)
        data_in[111:104]<= 8'b0011_1010;
    else data_in[111:104]<= 8'b0010_0000;
    data_in[119:112]<= {5'b0011_0,minute[6:4]};
    data_in[127:120]<= {4'b0011,minute[3:0]};
end
//LCD1602第二行数据处理
reg[2:0] week;
reg week_drive; //weeek检测二选一
always @(*) begin
    if(adjust_week)
        week_drive <= add_week;
    else week_drive <= (hour==6'd0);
end
always @(posedge week_drive) begin
    if(week > 3'd5)
        week <= 3'd0;
    else week <= week + 1;
end
//week显示输出
always @(*) begin
    case (week)
        3'd0 : begin
            data_in[135:128] <= 8'b0101_0011;//S
            data_in[143:136] <= 8'b0111_0101;//u
            data_in[151:144] <= 8'b0110_1110;//n
            data_in[159:152] <= 8'b0110_0100;//d
            data_in[167:160] <= 8'b0110_0001;//a
            data_in[175:168] <= 8'b0111_1001;//y
            data_in[183:176] <= 8'b0010_0000;// 
            data_in[191:182] <= 8'b0010_0000;// 
            data_in[199:192] <= 8'b0010_0000;// 
        end
        3'd1 : begin
            data_in[135:128] <= 8'b0100_1101;//M
            data_in[143:136] <= 8'b0110_1111;//o
            data_in[151:144] <= 8'b0110_1110;//n
            data_in[159:152] <= 8'b0110_0100;//d
            data_in[167:160] <= 8'b0110_0001;//a
            data_in[175:168] <= 8'b0111_1001;//y
            data_in[183:176] <= 8'b0010_0000;// 
            data_in[191:182] <= 8'b0010_0000;// 
            data_in[199:192] <= 8'b0010_0000;// 
        end
        3'd2 : begin                        //这里有问题
            data_in[135:128] <= 8'b0101_0100;//T
            data_in[143:136] <= 8'b0111_0101;//u
            data_in[151:144] <= 8'b0110_0101;//e
            data_in[159:152] <= 8'b0111_0011;//s
            data_in[167:160] <= 8'b0110_0100;//d
            data_in[175:168] <= 8'b0110_0001;//a
            data_in[183:176] <= 8'b0111_1001;//y
            data_in[191:182] <= 8'b0010_0000;// 
            data_in[199:192] <= 8'b0010_0000;// 
        end
        3'd3 : begin
            data_in[135:128] <= 8'b0101_0111;//W
            data_in[143:136] <= 8'b0110_0101;//e
            data_in[151:144] <= 8'b0110_0100;//d
            data_in[159:152] <= 8'b0110_1110;//n
            data_in[167:160] <= 8'b0110_0101;//e
            data_in[175:168] <= 8'b0111_0011;//s
            data_in[183:176] <= 8'b0110_0100;//d
            data_in[191:182] <= 8'b0110_0001;//a
            data_in[199:192] <= 8'b0111_1001;//y
        end
        3'd4 : begin                        //这里有问题
            data_in[135:128] <= 8'b0101_0100;//T
            data_in[143:136] <= 8'b0111_0101;//u
            data_in[151:144] <= 8'b0111_0010;//r
            data_in[159:152] <= 8'b0111_0011;//s
            data_in[167:160] <= 8'b0110_0100;//d
            data_in[175:168] <= 8'b0110_0001;//a
            data_in[183:176] <= 8'b0111_1001;//y
            data_in[191:182] <= 8'b0010_0000;// 
            data_in[199:192] <= 8'b0010_0000;// 
        end
        3'd5 : begin
            data_in[135:128] <= 8'b0100_0110;//F
            data_in[143:136] <= 8'b0111_0010;//r
            data_in[151:144] <= 8'b0110_1001;//i
            data_in[159:152] <= 8'b0110_0100;//d
            data_in[167:160] <= 8'b0110_0001;//a
            data_in[175:168] <= 8'b0111_1001;//y
            data_in[183:176] <= 8'b0010_0000;// 
            data_in[191:182] <= 8'b0010_0000;// 
            data_in[199:192] <= 8'b0010_0000;// 
        end
        3'd6 : begin
            data_in[135:128] <= 8'b0101_0011;//S
            data_in[143:136] <= 8'b0110_0001;//a
            data_in[151:144] <= 8'b0111_0100;//t
            data_in[159:152] <= 8'b0111_0101;//u
            data_in[167:160] <= 8'b0111_0010;//r
            data_in[175:168] <= 8'b0110_0100;//d
            data_in[183:176] <= 8'b0110_0001;//a
            data_in[191:182] <= 8'b0111_1001;//y
            data_in[199:192] <= 8'b0010_0000;// 
        end
    endcase
end

//背光问题
//按下背光亮一会秒，调星期直接闪
reg[27:0] count_bl; //还是用count_bl[24]闪;
always @(*) begin
    if(adjust_week) bl_en <= count_bl[24];
    else bl_en <= light;
end
//计时器问题
reg light;
always @(posedge CLOCK_50) begin
    if(adjust_week) begin           //检测调时信号
        count_bl <= count_bl + 1;
    end
    else if(count_bl[27]==1) begin  //亮屏归零，熄灭
        light <= 0;
        count_bl <= 0;
    end
    else if(bl || light) begin      //亮屏启动
        light <= 1;
        count_bl <= count_bl + 1;
    end
end //我都觉得 妙 ！！

//剩下得存储问题，目前不预留了，直接为空
/*
always @(*) begin
    data_in[207:200] <= 8'b0010_0000;
    data_in[215:208] <= 8'b0010_0000;
    data_in[223:216] <= 8'b0010_0000;
    data_in[231:224] <= 8'b0010_0000;
    data_in[239:232] <= 8'b0010_0000;
    data_in[247:240] <= 8'b0010_0000;
    data_in[255:248] <= 8'b0010_0000;
end
*/
endmodule