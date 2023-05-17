module DIGCLOCK (
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
wire[7:0] milliseconds;
wire[6:0] seconds;
wire[6:0] minutes;
wire[5:0] hours;
time_float u1(
    .clk(clk),
    .add(~add),
    .clr(~clr),
    .adjust(adjust),
    .select(select),
    .millisecond(milliseconds),
    .second(seconds),
    .minute(minutes),
    .hour(hours)
);
    
endmodule