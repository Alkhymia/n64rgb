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
// Company: Circuit-Board.de
// Engineer: borti4938
//
// VH-file Name:   n64a_params
// Project Name:   N64 Advanced RGB Mod
// Target Devices: several devices
// Tool versions:  Altera Quartus Prime
// Description:
//
//////////////////////////////////////////////////////////////////////////////////


parameter color_width_i = 7;
parameter color_width_o = 8;

parameter vdata_width_i = 4 + 3*color_width_i;
parameter vdata_width_o = 4 + 3*color_width_o;


`ifndef _n64a_params_vh_
`define _n64a_params_vh_

  // video vector slices and frame definitions
  // =========================================

  `define VDATA_I_FU_SLICE    vdata_width_i-1:0               // full slice
  `define VDATA_I_SY_SLICE  3*color_width_i+3:3*color_width_i // slice sync
  `define VDATA_I_CO_SLICE  3*color_width_i-1:0               // slice color
  `define VDATA_I_RE_SLICE  3*color_width_i-1:2*color_width_i // slice red
  `define VDATA_I_GR_SLICE  2*color_width_i-1:  color_width_i // slice green
  `define VDATA_I_BL_SLICE    color_width_i-1:0               // slice blue

  `define VDATA_O_FU_SLICE    vdata_width_o-1:0
  `define VDATA_O_SY_SLICE  3*color_width_o+3:3*color_width_o 
  `define VDATA_O_CO_SLICE  3*color_width_o-1:0
  `define VDATA_O_RE_SLICE  3*color_width_o-1:2*color_width_o
  `define VDATA_O_GR_SLICE  2*color_width_o-1:  color_width_o
  `define VDATA_O_BL_SLICE    color_width_o-1:0

  `define GAMMA_TABLE_OFF   4'b0101

  `define HSTART_NTSC 11'd0225
  `define HSTOP_NTSC  11'd1500
  `define HSTART_PAL  11'd0275
  `define HSTOP_PAL   11'd1550

  `define BUF_NUM_OF_PAGES    6
  `define BUF_DEPTH_PER_PAGE  (`HSTOP_NTSC - `HSTART_NTSC + 1)/2
  
  `define PIXEL_PER_LINE_2x_NTSC  1545
  `define PIXEL_PER_LINE_2x_PAL   1587
  `define PIXEL_PER_LINE_2x_MAX   1600

  `define HS_WIDTH_NTSC_240P  7'd115
  `define HS_WIDTH_NTSC_480I  7'd111
  `define HS_WIDTH_PAL_288P   7'd124
  `define HS_WIDTH_PAL_576I   7'd121

  `define VS_WIDTH  2'd2


  // N64 controller sniffing
  // =======================

  // controller serial data bits:
  //  0: 7 - A, B, Z, St, Du, Dd, Dl, Dr
  //  8:15 - 'Joystick reset', (0), L, R, Cu, Cd, Cl, Cr
  // 16:23 - X axis
  // 24:31 - Y axis
  // 32    - Stop bit

  // define constants
  // don't edit these constants

  `define A  16'h0001 // button A
  `define B  16'h0002 // button B
  `define Z  16'h0004 // trigger Z
  `define St 16'h0008 // Start button

  `define Du 16'h0010 // D-pad up
  `define Dd 16'h0020 // D-pad down
  `define Dl 16'h0040 // D-pad left
  `define Dr 16'h0080 // D-pad right

  `define L  16'h0400 // shoulder button L
  `define R  16'h0800 // shoulder button R

  `define Cu 16'h1000 // C-button up
  `define Cd 16'h2000 // C-button down
  `define Cl 16'h4000 // C-button left
  `define Cr 16'h8000 // C-button right

  // In-game reset command
  // =====================

  `define IGR_RESET (`A + `B + `Z + `St + `R)

  // Testpattern
  // ===========

  `define TESTPAT_HSTART      10'd060
  `define TESTPAT_HSTOP       10'd701
  `define TESTPAT_VSTART_NTSC  9'd005
  `define TESTPAT_VSTOP_NTSC   9'd247
  `define TESTPAT_VSTART_PAL   9'd006
  `define TESTPAT_VSTOP_PAL    9'd296

  // OSD menu window sizing
  // ======================

  // define font size (every value - 1)
  `define OSD_FONT_WIDTH  3'd7
  `define OSD_FONT_HEIGHT 4'd11

  // define text window size (every value - 1)
  `define MAX_CHARS_PER_ROW 6'd51
  `define MAX_TEXT_ROWS     4'd11

  // positioning of OSD window (not linedoubled)
  `define OSD_WINDOW_H_START  10'd160
  `define OSD_WINDOW_H_STOP   (`OSD_WINDOW_H_START + 4'd15 + (`MAX_CHARS_PER_ROW + 1'd1)*(`OSD_FONT_WIDTH + 1'd1))
  `define OSD_WINDOW_V_START  8'd50
  `define OSD_WINDOW_V_STOP   (`OSD_WINDOW_V_START + 4'd13 + (`MAX_TEXT_ROWS + 1'd1)*(`OSD_FONT_HEIGHT + 1'd1))


  // define some areas in the OSD windows
  `define OSD_TXT_H_START (`OSD_WINDOW_H_START + 3'd7)
  `define OSD_TXT_H_STOP  (`OSD_TXT_H_START + (`MAX_CHARS_PER_ROW + 1'd1)*(`OSD_FONT_WIDTH + 1'd1) + 1'd1)
  `define OSD_TXT_V_START (`OSD_WINDOW_V_START + 4'd8)
  `define OSD_TXT_V_STOP  (`OSD_TXT_V_START + (`MAX_TEXT_ROWS + 1'd1)*(`OSD_FONT_HEIGHT + 1'd1) + 1'd1)

  `define OSD_LOGO_H_START   `OSD_TXT_H_START
  `define OSD_LOGO_H_STOP    (`OSD_TXT_H_START + 10'd127)
  `define OSD_LOGO_V_START   (`OSD_TXT_V_START - 8'd4)
  `define OSD_LOGO_V_STOP    (`OSD_TXT_V_START + 8'd13)

  // define OSD background window color (three bits each color)
  `define OSD_BACKGROUND_WHITE        2'b11
  `define OSD_BACKGROUND_GREY         2'b10
  `define OSD_BACKGROUND_BLACK        2'b01
  `define OSD_BACKGROUND_DARKBLUE     2'b00

  `define OSD_WINDOW_BGCOLOR_WHITE    9'b111111111
  `define OSD_WINDOW_BGCOLOR_GREY     9'b010010010
  `define OSD_WINDOW_BGCOLOR_BLACK    9'b000000000
  `define OSD_WINDOW_BGCOLOR_DARKBLUE 9'b000000011

  // define text color
  `define FONTCOLOR_NON              4'h0
  `define FONTCOLOR_BLACK            4'h1
  `define FONTCOLOR_GREY             4'h2
  `define FONTCOLOR_LIGHTGREY        4'h3
  `define FONTCOLOR_WHITE            4'h4
  `define FONTCOLOR_RED              4'h5
  `define FONTCOLOR_GREEN            4'h6
  `define FONTCOLOR_BLUE             4'h7
  `define FONTCOLOR_YELLOW           4'h8
  `define FONTCOLOR_CYAN             4'h9
  `define FONTCOLOR_MAGENTA          4'hA
  `define FONTCOLOR_DARKORANGE       4'hB
  `define FONTCOLOR_TOMATO           4'hC
  `define FONTCOLOR_DARKMAGENTA      4'hD
  `define FONTCOLOR_NAVAJOWHITE      4'hE
  `define FONTCOLOR_DARKGOLD         4'hF

  `define OSD_TXT_COLOR_BLACK       21'h000000
  `define OSD_TXT_COLOR_GREY        21'h07CF9F
  `define OSD_TXT_COLOR_LIGHTGREY   21'h0FDFBF
  `define OSD_TXT_COLOR_WHITE       21'h1FFFFF
  `define OSD_TXT_COLOR_RED         21'h1FC000
  `define OSD_TXT_COLOR_GREEN       21'h003F80
  `define OSD_TXT_COLOR_BLUE        21'h00007F
  `define OSD_TXT_COLOR_YELLOW      21'h1FFF80
  `define OSD_TXT_COLOR_CYAN        21'h003FFF
  `define OSD_TXT_COLOR_MAGENTA     21'h1FC07F
  `define OSD_TXT_COLOR_DARKORANGE  21'h199980
  `define OSD_TXT_COLOR_TOMATO      21'h1DD721
  `define OSD_TXT_COLOR_DARKMAGENTA 21'h114045
  `define OSD_TXT_COLOR_NAVAJOWHITE 21'h1FF7D6
  `define OSD_TXT_COLOR_DARKGOLD    21'h1DEB07

  `define OSD_LOGO_COLOR `OSD_TXT_COLOR_DARKORANGE

`endif