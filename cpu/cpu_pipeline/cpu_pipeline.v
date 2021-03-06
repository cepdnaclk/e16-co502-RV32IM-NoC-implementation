`include "../other_modules/mux_2x1_32bit/mux_2x1_32bit.v"
`include "../other_modules/mux_4x1_32bit/mux_4x1_32bit.v"
`include "../other_modules/register_32bit/register_32bit.v"
`include "../other_modules/adder_32bit/adder_32bit.v"
`include "../instruction_cache_module/instruction_cache.v"
`include "../reg_file_module/reg_file.v"
`include "../control_unit_module/control_unit.v"
`include "../immediate_gen_module/immediate_generate.v"
`include "../alu_module/alu.v"
`include "../bj_detect_module/bj_detect.v"
`include "../data_cache_module/data_cache.v"
`include "../pipeline_reg_modules/EX_MEM_pipeline_reg_module/ex_mem_pipeline_reg.v"
`include "../pipeline_reg_modules/ID_EX_pipeline_reg_module/id_ex_pipeline_reg.v"
`include "../pipeline_reg_modules/IF_ID_pipeline_reg_module/if_id_pipeline_reg.v"
`include "../pipeline_reg_modules/MEM_WB_pipeline_reg_module/mem_wb_pipeline_reg.v"

module cpu_pipeline (RESET, CLK, INST_MEM_READDATA, DATA_MEM_READDATA, DATA_MEM_WRITEDATA, INST_MEM_READ, DATA_MEM_BUSYWAIT, DATA_MEM_READ, DATA_MEM_WRITE, INST_MEM_ADDRESS, DATA_MEM_ADDRESS, INST_MEM_BUSYWAIT);

input RESET, CLK, INST_MEM_BUSYWAIT, DATA_MEM_BUSYWAIT;
input [127:0] INST_MEM_READDATA, DATA_MEM_READDATA;
output [127:0] DATA_MEM_WRITEDATA;
output INST_MEM_READ, DATA_MEM_READ, DATA_MEM_WRITE;
output [27:0] INST_MEM_ADDRESS, DATA_MEM_ADDRESS;

wire [31:0] PC_4_OUT, ALU_OUT, PC_SEL_MUX_OUT, PC_OUT, INSTRUCTION, INSTRUCTION_ID, PC_OUT_ID, WB_MUX_OUT, REG_FILE_OUT1, REG_FILE_OUT2, IMM_GEN_OUT, PC_OUT_EX, REG_FILE_OUT1_EX, REG_FILE_OUT2_EX, IMM_GEN_OUT_EX, OPERAND1, OPERAND2, PC_OUT_MEM, ALU_OUT_MEM, REG_FILE_OUT2_MEM, IMM_GEN_OUT_MEM, PC_4_WB_OUT, READDATA, PC_4_WB_OUT_WB, ALU_OUT_WB, IMM_GEN_OUT_WB,  READDATA_WB;

wire PC_SEL, DATA_BUSYWAIT, INST_BUSYWAIT, REG_WRITE_EN_WB, WRITE_ENABLE, BUSYWAIT,OP1SEL, OP2SEL, REG_WRITE_EN, OP1SEL_EX,  OP2SEL_EX, REG_WRITE_EN_EX, REG_WRITE_EN_MEM;
wire [4:0] WRITE_ADDRESS_WB, WRITE_ADDRESS_EX, WRITE_ADDRESS_MEM;
wire [2:0] IMM_SEL, BRANCH_JUMP, BRANCH_JUMP_EX;
wire [1:0] WB_SEL, WB_SEL_EX, WB_SEL_MEM, WB_SEL_WB;
wire [4:0] ALUOP, ALUOP_EX;
wire [3:0] READ_WRITE, READ_WRITE_EX, READ_WRITE_MEM;

assign BUSYWAIT = (DATA_BUSYWAIT | INST_BUSYWAIT);
assign WRITE_ENABLE = (REG_WRITE_EN_WB & !BUSYWAIT);

// Instruction fetch stage
mux_2x1_32bit pc_sel_mux(PC_4_OUT, ALU_OUT, PC_SEL_MUX_OUT, PC_SEL);
register_32bit program_counter(PC_SEL_MUX_OUT, PC_OUT, RESET, CLK, BUSYWAIT);
instruction_cache inst_cache(CLK, RESET, PC_OUT, INSTRUCTION, INST_BUSYWAIT, INST_MEM_ADDRESS, INST_MEM_READ, INST_MEM_READDATA, INST_MEM_BUSYWAIT);
adder_32bit pc_4_adder(PC_OUT, PC_4_OUT);

if_id_pipeline_reg if_id_reg(INSTRUCTION, PC_OUT, INSTRUCTION_ID, PC_OUT_ID, CLK, RESET, BUSYWAIT);

// Instruction decode stage

reg_file register_file(WB_MUX_OUT, REG_FILE_OUT1, REG_FILE_OUT2, WRITE_ADDRESS_WB, INSTRUCTION_ID[19:15], INSTRUCTION_ID[24:20], WRITE_ENABLE, CLK, RESET);
immediate_generate imm_gen(INSTRUCTION_ID[31:7], IMM_GEN_OUT, IMM_SEL);
control_unit ctrl_unit(INSTRUCTION_ID[6:0], INSTRUCTION_ID[14:12], INSTRUCTION_ID[31:25], OP1SEL, OP2SEL, REG_WRITE_EN, WB_SEL, ALUOP, BRANCH_JUMP, IMM_SEL, READ_WRITE);

id_ex_pipeline_reg id_ex_reg(INSTRUCTION_ID[11:7], PC_OUT_ID, REG_FILE_OUT1,  REG_FILE_OUT2,  IMM_GEN_OUT, OP1SEL,  OP2SEL, ALUOP, BRANCH_JUMP, READ_WRITE, WB_SEL, REG_WRITE_EN, WRITE_ADDRESS_EX, PC_OUT_EX, REG_FILE_OUT1_EX, REG_FILE_OUT2_EX, IMM_GEN_OUT_EX,  OP1SEL_EX,  OP2SEL_EX, ALUOP_EX, BRANCH_JUMP_EX, READ_WRITE_EX, WB_SEL_EX, REG_WRITE_EN_EX, CLK,  RESET, BUSYWAIT);

// Instruction execution stage
mux_2x1_32bit operand1_mux(REG_FILE_OUT1_EX, PC_OUT_EX, OPERAND1, OP1SEL_EX);
mux_2x1_32bit operand2_mux(REG_FILE_OUT2_EX, IMM_GEN_OUT_EX, OPERAND2, OP2SEL_EX);
alu alu_unit(OPERAND1, OPERAND2, ALU_OUT, ALUOP_EX);
bj_detect bj_unit(BRANCH_JUMP_EX, REG_FILE_OUT1_EX, REG_FILE_OUT2_EX, PC_SEL);

ex_mem_pipeline_reg ex_mem_reg(WRITE_ADDRESS_EX, PC_OUT_EX, ALU_OUT,  REG_FILE_OUT2_EX,  IMM_GEN_OUT_EX, READ_WRITE_EX, WB_SEL_EX, REG_WRITE_EN_EX, WRITE_ADDRESS_MEM, PC_OUT_MEM, ALU_OUT_MEM, REG_FILE_OUT2_MEM, IMM_GEN_OUT_MEM,  READ_WRITE_MEM, WB_SEL_MEM, REG_WRITE_EN_MEM, CLK,  RESET, BUSYWAIT);

// Memory stage
adder_32bit pc_4_adder_wb(PC_OUT_MEM, PC_4_WB_OUT);
data_cache d_cache(CLK, RESET, DATA_BUSYWAIT, READ_WRITE_MEM, REG_FILE_OUT2_MEM, READDATA, ALU_OUT_MEM, DATA_MEM_BUSYWAIT, DATA_MEM_READ, DATA_MEM_WRITE, DATA_MEM_READDATA, DATA_MEM_WRITEDATA, DATA_MEM_ADDRESS);

mem_wb_pipeline_reg mem_wb_reg(WRITE_ADDRESS_MEM, PC_4_WB_OUT, ALU_OUT_MEM,  IMM_GEN_OUT_MEM, READDATA, WB_SEL_MEM, REG_WRITE_EN_MEM, WRITE_ADDRESS_WB, PC_4_WB_OUT_WB, ALU_OUT_WB, IMM_GEN_OUT_WB,  READDATA_WB, WB_SEL_WB, REG_WRITE_EN_WB, CLK,  RESET, BUSYWAIT);

// Writeback stage
mux_4x1_32bit wb_mux(ALU_OUT_WB, READDATA_WB, IMM_GEN_OUT_WB, PC_4_WB_OUT_WB, WB_MUX_OUT, WB_SEL_WB);

endmodule