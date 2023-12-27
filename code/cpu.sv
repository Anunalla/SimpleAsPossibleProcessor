`include "bus_interface.sv"
import sap_pkg::*;

module sap1_cpu ();
    reg clk,clkn,clr,clrn;
    reg rst=0;
    reg counter_done;
    
    STATE_t counter;
    bus_if my_bus();

    reg[3:0] input_mar;
    reg[2:0] counter_out;
    reg[3:0] ir_out;
    reg[11:0] controlword;
    reg[7:0] acc_reg;
    reg[7:0] breg;
    reg[7:0] display;

    ring_counter tstates(clk, clrn, {>>{counter}});
    controller cunit(ir_out, rst,counter, controlword,clk,clkn,clr,clrn);
    program_counter pc(clkn,clrn,controlword[ep],controlword[cp],my_bus);
    mar ipmar(clk, my_bus, controlword[lm_n], input_mar);
    ram_top mem1(controlword[ce_n],input_mar,my_bus);
    ir ir1(clk, clr, controlword[l1_n], controlword[e1_n], my_bus, ir_out);
    accumulator acc(clk, controlword[la_n], controlword[ea],acc_reg, my_bus);
    b_reg b(clk, controlword[lb_n],my_bus,breg);
    addersub addsub(controlword[eu],controlword[su],breg, acc_reg, my_bus);
    b_reg out(clk, controlword[lo_n],my_bus,display);
   
    initial begin
        #5 rst=1;
        #20 rst=0;
        #600 $stop();
    end
endmodule
