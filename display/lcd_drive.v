module lcd_drive (
    output reg lcd_on,   //power on
    output reg lcd_blon, //背光on
    output reg lcd_en,   //lcd使能
    output reg rs,       //0命令  1数据
    output reg rw,       //读写选择 0写  1读
    output reg[7:0] data
);

always @(*) begin
    lcd_on <= 1;
    lcd_blon <= 1;
    lcd_en <= 1;
end
endmodule