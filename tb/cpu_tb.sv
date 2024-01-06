`include "../code/bus_interface.sv"
`include "cpu_assert.sv"
import sap_pkg::*;


module cpu_tb();
    reg rst=0;
    reg clk,clkn,clr,clrn;
    bus_if my_bus();
    reg[7:0] display;
    reg[7:0] acc_reg;
    reg[7:0] breg;
    reg[5:0] counter_out;
    reg[3:0] input_mar;
    reg[3:0] ir_out,pc_out;
    reg[11:0] controlword;
    STATE_t counter;

    sap1_cpu dut(rst, clk,clkn,clr,clrn,
                my_bus, counter,
                display,
                acc_reg,
                breg,
                counter_out,
                input_mar,
                ir_out,pc_out,
                controlword);
    
    // bind cpu_assert sap1_cpu dut2(rst, clk,clkn,clr,clrn,
    //             my_bus, counter,
    //             display,
    //             acc_reg,
    //             breg,
    //             counter_out,
    //             input_mar,
    //             ir_out,pc_out,
    //             controlword);



    initial begin
        #5 rst=1;
        #20 rst=0;
        #600 $stop();
    end


    default clocking pclk 
    @(posedge clk);
    endclocking
    default disable iff (rst); 
    // sequence rst_dis
    //     rst ##1;
    // endsequence

    property mar_check;
        (counter==T1) |=> input_mar == (my_bus.command);
    endproperty

    property pc_check;
        (counter==T2) |=>  pc_out== $past(pc_out+1);
    endproperty

    property ir_check;
        (counter==T3) |=> $changed(ir_out);
    endproperty

    
    reg[11:0] default_controlword = 12'h3E3;
    integer i;
    // checking control word 
    sequence active_ctlword2(index1,index2);
        (controlword[index1] == ~default_controlword[index1]) & (controlword[index2]==~default_controlword[index2]);
    endsequence

    sequence active_ctlword1(index1);
        (controlword[index1] == ~default_controlword[index1]);
    endsequence

    property t1_cw;
        (counter==T1) |-> active_ctlword2(ep,lm_n);
    endproperty

    // property t1_cw;
    //     (counter==T1) |-> ((active_ctlword(ep,controlword)) &(active_ctlword(lm_n,controlword)));
    // endproperty
    property t2_cw;
        (counter==T2) |-> active_ctlword1(cp);
    endproperty

    property t3_cw;
        (counter==T3) |-> active_ctlword2(ce_n,l1_n);
    endproperty
    
    

    MAR_CHECK: assert property (mar_check);
    // assert if PC++ in T2;
    PC_CHECK: assert property(pc_check);
    // assert if CE_n and Li_n in T3;IR == RAM[IR[:4]]
    IR_CHECK: assert property(ir_check); // any way the exact IR contents could be checked for correctness?

    T1_ACTIVE_CWCHECK: assert property(t1_cw);
    T2_ACTIVE_CWCHECK: assert property(t2_cw);
    T3_ACTIVE_CWCHECK: assert property(t3_cw);

    // LDA:
    // T4: Ei_n and Lm_n active; MAR==INST
    // T5: CE_n, La_n active; Accumulator == RAM[MAR]
    // T6: NOP

    // ADD:
    // T4, T5, T6

    // SUB:
    // T4, T5, T6

    // OUT:
    // T4, T5, T6
endmodule



