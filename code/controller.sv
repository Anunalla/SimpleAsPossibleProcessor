import sap_pkg::*;

module dff(input reg clk, load, val, d, output reg q);
    always@(negedge clk) begin
        if(!load) q<=val;
        else q<=d;
    end
endmodule

module ring_counter #(parameter N=6, parameter WIDTH=3) 
(input reg clk, rst, output reg[N-1:0] counter);
    
    genvar i;
    generate;
        for(i=0; i<N; i++) begin
            dff ff_dut(clk,rst, i==0?1'b1:1'b0, i==0?counter[N-1]:counter[i-1],counter[i]);
        end
    endgenerate
    
endmodule

module controller (input reg[3:0] ir_out,
                input reg rst, 
                STATE_t state, 
                output reg[11:0] controlword,
                output reg clk,
                output reg clkn,
                output reg clr,
                output reg clrn);

    assign clr = rst;
    assign clrn = ~clr;
    assign clkn = ~clk;
    logic clk_gate = 1;
    initial begin
        clk = 0; controlword = 12'h3E3;
    end
    always #10 clk = clk_gate& ~clk;
    
    always @(*) begin
        case(state) 
        T1: controlword = 12'h5E3;
        T2: controlword = 12'hBE3;
        T3: controlword = 12'h263;
        T4: begin
            case(ir_out)
            (4'b0000): controlword = 12'h1A3;
            (4'b0001): controlword = 12'h1A3;
            (4'b0010): controlword = 12'h1A3;
            (4'b1110): controlword = 12'h3F2;
            (4'b1111): begin
                controlword = 12'h3E3;
                clk_gate = 0;
            end
            default: begin
                $display("T4: IR_OUT CASE DEFAULT");
                controlword = 12'h3E3;
            end
            endcase
        end
        T5: begin
            case(ir_out)
            (4'b0000): controlword = 12'h2C3;
            (4'b0001): controlword = 12'h2E1;
            (4'b0010): controlword = 12'h2E1;
            (4'b1110): controlword = 12'h3E3;
            (4'b1111): controlword = 12'h3E3;
            default: begin
                $display("T5: IR_OUT CASE DEFAULT");
                controlword = 12'h3E3;
            end
            endcase
        end
        T6: begin
            case(ir_out)
            (4'b0000): controlword = 12'h3E3;
            (4'b0001): controlword = 12'h3C7;
            (4'b0010): controlword = 12'h2CF;
            (4'b1110): controlword = 12'h3E3;
            (4'b1111): controlword = 12'h3E3;
            default: begin
                $display("T6: IR_OUT CASE DEFAULT");
                controlword = 12'h3E3;
            end
            endcase
        end
        default: controlword = 12'h3E3;
        endcase
    end

endmodule