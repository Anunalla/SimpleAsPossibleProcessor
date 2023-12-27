package sap_pkg;

    parameter cp=11;
    parameter ep=10;
    parameter lm_n=9;
    parameter ce_n=8;
    parameter l1_n=7;
    parameter e1_n=6;
    parameter la_n=5;
    parameter ea=4;
    parameter su=3;
    parameter eu=2;
    parameter lb_n=1;
    parameter lo_n=0; 

    typedef enum reg[5:0] {
        T1 = 6'b000001,
        T2 = 6'b000010,
        T3 = 6'b000100,
        T4 = 6'b001000,
        T5 = 6'b010000,
        T6 = 6'b100000
    } STATE_t;

    

endpackage