`include "bus_interface.sv"
import sap_pkg::*;


module b_reg (input reg clk, lb_n, bus_if busif, output reg[7:0] b_out);
    always @(posedge clk) begin
        if(!lb_n) begin
            b_out <= busif.command;
            busif.ready <= 1;
        end
    end
endmodule

module addersub(input reg eu,su, 
input reg[7:0] b_out, acc_out, bus_if busif);
    reg[7:0] sum;
    reg prop_delay=1;
    always @(*) begin
        if(!su) begin
            sum = acc_out + b_out;
        end
        else begin
            sum = acc_out + (~(b_out)+1'b1);
        end
        if(eu & prop_delay) begin
            busif.command = sum;
            prop_delay = 0;
        end
        if(!eu) prop_delay = 1;
    end
endmodule

module accumulator (input reg clk, la_n, ea, output reg[7:0] acc, bus_if busif);
    
    always @(posedge clk) begin
        if(!la_n) acc = busif.command;
        if(ea) busif.command =acc;
    end
endmodule