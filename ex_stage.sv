
// Author: Florian Zaruba, ETH Zurich
// Date: 19.04.2017
// Description: Instantiation of all functional units residing in the execute stage
//
// Copyright (C) 2017 ETH Zurich, University of Bologna
// All rights reserved.
//
// This code is under development and not yet released to the public.
// Until it is released, the code is under the copyright of ETH Zurich and
// the University of Bologna, and may contain confidential and/or unpublished
// work. Any reuse/redistribution is strictly forbidden without written
// permission from ETH Zurich.
//
// Bug fixes and contributions will eventually be released under the
// SolderPad open hardware license in the context of the PULP platform
// (http://www.pulp-platform.org), under the copyright of ETH Zurich and the
// University of Bologna.
//
import ariane_pkg::*;

module ex_stage #(
        parameter int ASID_WIDTH = 1
    )(
    input  logic                                   clk_i,    // Clock
    input  logic                                   rst_ni,   // Asynchronous reset active low

    input  fu_op                                   operator_i,
    input  logic [63:0]                            operand_a_i,
    input  logic [63:0]                            operand_b_i,
    input  logic [63:0]                            imm_i,
    input  logic [TRANS_ID_BITS-1:0]               trans_id_i,

    // ALU 1
    output logic                                   alu_ready_o,      // FU is ready
    input  logic                                   alu_valid_i,      // Output is valid
    output logic                                   alu_valid_o,      // ALU result is valid
    output logic [63:0]                            alu_result_o,
    output logic [TRANS_ID_BITS-1:0]               alu_trans_id_o,       // ID of scoreboard entry at which to write back
    output logic                                   comparison_result_o,
    // LSU
    output logic                                   lsu_ready_o,      // FU is ready
    input  logic                                   lsu_valid_i,      // Input is valid
    output logic                                   lsu_valid_o,      // Output is valid
    output logic [63:0]                            lsu_result_o,
    output logic [TRANS_ID_BITS-1:0]               lsu_trans_id_o,
    // memory management
    input  logic                                   enable_translation_i,
    input  logic                                   fetch_req_i,
    output logic                                   fetch_gnt_o,
    output logic                                   fetch_valid_o,
    output logic                                   fetch_err_o,
    input  logic [63:0]                            fetch_vaddr_i,
    output logic [31:0]                            fetch_rdata_o,
    input  priv_lvl_t                              priv_lvl_i,
    input  logic                                   flag_pum_i,
    input  logic                                   flag_mxr_i,
    input  logic [19:0]                            pd_ppn_i,
    input  logic [ASID_WIDTH-1:0]                  asid_i,
    input  logic                                   flush_tlb_i,
    mem_if.Slave                                   instr_if,
    mem_if.Slave                                   data_if,

    // MULT
    output logic                                   mult_ready_o,      // FU is ready
    input  logic                                   mult_valid_i       // Output is valid
);


    // ALU is a single cycle instructions, hence it is always ready
    assign alu_ready_o = 1'b1;
    assign alu_valid_o = alu_valid_i;
    assign alu_trans_id_o = trans_id_i;

    alu alu_i (
        .operator_i          ( operator_i          ),
        .operand_a_i         ( operand_a_i         ),
        .operand_b_i         ( operand_b_i         ),
        .adder_result_o      (                     ),
        .adder_result_ext_o  (                     ),
        .result_o            ( alu_result_o        ),
        .comparison_result_o ( comparison_result_o ),
        .is_equal_result_o   (                     )
    );

    // Multiplication

    // Load-Store Unit

    assign lsu_valid_o = 1'b0;
    assign lsu_trans_id_o = trans_id_i;


    exception lsu_exception_o;

    lsu i_lsu (
        .clk_i                ( clk_i           ),
        .rst_ni               ( rst_ni           ),
        .data_req_o           ( data_req_o      ),
        .data_gnt_i           ( data_gnt_i      ),
        .data_rvalid_i        ( data_rvalid_i   ),
        .data_err_i           ( data_err_i      ),
        .data_addr_o          ( data_addr_o     ),
        .data_we_o            ( data_we_o       ),
        .data_be_o            ( data_be_o       ),
        .data_wdata_o         ( data_wdata_o    ),
        .data_rdata_i         ( data_rdata_i    ),
        .operator_i           ( operator_i      ),
        .operand_a_i          ( operand_a_i     ),
        .operand_b_i          ( operand_b_i     ),
        .lsu_ready_o          ( lsu_ready_o     ),
        .lsu_valid_i          ( lsu_valid_i     ),
        .lsu_trans_id_i       ( trans_id_i      ),
        .lsu_trans_id_o       ( lsu_trans_id_o  ),
        .lsu_valid_o          ( lsu_valid_o     ),

        .enable_translation_i ( enable_translation_i ),
        .fetch_req_i          ( fetch_req_i          ),
        .fetch_gnt_o          ( fetch_gnt_o          ),
        .fetch_valid_o        ( fetch_valid_o        ),
        .fetch_err_o          ( fetch_err_o          ),
        .fetch_vaddr_i        ( fetch_vaddr_i        ),
        .fetch_rdata_o        ( fetch_rdata_o        ),
        .priv_lvl_i           ( priv_lvl_i           ),
        .flag_pum_i           ( flag_pum_i           ),
        .flag_mxr_i           ( flag_mxr_i           ),
        .pd_ppn_i             ( pd_ppn_i             ),
        .asid_i               ( asid_i               ),
        .flush_tlb_i          ( flush_tlb_i          ),
        .instr_if             ( instr_if             ),
        .data_if              ( data_if              ),

        .lsu_exception_o ( lsu_exception_o )  // TODO: exception
    );

    // pass through


endmodule