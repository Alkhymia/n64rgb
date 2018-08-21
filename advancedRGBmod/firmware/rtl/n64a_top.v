//////////////////////////////////////////////////////////////////////////////////
//
// This file is part of the N64 RGB/YPbPr DAC project.
//
// Copyright (C) 2016-2018 by Peter Bartmann <borti4938@gmx.de>
//
// N64 RGB/YPbPr DAC is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
//////////////////////////////////////////////////////////////////////////////////
//
// Company:  Circuit-Board.de
// Engineer: borti4938
//
// Module Name:    n64a_top
// Project Name:   N64 Advanced RGB/YPbPr DAC Mod
// Target Devices: Cyclone IV:    EP4CE6E22   , EP4CE10E22
//                 Cyclone 10 LP: 10CL006YE144, 10CL010YE144
// Tool versions:  Altera Quartus Prime
// Description:
//
// Dependencies: vh/n64a_params.vh
//               rtl/n64a_controller.v
//               rtl/n64_vinfo_ext.v
//               rtl/n64_deblur.v
//               rtl/n64a_vdemux.v
//               rtl/n64a_gamma_module.v
//               rtl/n64a_linedbl.v
//               rtl/n64a_vconv.v
// (more dependencies may appear in other files)
//
// Revision: 2.08
// Features: see repository readme
//
//////////////////////////////////////////////////////////////////////////////////


module n64a_top (
  // N64 Video Input
  VCLK,
  nDSYNC,
  D_i,

  // System CLK, Controller and Reset
  SYS_CLK,
  SYS_CLKen,
  CTRL_i,
  nRST,

  // Video Output to ADV712x
     CLK_ADV712x,
  nCSYNC_ADV712x,
//   nBLANK_ADV712x,
  V3_o,     // video component data vector 3 (B or Pr)
  V2_o,     // video component data vector 2 (G or Y)
  V1_o,     // video component data vector 1 (R or Pb)

  // Sync / Debug / Filter AddOn Output
  nCSYNC,
  nVSYNC_or_F2,
  nHSYNC_or_F1,

  // Jumper VGA Sync / Filter AddOn
  UseVGA_HVSync, // (J1) use Filter out if '0'; use /HS and /VS if '1'
  nFilterBypass, // (J1) bypass filter if '0'; set filter as output if '1'
                 //      (only applicable if UseVGA_HVSync is '0')

  // Jumper Video Output Type and Scanlines
  nEN_RGsB,   // (J2) generate RGsB if '0'
  nEN_YPbPr,  // (J2) generate RGsB if '0' (no RGB, no RGsB (overrides nEN_RGsB))
  SL_str,     // (J3) Scanline strength    (only for line multiplication and not for 480i bob-deint.)
  n240p,      // (J4) no linemultiplication for 240p if '0' (beats n480i_bob)
  n480i_bob   // (J4) bob de-interlacing of 480i material if '0'

);

parameter [3:0] hdl_fw_main = 4'd2;
parameter [7:0] hdl_fw_sub  = 8'd21;

`include "vh/n64a_params.vh"

input                     VCLK;
input                     nDSYNC;
input [color_width_i-1:0] D_i;

input  SYS_CLK;
output SYS_CLKen;
input  CTRL_i;
inout  nRST;

output                        CLK_ADV712x;
output                     nCSYNC_ADV712x;
// output                     nBLANK_ADV712x;
output [color_width_o-1:0] V3_o;
output [color_width_o-1:0] V2_o;
output [color_width_o-1:0] V1_o;

output nCSYNC;
output nVSYNC_or_F2;
output nHSYNC_or_F1;

input UseVGA_HVSync;
input nFilterBypass;

input       nEN_RGsB;
input       nEN_YPbPr;
input [1:0] SL_str;
input       n240p;
input       n480i_bob;


// start of rtl

// Part 1: connect controller module
// =================================

assign SYS_CLKen = 1'b1;

wire vmode    = vinfo_pass[1];
wire n64_480i = vinfo_pass[0];

wire [ 3:0] InfoSet = {vmode,n64_480i,~ndo_deblur,UseVGA_HVSync};
wire [ 6:0] JumperCfgSet = {nFilterBypass,n240p,~n480i_bob,~SL_str,~nEN_YPbPr,(nEN_YPbPr & ~nEN_RGsB)}; // (~nEN_YPbPr | nEN_RGsB) ensures that not both jumpers are set and passed through the NIOS II
wire [47:0] OutConfigSet;
// general structure [47:32] video settings, [31:16] 240p settings, [15:0] 480i settings
// [47:40] {sl_in_osd,(3bits reserve),FilterSet (2bit),YPbPr,RGsB}
// [39:32] {gamma (4bits),(1bit reserve),VI-DeBlur (2bit), 15bit mode}
// [31:16] {(2bits reserve),lineX2,Sl_hybrid_depth (5bits),Sl_str (4bits),(1bit reserve),Sl_Method,Sl_ID,Sl_En}
// [15: 0] {(2bits reserve),lineX2,Sl_hybrid_depth (5bits),Sl_str (4bits),(1bit reserve),Sl_link,Sl_ID,Sl_En}

n64a_controller #({hdl_fw_main,hdl_fw_sub}) controller_u(
  .SYS_CLK(SYS_CLK),
  .nRST(nRST),
  .CTRL(CTRL_i),
  .InfoSet(InfoSet),
  .JumperCfgSet(JumperCfgSet),
  .OutConfigSet(OutConfigSet),
  .VCLK(VCLK),
  .nDSYNC(nDSYNC),
  .video_data_i(vdata_r[2]),
  .video_data_o(vdata_r[3])
);



wire       cfg_OSD_SL    =  OutConfigSet[47];
wire [1:0] FilterSetting =  OutConfigSet[43:42];
wire       cfg_nEN_YPbPr = ~OutConfigSet[41];
wire       cfg_nEN_RGsB  = ~OutConfigSet[40];
wire [3:0] cfg_gamma     =  OutConfigSet[39:36];
wire       nDeBlurMan    = ~OutConfigSet[34];
wire       nForceDeBlur  = ~|OutConfigSet[34:33];
wire       n15bit_mode   = ~OutConfigSet[32];

wire       cfg_lineX2    =       ~n64_480i ? OutConfigSet[29   ] : OutConfigSet[13   ];
wire [4:0] cfg_SLHyb_str =       ~n64_480i ? OutConfigSet[28:24] :
                           OutConfigSet[2] ? OutConfigSet[28:24] : OutConfigSet[12: 8];
wire [3:0] cfg_SL_str    =       ~n64_480i ? OutConfigSet[23:20] :
                           OutConfigSet[2] ? OutConfigSet[23:20] : OutConfigSet[ 7: 4];
wire       cfg_SL_method =       ~n64_480i ? OutConfigSet[18   ] : 1'b0;
wire       cfg_SL_id     =       ~n64_480i ? OutConfigSet[17   ] :
                           OutConfigSet[2] ? OutConfigSet[17   ] : OutConfigSet[ 1   ] ;
wire       cfg_SL_en     =       ~n64_480i ? OutConfigSet[16   ] : OutConfigSet[ 0   ] ;

reg nVRST_pre = 1'b0;
reg nVRST = 1'b0;

always @(posedge VCLK) begin
  nVRST <= nVRST_pre;
  nVRST_pre <= nRST;
end


// Part 2 - 4: RGB Demux with De-Blur Add-On
// =========================================
//
// short description of N64s RGB and sync data demux
// -------------------------------------------------
//
// pulse shapes and their realtion to each other:
// VCLK (~50MHz, Numbers representing negedge count)
// ---. 3 .---. 0 .---. 1 .---. 2 .---. 3 .---
//    |___|   |___|   |___|   |___|   |___|
// nDSYNC (~12.5MHz)                           .....
// -------.       .-------------------.
//        |_______|                   |_______
//
// more info: http://members.optusnet.com.au/eviltim/n64rgb/n64rgb.html
//


// Part 2: get all of the vinfo needed for further processing
// ==========================================================

wire [3:0] vinfo_pass;

n64_vinfo_ext get_vinfo(
  .VCLK(VCLK),
  .nDSYNC(nDSYNC),
  .Sync_pre(vdata_r[0][`VDATA_I_SY_SLICE]),
  .Sync_cur(D_i[3:0]),
  .vinfo_o(vinfo_pass)
);


// Part 3: DeBlur Management (incl. heuristic)
// ===========================================

wire ndo_deblur;

n64_deblur deblur_management(
  .VCLK(VCLK),
  .nDSYNC(nDSYNC),
  .nRST(nVRST),
  .vdata_pre(vdata_r[0]),
  .D_i(D_i),
  .deblurparams_i({vinfo_pass,nForceDeBlur,nDeBlurMan}),
  .ndo_deblur(ndo_deblur)
);


// Part 4: data demux
// ==================

wire [`VDATA_I_FU_SLICE] vdata_r[0:3];

n64a_vdemux video_demux(
  .VCLK(VCLK),
  .nDSYNC(nDSYNC),
  .nRST(nVRST),
  .D_i(D_i),
  .demuxparams_i({vinfo_pass[3:1],ndo_deblur,n15bit_mode}),
  .gammaparams_i(cfg_gamma),
  .vdata_r_0(vdata_r[0]),
  .vdata_r_1(vdata_r[1]),
  .vdata_r_6(vdata_r[2])
);

// Part 5: Post-Processing
// =======================

// Part 5.1: Line Multiplier
// =========================

wire nENABLE_linedbl = ~cfg_lineX2 | ~nRST;

wire [15:0] vinfo_dbl = {nENABLE_linedbl,cfg_OSD_SL,cfg_SLHyb_str,cfg_SL_str,cfg_SL_method,cfg_SL_id,cfg_SL_en,vinfo_pass[1:0]};

wire [vdata_width_o-1:0] vdata_tmp;

n64a_linedbl linedoubler(
  .VCLK(VCLK),
  .nRST(nVRST),
  .vinfo_dbl(vinfo_dbl),
  .vdata_i(vdata_r[3]),
  .vdata_o(vdata_tmp)
);


// Part 5.2: Color Transformation
// ==============================

wire [3:0] Sync_o;

n64a_vconv video_converter(
  .VCLK(VCLK),
  .nEN_YPbPr(cfg_nEN_YPbPr),    // enables color transformation on '0'
  .vdata_i(vdata_tmp),
  .vdata_o({Sync_o,V1_o,V2_o,V3_o})
);

// Part 5.3: assign final outputs
// ===========================
assign    CLK_ADV712x = VCLK;
assign nCSYNC_ADV712x = cfg_nEN_RGsB & cfg_nEN_YPbPr ? 1'b0  : Sync_o[0];
// assign nBLANK_ADV712x = Sync_o[2];

// Filter Add On:
// =============================
//
// Filter setting from NIOS II core:
// - 00: Auto
// - 01: 9.5MHz
// - 10: 18.0MHz
// - 11: Bypassed (i.e. 72MHz)
//
// FILTER 1 | FILTER 2 | DESCRIPTION
// ---------+----------+--------------------
//      0   |     0    |  SD filter ( 9.5MHz)
//      0   |     1    |  ED filter (18.0MHz)
//      1   |     0    |  HD filter (36.0MHz)
//      1   |     1    | FHD filter (72.0MHz)
//
// (Bypass SF is hard wired to 1)

reg [1:2] Filter;

always @(posedge VCLK)
  Filter <= FilterSetting   == 2'b11 ? 2'b11 :        // bypassed
            FilterSetting   == 2'b10 ? 2'b01 :        // 18.0MHz
            FilterSetting   == 2'b01 ? 2'b00 :        // 9.5MHz
            nENABLE_linedbl == 1'b0  ? 2'b01 : 2'b00; // Auto (18.0MHz in LineX2 and 9.5MHz else)

assign nCSYNC       = Sync_o[0];

assign nVSYNC_or_F2 = UseVGA_HVSync ? Sync_o[3] : Filter[2];
assign nHSYNC_or_F1 = UseVGA_HVSync ? Sync_o[1] : Filter[1];

endmodule
