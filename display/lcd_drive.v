/*
    不妨先写 输入16*2字节的数据，本模块对数据进行处理，
    不断刷新进行 直接输出
    上级模块处理数据内容

    16*2*8=256  输入为256
    en t_pw>150*10^{-9}  
    各指令执行时间
    使用时钟驱动的计数器[12]位  则对应count[11]
    但光标返回执行时间1.53ms，需要长时间的等待  保守需要2^16的等待

    对以下数据需要32+4的计数器，由en直接驱动，但开始使用2^16等待

    wire[255:0] data;
    data[7:0] year_Oxxx
    data[15:8] year_xOxx
    data[23:16] year_xxOx
    data[31:24] year_xxxO
    data[39:32] 
    data[47:40] month_h
    data[55:48] month_l
    data[63:56] 
    data[71:64] day_h
    data[79:72] day_l
    data[87:80] 
    data[95:88] hour_h
    data[103:96] hour_l
    data[111:104]
    data[119:112] min_h
    data[127:120] min_l
    data[135:128] S M T W T F S         //第二行
    data[143:136] u o u e u r a
    data[151:144] n n e d r i t
    data[159:152] d d s n s d u
    data[167:160] a a d e d a r
    data[175:168] y y a s a y d
    data[183:176]     y d y   a
    data[191:182]       a     y
    data[199:192]       y
    data[207:200]
    data[215:208]
    data[223:216] A      
    data[231:224] l      
    data[239:232] a
    data[247:240] r
    data[255:248] m
*/

module lcd_drive (
    input wire[255:0] data_in,
    input CLOCK_50,
    input bl_in,         //对接data_trans的bl_en输出
    output reg lcd_on,   //power on
    output reg lcd_blon, //背光on
    output reg lcd_en,   //lcd使能
    output reg rs,       //0命令  1数据
    output reg rw,       //读写选择 0写  1读
    output reg[7:0] data
);
//on以及背光情况
always @(*) begin
    lcd_on <= 1;
    //预留背光操作
    lcd_blon <= bl_in;
end


//lcd_en所需求的计数器
//en_count[11]周期为81.92us 对除光标返回和清屏之外绰绰有余
//因此如果执行返回光标需要此计数器空余20个数
reg[11:0] en_count;
always @(posedge CLOCK_50) begin
    en_count <= ~en_count;
end

//输入指令和数据的控制计数器
//2^6=64  64-32-4=28>20 因此足够
//*****下列三段always需要严格对应******
reg[5:0] command_count;
always @(posedge en_count[11]) begin
    if(command_count >6'd56)
        command_count <= 0;
    else command_count <= command_count + 1;
end

//lcd_en驱动
always @(posedge CLOCK_50) begin    //如果使用负边沿效果是否更好？
    if(command_count > 6'd35)
        lcd_en <= 0;
    else lcd_en <= en_count[11];
end

//指令序列 8.192us*56=4.58ms写入一轮
//刷新率位217Hz
always @(*) begin
    case (command_count)
        6'd0 : begin    //功能设置-光标写入数据后右移屏不动
            rs <= 0;
            rw <= 0;
            data <= 8'b0000_0110;
        end
        6'd1 : begin    //显示开关控制-光标不显示
            rs <= 0;
            rw <= 0;
            data <= 8'b0000_1100;
        end
        6'd2 : begin    //接口8位，显示两行 字形5*8
            rs <= 0;
            rw <= 0;
            data <= 8'b0011_1000;
        end
        //开始写入数据
        6'd3 :begin     //第一行第一个1-1
            rs <= 1;
            rw <= 0;
            data <= data_in[7:0];
        end
        6'd4 :begin     //1-2
            rs <= 1;
            rw <= 0;
            data <= data_in[15:8];
        end
        6'd5 :begin     //1-3
            rs <= 1;
            rw <= 0;
            data <= data_in[23:16];
        end
        6'd6 :begin     //1-4
            rs <= 1;
            rw <= 0;
            data <= data_in[31:24];
        end
        6'd7 :begin     //1-5
            rs <= 1;
            rw <= 0;
            data <= data_in[39:32];
        end
        6'd8 :begin     //1-6
            rs <= 1;
            rw <= 0;
            data <= data_in[47:40];
        end
        6'd9 :begin     //1-7
            rs <= 1;
            rw <= 0;
            data <= data_in[55:48];
        end
        6'd10 :begin     //1-8
            rs <= 1;
            rw <= 0;
            data <= data_in[63:56];
        end
        6'd11 :begin     //1-9
            rs <= 1;
            rw <= 0;
            data <= data_in[71:64];
        end
        6'd12 :begin     //1-10
            rs <= 1;
            rw <= 0;
            data <= data_in[79:72];
        end
        6'd13 :begin     //1-11
            rs <= 1;
            rw <= 0;
            data <= data_in[87:80];
        end
        6'd14 :begin     //1-12
            rs <= 1;
            rw <= 0;
            data <= data_in[95:88];
        end
        6'd15 :begin     //1-13
            rs <= 1;
            rw <= 0;
            data <= data_in[103:96];
        end
        6'd16 :begin     //1-14
            rs <= 1;
            rw <= 0;
            data <= data_in[111:104];
        end
        6'd17 :begin     //1-15
            rs <= 1;
            rw <= 0;
            data <= data_in[119:112];
        end
        6'd18 :begin     //1-16
            rs <= 1;
            rw <= 0;
            data <= data_in[127:120];
        end
        6'd19 :begin     //2-1
            rs <= 1;
            rw <= 0;
            data <= data_in[135:128];
        end
        6'd20 :begin     //2-2
            rs <= 1;
            rw <= 0;
            data <= data_in[143:136];
        end
        6'd21 :begin     //2-3
            rs <= 1;
            rw <= 0;
            data <= data_in[151:144];
        end
        6'd22 :begin     //2-4
            rs <= 1;
            rw <= 0;
            data <= data_in[159:152];
        end
        6'd23 :begin     //2-5
            rs <= 1;
            rw <= 0;
            data <= data_in[167:160];
        end
        6'd24 :begin     //2-6
            rs <= 1;
            rw <= 0;
            data <= data_in[175:168];
        end
        6'd25 :begin     //2-7
            rs <= 1;
            rw <= 0;
            data <= data_in[183:176];
        end
        6'd26 :begin     //2-8
            rs <= 1;
            rw <= 0;
            data <= data_in[191:182];
        end
        6'd27 :begin     //2-9
            rs <= 1;
            rw <= 0;
            data <= data_in[199:192];
        end
        6'd28 :begin     //2-10
            rs <= 1;
            rw <= 0;
            data <= data_in[207:200];
        end
        6'd29 :begin     //2-11
            rs <= 1;
            rw <= 0;
            data <= data_in[215:208];
        end
        6'd30 :begin     //2-12
            rs <= 1;
            rw <= 0;
            data <= data_in[223:216];
        end
        6'd31 :begin     //2-13
            rs <= 1;
            rw <= 0;
            data <= data_in[231:224];
        end
        6'd32 :begin     //2-14
            rs <= 1;
            rw <= 0;
            data <= data_in[239:232];
        end
        6'd33 :begin     //2-15
            rs <= 1;
            rw <= 0;
            data <= data_in[247:240];
        end
        6'd34 :begin     //2-16
            rs <= 1;
            rw <= 0;
            data <= data_in[255:248];
        end
        6'd35 :begin     //光标返回
            rs <= 0;
            rw <= 0;
            data <= 8'b0000_0010;
        end
    endcase
end

endmodule