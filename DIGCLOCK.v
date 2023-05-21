module DIGCLOCK (
    input CLOCK_50,add,
    input clr,
    input adjust,
    input wire[3:0] select,
    output reg[6:0] HEX0,
    output reg[6:0] HEX1,
    output reg[6:0] HEX2,
    output reg[6:0] HEX3,
    output reg[6:0] HEX4,
    output reg[6:0] HEX5,
    output reg[6:0] HEX6,
    output reg[6:0] HEX7,
    output reg[1:0] LEDR
);
wire[7:0] milliseconds;
wire[6:0] seconds;
wire[6:0] minutes;
wire[5:0] hours;
wire[5:0] day;
wire[4:0] month;
wire[7:0] year_l;
wire[7:0] year_h;
time_float u1(
    .CLOCK_50(CLOCK_50),
    .add(~add),
    .clr(~clr),
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
display_time u2(
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
    .HEX7(HEX7_t)
);
    
endmodule