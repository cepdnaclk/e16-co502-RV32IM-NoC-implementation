`include "../other_modules/mux_2x1_32bit/mux_2x1_32bit.v"

module address_map(NODEADDRESS, MEMADDRESS, ADDRESS);

input[3:0] NODEADDRESS;
input[31:0] MEMADDRESS;
output wire[31:0] ADDRESS;

wire[1:0] X, Y;

wire sharedMemAccess;
wire[31:0] xOffset, yOffset, sharedOffset, memoryMap, sharedMap, sharedAddressValue;

assign X = NODEADDRESS[3:2];
assign Y = NODEADDRESS[1:0];
assign sharedMemAccess = MEMADDRESS >= 1024 ? 1 : 0;
/*
initial begin
    $monitor("Time :%t\tX : %b\tY : %b\tsharedMemAccess : %b\t", $time, X, Y, sharedMemAccess);
    $monitor("Time :%t\txOffset : %d\tyOffset : %d\t", $time, xOffset, yOffset);
    $monitor("Time :%t\tsharedMap : %d\tmemoryMap : %d\t", $time, sharedMap, memoryMap);
    $monitor("Time :%t\taddress : %d\tm", $time, ADDRESS);
end
*/
assign xOffset = X << 12;
assign yOffset = Y << 10;
assign sharedOffset = 4 << 12;

assign memoryMap = xOffset + yOffset + MEMADDRESS;
assign sharedAddressValue = { 23'd0, MEMADDRESS[8:0] };
assign sharedMap = sharedOffset + sharedAddressValue;

mux_2x1_32bit address_select_mux(memoryMap, sharedMap, ADDRESS, sharedMemAccess);
 
endmodule