`include "../utils/macros.v"
`include "../utils/encodings.v"
`include "address_map.v"


module address_map_tb;
    
    reg[3:0] NODEADDRESS;
    reg[31:0] MEMADDRESS;
    wire[31:0] ADDRESS;

    address_map my_address_map(NODEADDRESS, MEMADDRESS, ADDRESS);

    initial begin
        // ------- ADDRESS MAP Test 01 : Address generation for node (0, 0) ----------
        NODEADDRESS = 4'b0000;
        MEMADDRESS = 32'd10;
        #0;
        `assert(ADDRESS,32'd10);

        $display("ADDRESS MAP Test 01: Address generation for node (0, 1) passed!");

        // ------- ADDRESS MAP Test 02 : Address generation for node (0, 1) ----------
        NODEADDRESS = 4'b0001;
        MEMADDRESS = 32'd10;
        #0;
        `assert(ADDRESS,32'd1034);

        $display("ADDRESS MAP Test 02: Address generation for node (0, 1) passed!");

        // ------- ADDRESS MAP Test 03 : Address generation for node (1, 1) ----------
        NODEADDRESS = 4'b0101;
        MEMADDRESS = 32'd10;
        #0;
        `assert(ADDRESS,32'd5130);

        $display("ADDRESS MAP Test 03: Address generation for node (1, 1) passed!");

        $display("All Tests Passed !!!");

    
    end

endmodule