module DIGCLOCK (
    input CLOCK_50,
    input wire[3:0] KEY,

    output reg[6:0] HEX0,
    output reg[6:0] HEX1,
    output reg[6:0] HEX2,
    output reg[6:0] HEX3,
    output reg[6:0] HEX4,
    output reg[6:0] HEX5,
    output reg[6:0] HEX6,
    output reg[6:0] HEX7,
    output reg[1:0] LEDR,

    output reg[7:0] LCD_DATA,
    output reg      LCD_RW,
    output reg      LCD_EN,
    output reg      LCD_RS,
    output reg      LCD_ON,
    output reg      LCD_BLON,

    output reg[8:0] LEDG,
    output reg[2:0] GPIO_1
);
//key_control直接对接DE2，将物理按键等直接映射
wire add;
wire clr;
wire adjust;
wire[3:0] select;
wire adjust_week,add_week,bl;   //LCD方面
wire adjust_alarm,flip_state,select_add,alarm_add,alarm_clr;
key_control key_control_u(
    .CLOCK_50(CLOCK_50),
    .KEY(KEY),

    .add(add),
    .clr(clr),
    .adjust(adjust),
    .select(select),

    .adjust_week(adjust_week),
    .add_week(add_week),
    .bl(bl),

    .adjust_alarm(adjust_alarm),
    .flip_state(flip_state),
    .select_add(select_add),
    .alarm_add(alarm_add),
    .alarm_clr(alarm_clr)
);

//time_float将key_control的输入，配合时钟，输出自己的时间存到寄存器
wire[7:0] milliseconds;
wire[6:0] seconds;
wire[6:0] minutes;
wire[5:0] hours;
wire[5:0] day;
wire[4:0] month;
wire[7:0] year_l;
wire[7:0] year_h;
time_float time_float_u(
    .CLOCK_50(CLOCK_50),
    .add(add),
    .clr(clr),
    .adjust(adjust),
    .select(select),
    .millisecond(milliseconds),
    .second(seconds),
    .minute(minutes),
    .hour(hours),
    .day(day),
    .month(month),
    .year_l(year_l),
    .year_h(year_h)
);

//display_time需要时钟，key_control以及time_float的输出，进行统一显示
wire[6:0] HEX0_t;
wire[6:0] HEX1_t;
wire[6:0] HEX2_t;
wire[6:0] HEX3_t;
wire[6:0] HEX4_t;
wire[6:0] HEX5_t;
wire[6:0] HEX6_t;
wire[6:0] HEX7_t;
always @(*) begin
    HEX0 <= HEX0_t;
    HEX1 <= HEX1_t;
    HEX2 <= HEX2_t;
    HEX3 <= HEX3_t;
    HEX4 <= HEX4_t;
    HEX5 <= HEX5_t;
    HEX6 <= HEX6_t;
    HEX7 <= HEX7_t;
end
wire[1:0] LEDR_wire;
always @(*) begin
    LEDR <= LEDR_wire;
end
display_time display_time_u(
    .CLOCK_50(CLOCK_50),
    .adjust(adjust),
    .select(select),
    .millisecond(milliseconds),
    .second(seconds),
    .minute(minutes),
    .hour(hours),
    .day(day),
    .month(month),
    .year_l(year_l),
    .year_h(year_h),
    .HEX0(HEX0_t),
    .HEX1(HEX1_t),
    .HEX2(HEX2_t),
    .HEX3(HEX3_t),
    .HEX4(HEX4_t),
    .HEX5(HEX5_t),
    .HEX6(HEX6_t),
    .HEX7(HEX7_t),
    .LEDR(LEDR_wire)
);
//将key_control的部分控制输出和time_float的数据输入lcd_data_trans
//将其输出引出接入LCD_drive
wire[255:0] data_in;
wire bl_en;
lcd_data_trans lcd_data_trans_uti(
    .CLOCK_50(CLOCK_50),
    .adjust_week(adjust_week),
    .add_week(add_week),
    .bl(bl),
    .second(seconds),
    .minute(minutes),
    .hour(hours),
    .day(day),
    .month(month),
    .year_l(year_l),
    .year_h(year_h),
    .data_in(data_in[199:0]),
    .bl_en(bl_en)
);
//将lcd_drive例化，并且输入数据，引出结果
wire[7:0] lcd_data_wire;    
wire      lcd_rw_wire;      
wire      lcd_en_wire;      
wire      lcd_rs_wire;      
wire      lcd_on_wire;      
wire      lcd_blon_wire;    
always @(*) begin
    LCD_DATA    <= lcd_data_wire;   
    LCD_RW      <= lcd_rw_wire;     
    LCD_EN      <= lcd_en_wire;     
    LCD_RS      <= lcd_rs_wire;     
    LCD_ON      <= lcd_on_wire;     
    LCD_BLON    <= lcd_blon_wire;   
end
lcd_drive lcd_drive_uti(
    .data_in(data_in),
    .CLOCK_50(CLOCK_50),
    .bl_in(bl_en),
    .lcd_on(lcd_on_wire),
    .lcd_blon(lcd_blon_wire),
    .lcd_en(lcd_en_wire),
    .rs(lcd_rs_wire),
    .rw(lcd_rw_wire),
    .data(lcd_data_wire)
);
    
wire beep_wire;
wire[8:0] ledg_wire;
wire state_wire;
wire[3:0] select_one_wire;
wire[5:0] alarm_hour_wire;
wire[6:0] alarm_minute_wire;
Alarm Alarm_uti(
    .CLOCK_50(CLOCK_50),
    .adjust_alarm(adjust_alarm),
    .flip_state(flip_state),
    .select_add(select_add),
    .add(alarm_add),
    .clr(alarm_clr),
    .second(seconds),
    .minute(minutes),
    .hour(hours),

    .beep(beep_wire),
    .ledg(ledg_wire),
    .state(state_wire),
    .select_one(select_one_wire),
    .alarm_hour(alarm_hour_wire),
    .alarm_minute(alarm_minute_wire)
);
always @(*) begin
    GPIO_1 <= {1'b1, beep_wire, 1'b0};
    LEDG <= ledg_wire;
end

lcd_alarm_trans lcd_alarm_trans_uti(
    .CLOCK_50(CLOCK_50),
    .state(state_wire),
    .select_one(select_one_wire),
    .alarm_hour(alarm_hour_wire),
    .alarm_minute(alarm_minute_wire),

    .data_in(data_in[255:200])
);
endmodule
