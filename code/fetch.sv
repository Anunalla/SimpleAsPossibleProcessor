`include "bus_interface.sv"
import sap_pkg::*;

module program_counter(input reg clk, rst, ep, cp,
        // output
        bus_if.feeder bus_port, output reg[3:0] pc );

    // reg[3:0] pc;
    always @(negedge clk) begin
        if(!rst) pc= '0;
        else begin
            if(cp) pc = pc+1;
            if(ep) bus_port.command[3:0]= pc;
        end
    end

endmodule

module mar (input reg clk,
bus_if.reciever getIP, input reg lm_n, output reg[3:0] mar_reg);
    
    always @(posedge clk) begin
        if(!lm_n) 
            mar_reg = getIP.command[3:0];
    end
endmodule

module ir (input reg clk, rst, l1_n, e1_n, bus_if busif, 
    output reg[3:0] ir_out);
    reg[7:0] ir_reg;
    assign ir_out = ir_reg[7:4];
    always @(posedge clk) begin
        if(rst) begin 
            // $display("IR:reset");
            ir_reg='0;
        end
        else begin
            // $display("IR: Not reset");
            if(!l1_n) begin
                ir_reg <= busif.command;
                busif.ready <= 1;
            end
            if(!e1_n) begin
                busif.command <= ir_reg;
                busif.en <= 1;
            end
        end
    end
endmodule

module ram #(parameter ADDR_WIDTH=4, parameter DATA_WIDTH=8, parameter RAMSIZE= 16) (
    input reg en,wr, 
    input reg[ADDR_WIDTH-1:0] addr,
    input reg[DATA_WIDTH-1:0] datain,
    output reg[DATA_WIDTH-1:0] dataout
);
    reg[DATA_WIDTH-1:0] ram_array[RAMSIZE-1:0];

    always @(*) begin
        if(en) begin
            if(wr) ram_array[addr] = datain;
            else dataout = ram_array[addr];
        end
    end

    initial begin
        $display("loading program memory");
        $readmemh("program.mem", ram_array, 0);
        // $display("loading data memory");
        // $readmemh("data.mem", ram_array, 16);
    end
endmodule

module ram_top(input reg ce, 
                input reg[3:0] input_mar_addr, 
                bus_if.feeder putIP);

    reg wr;
    reg[3:0] addr;
    reg[7:0] datain;
    reg[7:0] dataout;
    assign addr = input_mar_addr;
    ram ram(!ce, wr,addr, datain, dataout);
    always @(*) begin
        if(!ce) begin
            wr = 0;
            putIP.command = dataout;
            putIP.en = 1;
        end
    end
endmodule