module test_lcd (
    input  wire[11:0] SW,
    input wire[3:0] KEY,

    output reg LCD_ON,   //power on
    output reg LCD_BLON, //背光on
    output reg LCD_EN,   //lcd使能
    output reg LCD_RS,       //0命令  1数据
    output reg LCD_RW,       //读写选择 0写  1读
    output reg[7:0] LCD_DATA
);
    always @(*) begin
        LCD_ON <= SW[11];
        LCD_BLON <= SW[10];
        LCD_EN <= ~KEY[0];
        LCD_RS <= SW[9];
        LCD_RW <= SW[8];
        LCD_DATA <= SW[7:0];
    end
endmodule