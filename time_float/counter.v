/*
    本文档为各种模数计数器，省去判断归零的操作，但24时，31日，30日，29日，28日，12月仍需联合判断
    计数器均：clk上升沿有效
            clr上升沿有效
*/

//模10计数器-4位：存储0-9
module counter10 (
    input clk,
    input clr,
    output reg[3:0] data,
    output reg rco
);
always @(posedge clk, posedge clr) begin
    if(clr)
        begin
            data <= 0;
            rco <= 0;
        end
    else if(data == 4'b1001)
        begin
            data <= 0;
            rco <= 1;
        end
    else
        begin
            data <= data + 1;
            rco <= 0;
        end
end
endmodule

//模6计数器-3位：存储0-5
module counter6 (
    input clk,
    input clr,
    output reg[2:0] data,
    output reg rco
);
always @(posedge clk, posedge clr) begin
    if(clr)
        begin
            data <= 0;
            rco <= 0;
        end
    else if(data == 3'b101)
        begin
            data <= 0;
            rco <= 1;
        end
    else
        begin
            data <= data + 1;
            rco <= 0;
        end
end
endmodule

//模4计数器-2位：存储0-3
module counter4(
    input clk,
    input clr,
    output reg[1:0] data,
    output reg rco
);
always @(posedge clk, posedge clr) begin
    if(clr)
        begin
            data <= 0;
            rco <= 0;
        end
    else if(data == 2'b11)
        begin
            data <= 0;
            rco <= 1;
        end
    else
        begin
            data <= data + 1;
            rco <= 0;
        end
end
endmodule


//4线16译码器，有效高电平
module MUX4_16 (
    input wire[3:0] a,
    output reg[15:0] b
);
always@(*)  begin
    case(a)
    4'd0 : b <= 16'b0000_0000_0000_0001;
    4'd1 : b <= 16'b0000_0000_0000_0010;
    4'd2 : b <= 16'b0000_0000_0000_0100;
    4'd3 : b <= 16'b0000_0000_0000_1000;
    4'd4 : b <= 16'b0000_0000_0001_0000;
    4'd5 : b <= 16'b0000_0000_0010_0000;
    4'd6 : b <= 16'b0000_0000_0100_0000;
    4'd7 : b <= 16'b0000_0000_1000_0000;
    4'd8 : b <= 16'b0000_0001_0000_0000;
    4'd9 : b <= 16'b0000_0010_0000_0000;
    4'd10 : b <= 16'b0000_0100_0000_0000;
    4'd11 : b <= 16'b0000_1000_0000_0000;
    4'd12 : b <= 16'b0001_0000_0000_0000;
    4'd13 : b <= 16'b0010_0000_0000_0000;
    4'd14 : b <= 16'b0100_0000_0000_0000;
    4'd15 : b <= 16'b1000_0000_0000_0000;
    endcase
end
    
endmodule