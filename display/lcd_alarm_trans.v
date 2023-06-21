/*
    将alarm的内容输出到剩下的角落里
*/
module lcd_alarm_trans(
    input CLOCK_50,
    input state,
    input wire[1:0] select_one,
    input wire[5:0] alarm_hour,
    input wire[6:0] alarm_minute,

    output reg[255:200] data_in
);
always @(posedge CLOCK_50) begin
    if(!state) begin    //闹钟关闭
        data_in[207:200] <= 8'b0010_0000;
        data_in[215:208] <= 8'b0010_0000;
        data_in[223:216] <= 8'b0010_0000;
        data_in[231:224] <= 8'b0010_0000;
        data_in[239:232] <= 8'b0100_1111;//O
        data_in[247:240] <= 8'b0100_0110;//F
        data_in[255:248] <= 8'b0100_0110;//F
    end
    else if((select_one == 4'b0001)&&count[23])begin
        data_in[207:200] <= 8'b0010_0000;                   // 
        data_in[215:208] <= 8'b0110_0001;                   //a
        data_in[223:216] <= {6'b0011_00,alarm_hour[5:4]};   //hour_h
        data_in[231:224] <= {4'b0011,alarm_hour[3:0]};            //hour_l
        data_in[239:232] <= 8'b0011_1010;                   //:
        data_in[247:240] <= {5'b0011_0,alarm_minute[6:4]};  //min_h
        data_in[255:248] <= 8'b0010_0000;                   //min_l but _
    end
    else if((select_one == 4'b0010)&&count[23])begin
        data_in[207:200] <= 8'b0010_0000;                   // 
        data_in[215:208] <= 8'b0110_0001;                   //a
        data_in[223:216] <= {6'b0011_00,alarm_hour[5:4]};   //hour_h
        data_in[231:224] <= {4'b0011,alarm_hour[3:0]};            //hour_l
        data_in[239:232] <= 8'b0011_1010;                   //:
        data_in[247:240] <= 8'b0010_0000;                   //min_h but _
        data_in[255:248] <= {4'b0011,alarm_minute[3:0]};          //min_l
    end
    else if((select_one == 4'b0100)&&count[23])begin
        data_in[207:200] <= 8'b0010_0000;                   // 
        data_in[215:208] <= 8'b0110_0001;                   //a
        data_in[223:216] <= {6'b0011_00,alarm_hour[5:4]};   //hour_h
        data_in[231:224] <= 8'b0010_0000;                   //hour_l but _
        data_in[239:232] <= 8'b0011_1010;                   //:
        data_in[247:240] <= {5'b0011_0,alarm_minute[6:4]};  //min_h
        data_in[255:248] <= {4'b0011,alarm_minute[3:0]};          //min_l
    end
    else if((select_one == 4'b1000)&&count[23])begin
        data_in[207:200] <= 8'b0010_0000;                   // 
        data_in[215:208] <= 8'b0110_0001;                   //a
        data_in[223:216] <= 8'b0010_0000;                   //hour_h but _
        data_in[231:224] <= {4'b0011,alarm_hour[3:0]};      //hour_l
        data_in[239:232] <= 8'b0011_1010;                   //:
        data_in[247:240] <= {5'b0011_0,alarm_minute[6:4]};  //min_h
        data_in[255:248] <= {4'b0011,alarm_minute[3:0]};          //min_l
    end
    else begin
        data_in[207:200] <= 8'b0010_0000;                   // 
        data_in[215:208] <= 8'b0110_0001;                   //a
        data_in[223:216] <= {6'b0011_00,alarm_hour[5:4]};   //hour_h
        data_in[231:224] <= {4'b0011,alarm_hour[3:0]};            //hour_l
        data_in[239:232] <= 8'b0011_1010;                   //:
        data_in[247:240] <= {5'b0011_0,alarm_minute[6:4]};  //min_h
        data_in[255:248] <= {4'b0011,alarm_minute[3:0]};          //min_l
    end
end

reg[23:0] count;
always @(posedge CLOCK_50) begin
    count <= count + 1;
end

endmodule
