`ifndef BUS_INTERFACE_SV
`define BUS_INTERFACE_SV

interface bus_if();
    reg[7:0] command;
    reg en;
    reg ready;

    modport feeder(
        input en, command,
        output ready
    );

    modport reciever (
        output en, command,
        input ready
    );
endinterface
`endif