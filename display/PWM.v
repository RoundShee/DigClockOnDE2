/*
    在此处模块中生成一个占空比可控的PWM波形
    2^6=64
*/
module PWM (
    input CLOCK_50,
    input en,
    input wire[5:0] duty,   //Duty cycle为占空比翻译
    output reg pwm_wave
);

reg[5:0] period;            //64个时钟为一个PWM周期
always @(posedge CLOCK_50) begin
    period <= period + 1;
end

always @(posedge CLOCK_50) begin
    if((en)&&(period <= duty))
        pwm_wave <= 1;
    else
        pwm_wave <= 0;
end

endmodule