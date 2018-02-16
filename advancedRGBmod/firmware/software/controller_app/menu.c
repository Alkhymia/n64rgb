/*********************************************************************************
 *
 * This file is part of the N64 RGB/YPbPr DAC project.
 *
 * Copyright (C) 2016-2018 by Peter Bartmann <borti4938@gmx.de>
 *
 * N64 RGB/YPbPr DAC is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 *********************************************************************************
 *
 * menu.c
 *
 *  Created on: 09.01.2018
 *      Author: Peter Bartmann
 *
 ********************************************************************************/


#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include "alt_types.h"
#include "altera_avalon_pio_regs.h"
#include "system.h"
#include "n64.h"
#include "config.h"
#include "menu.h"

#include "menu_text/textdefs_p.h"
#include "vd_driver.h"



#define OPT_WINDOWCOLOR_BG    BACKGROUNDCOLOR_WHITE
#define OPT_WINDOWCOLOR_FONT  FONTCOLOR_BLACK

#define SUBMENU_ARROW_L   ARROW_RIGHT
#define OPT_ARROW_L       TRIANGLE_LEFT
#define OPT_ARROW_R       TRIANGLE_RIGHT
#define OPT_WINDOW_WIDTH  13

extern alt_u8 use_flash;

inline alt_u8 is_cfg_screen (menu_t *menu) /* ugly hack (ToDo on updates: check for validity, i.e. is this property still unique) */
  {  return (menu->leaves[0].config_value->flag_masks.clrflag_mask == CFG_LINEX2_CLRMASK); }


static const arrow_t selection_arrow = {
    .arrowshape_left  = SUBMENU_ARROW_L,
    .arrowshape_right = SUBMENU_ARROW_L,
    .larrow_hpos = 1,
    .rarrow_hpos = 1
};

static const arrow_t cfg_screen_arrow = {
    .arrowshape_left  = OPT_ARROW_L,
    .arrowshape_right = OPT_ARROW_R,
    .larrow_hpos = (CFG_VALS_H_OFFSET - 2),
    .rarrow_hpos = (CFG_VALS_H_OFFSET + OPT_WINDOW_WIDTH - 2)
};

static const arrow_t misc_screen_arrow = {
    .arrowshape_left  = OPT_ARROW_L,
    .arrowshape_right = OPT_ARROW_R,
    .larrow_hpos = (MISC_VALS_H_OFFSET - 2),
    .rarrow_hpos = (MISC_VALS_H_OFFSET + OPT_WINDOW_WIDTH - 2)
};


extern config_t linex2, deint480ibob, sl_str, vformat, deblur, mode15bit, gamma_lut;

menu_t cfg_screen = {
    .type = CONFIG,
    .header = &cfg_header,
    .overlay = &cfg_overlay,
    .parent = &home_menu,
    .current_selection = 0,
    .number_selections = 7,
    .leaves = { /* ToDo: assign leave_numbers ??? (e.g. usable if selection is checked) */
        {.id = CFG_LINEX2_V_OFFSET , .arrow_desc = &cfg_screen_arrow, .leavetype = ICONFIG, .config_value = &linex2},
        {.id = CFG_480IBOB_V_OFFSET, .arrow_desc = &cfg_screen_arrow, .leavetype = ICONFIG, .config_value = &deint480ibob},
        {.id = CFG_SLSTR_V_OFFSET  , .arrow_desc = &cfg_screen_arrow, .leavetype = ICONFIG, .config_value = &sl_str},
        {.id = CFG_FORMAT_V_OFFSET , .arrow_desc = &cfg_screen_arrow, .leavetype = ICONFIG, .config_value = &vformat},
        {.id = CFG_DEBLUR_V_OFFSET , .arrow_desc = &cfg_screen_arrow, .leavetype = ICONFIG, .config_value = &deblur},
        {.id = CFG_15BIT_V_OFFSET  , .arrow_desc = &cfg_screen_arrow, .leavetype = ICONFIG, .config_value = &mode15bit},
        {.id = CFG_GAMMA_V_OFFSET  , .arrow_desc = &cfg_screen_arrow, .leavetype = ICONFIG, .config_value = &gamma_lut}
    }
};


extern config_t igr_reset, igr_quickchange;

menu_t misc_screen = {
    .type = CONFIG,
    .header = &misc_header,
    .overlay = &misc_overlay,
    .parent = &home_menu,
    .current_selection = 0,
    .number_selections = 2,
    .leaves = {
        {.id = MISC_IGR_RESET_V_OFFSET, .arrow_desc = &misc_screen_arrow, .leavetype = ICONFIG, .config_value = &igr_reset},
        {.id = MISC_IGR_QUICK_V_OFFSET, .arrow_desc = &misc_screen_arrow, .leavetype = ICONFIG, .config_value = &igr_quickchange}
    }
};


menu_t rwdata_screen = {
    .type = RWDATA,
    .header = &rwdata_header,
    .overlay = &rwdata_overlay,
    .parent = &home_menu,
    .current_selection = 0,
    .number_selections = 4,
    .leaves = {
        {.id = RWDATA_SAVE_FL_V_OFFSET , .arrow_desc = &selection_arrow, .leavetype = IFLASHFUNC, .save_fun = &cfg_save_to_flash},
        {.id = RWDATA_LOAD_FL_V_OFFSET , .arrow_desc = &selection_arrow, .leavetype = IFLASHFUNC, .load_fun = &cfg_load_from_flash},
        {.id = RWDATA_LOAD_JS_V_OFFSET , .arrow_desc = &selection_arrow, .leavetype = IFUNC, .load_fun = &cfg_load_jumperset},
        {.id = RWDATA_LOAD_N64_V_OFFSET, .arrow_desc = &selection_arrow, .leavetype = IFUNC, .load_fun = &cfg_load_n64defaults}
    }
};


menu_t vinfo_screen = {
    .type = VINFO,
    .header = &vinfo_header,
    .overlay = &vinfo_overlay,
    .parent = &home_menu
};

menu_t about_screen = {
   .type = TEXT,
   .overlay = &about_overlay,
   .parent = &home_menu
};

menu_t thanks_screen = {
   .type = TEXT,
   .overlay = &thanks_overlay,
   .parent = &home_menu
};

menu_t license_screen = {
   .type = TEXT,
   .overlay = &license_overlay,
   .parent = &home_menu
};

menu_t home_menu = {
    .type = HOME,
    .header  = &home_header,
    .overlay = &home_overlay,
    .current_selection = 1,
    .number_selections = 7,
    .leaves = {
        {.id = MAIN2VINFO_V_OFFSET  , .arrow_desc = &selection_arrow, .leavetype = ISUBMENU, .submenu = &vinfo_screen},
        {.id = MAIN2CFG_V_OFFSET    , .arrow_desc = &selection_arrow, .leavetype = ISUBMENU, .submenu = &cfg_screen},
        {.id = MAIN2MISC_V_OFFSET   , .arrow_desc = &selection_arrow, .leavetype = ISUBMENU, .submenu = &misc_screen},
        {.id = MAIN2SAVE_V_OFFSET   , .arrow_desc = &selection_arrow, .leavetype = ISUBMENU, .submenu = &rwdata_screen},
        {.id = MAIN2ABOUT_V_OFFSET  , .arrow_desc = &selection_arrow, .leavetype = ISUBMENU, .submenu = &about_screen},
        {.id = MAIN2THANKS_V_OFFSET , .arrow_desc = &selection_arrow, .leavetype = ISUBMENU, .submenu = &thanks_screen},
        {.id = MAIN2LICENSE_V_OFFSET, .arrow_desc = &selection_arrow, .leavetype = ISUBMENU, .submenu = &license_screen}
    }
};

updateaction_t apply_command(cmd_t command, menu_t* *current_menu, configuration_t* sysconfig)
{
  alt_u8 id = (*current_menu)->current_selection;

  if ((command == CMD_CLOSE_MENU)) {
    while ((*current_menu)->parent) {
      (*current_menu)->current_selection = 0;
      *current_menu = (*current_menu)->parent;
    }
    (*current_menu)->current_selection = 1;
    return MENU_CLOSE;
  }

  if ((*current_menu)->type == HOME) {
    switch (command) {
      case CMD_MENU_RIGHT:
      case CMD_MENU_ENTER:
        if ((*current_menu)->leaves[id].submenu) {
          *current_menu = (*current_menu)->leaves[id].submenu;
          return NEW_OVERLAY;
        }
        break;
      case CMD_MENU_BACK:
        (*current_menu)->current_selection = 1;
        return MENU_CLOSE;
      default:
        break;
    }
  } else {
    switch (command) {
      case CMD_MENU_BACK:
        (*current_menu)->current_selection = 0;
        *current_menu = (*current_menu)->parent;
        return NEW_OVERLAY;
      default:
        break;
    }
  }

  if (((*current_menu)->type == TEXT) ||
      ((*current_menu)->type == VINFO)  )
    return NON;

  updateaction_t todo = NON;

  switch (command) {
    case CMD_MENU_DOWN:
      (*current_menu)->current_selection++;
      if ((*current_menu)->current_selection == (*current_menu)->number_selections)
        (*current_menu)->current_selection = 0;
      todo = NEW_SELECTION;
      break;
    case CMD_MENU_UP:
      if ((*current_menu)->current_selection == 0)
        (*current_menu)->current_selection =  (*current_menu)->number_selections - 1;
      else
        (*current_menu)->current_selection--;
      todo = NEW_SELECTION;
      break;
    default:
      break;
  }

  if (todo == NEW_SELECTION) {
    if (is_cfg_screen(*current_menu) && (!cfg_get_value((*current_menu)->leaves[0].config_value))) {
      if ((*current_menu)->current_selection == 1) (*current_menu)->current_selection = 3;
      if ((*current_menu)->current_selection == 2) (*current_menu)->current_selection = 0;
    }
    return todo;
  }

  if ((*current_menu)->type != CONFIG) {
    if (command == CMD_MENU_BACK) {
      (*current_menu)->current_selection = 0;
      *current_menu = (*current_menu)->parent;
      return NEW_OVERLAY;
    }
  }

  if ((*current_menu)->type == CONFIG) {
    switch (command) {
      case CMD_MENU_RIGHT:
        cfg_inc_value((*current_menu)->leaves[id].config_value);
        return NEW_CONF_VALUE;
      case CMD_MENU_LEFT:
        cfg_dec_value((*current_menu)->leaves[id].config_value);
        return NEW_CONF_VALUE;
      default:
        break;
    }
  }

  if ((*current_menu)->type == RWDATA) {
    if ((command == CMD_MENU_RIGHT) || (command == CMD_MENU_ENTER)) {
      int retval = -1;
      if (use_flash || ((*current_menu)->leaves[id].leavetype != IFLASHFUNC))
        retval = (*current_menu)->leaves[id].load_fun(sysconfig);
      return (retval == 0 ? RW_DONE : RW_FAILED);
    }
  }

  return NON;
}

void print_overlay(menu_t* current_menu)
{
  alt_u8 h_run;
  alt_u8 overlay_h_offset = (current_menu->type == TEXT) ? TEXTOVERLAY_H_OFFSET : HOMEOVERLAY_H_OFFSET;
  alt_u8 overlay_v_offset = 0;

  VD_CLEAR_SCREEN;

  if (current_menu->header) {
    overlay_v_offset = OVERLAY_V_OFFSET_WH;
    vd_print_string(HEADER_H_OFFSET,0,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_DARKMAGENTA,*current_menu->header);
    for (h_run = 0; h_run < VD_WIDTH; h_run++)
      vd_print_char(h_run,1,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_NAVAJOWHITE,(char) HEADER_UNDERLINE);
  }
  vd_print_string(overlay_h_offset,overlay_v_offset,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,*current_menu->overlay);

  if (current_menu->type == HOME) vd_print_string(BTN_OVERLAY_0_H_OFFSET,BTN_OVERLAY_0_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_GREEN,btn_overlay_0);
  if (current_menu->type == RWDATA) vd_print_string(BTN_OVERLAY_0_H_OFFSET,BTN_OVERLAY_0_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_GREEN,btn_overlay_1);

  switch (current_menu->type) {
    case HOME:
    case CONFIG:
    case VINFO:
    case RWDATA:
      vd_print_string(COPYRIGHT_H_OFFSET,COPYRIGHT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_DARKMAGENTA,copyright_note);
      vd_print_char(COPYRIGHT_SIGN_H_OFFSET,COPYRIGHT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_DARKMAGENTA,(char) COPYRIGHT_SIGN);
      for (h_run = 0; h_run < VD_WIDTH; h_run++)
        vd_print_char(h_run,VD_HEIGHT-2,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_NAVAJOWHITE,(char) HOME_LOWSEC_UNDERLINE);
      break;
    case TEXT:
      if (&(*current_menu->overlay) == &license_overlay)
        vd_print_char(CR_SIGN_LICENSE_H_OFFSET,CR_SIGN_LICENSE_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,(char) COPYRIGHT_SIGN);
      break;
    default:
      break;
  }
}

void print_selection_arrow(menu_t* current_menu)
{
  alt_u8 h_l_offset, h_r_offset;
  alt_u8 v_run, v_offset;

  for (v_run = 0; v_run < current_menu->number_selections; v_run++) {
    h_l_offset = current_menu->leaves[v_run].arrow_desc->larrow_hpos;
    h_r_offset = current_menu->leaves[v_run].arrow_desc->rarrow_hpos;
    v_offset   = current_menu->leaves[v_run].id;
    if (v_run == current_menu->current_selection) {
      vd_print_char(h_l_offset,v_offset,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,(char) current_menu->leaves[v_run].arrow_desc->arrowshape_left);
      vd_print_char(h_r_offset,v_offset,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,(char) current_menu->leaves[v_run].arrow_desc->arrowshape_right);
    } else {
      vd_clear_char(h_l_offset,v_offset);
      vd_clear_char(h_r_offset,v_offset);
    }
  }
}

int update_vinfo_screen(menu_t* current_menu, configuration_t* sysconfig, alt_u8 info_data)
{
  if (current_menu->type != VINFO) return -1;

  alt_u8 str_select;
  static alt_u8 video_sd_ed;

  // Video Input
  str_select = ((info_data & (INFO_480I_GETMASK | INFO_VMODE_GETMASK)) >> INFO_VMODE_OFFSET);
  vd_clear_lineend(INFO_VALS_H_OFFSET,INFO_VIN_V_OFFSET);
  vd_print_string(INFO_VALS_H_OFFSET,INFO_VIN_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,VideoMode[str_select]);

  // Video Output
  switch((((sysconfig->cfg_word_def[VIDEO]->cfg_word_val & (CFG_LINEX2_GETMASK | CFG_480IBOB_GETMASK)) >> (CFG_480IBOB_OFFSET - 2)) | str_select) & 0xF) {
   /* order: lineX2, 480ibob, 480i, pal */
    case 0xF: /* 1111 */
    case 0xD: /* 1101 */
    case 0x9: /* 1001 */
      str_select  = 5;
      video_sd_ed = 1;
      break;
    case 0xE: /* 1110 */
    case 0xC: /* 1100 */
    case 0x8: /* 1000 */
      str_select  = 4;
      video_sd_ed = 1;
      break;
    default :
      video_sd_ed = 0;
      break;
  }
  vd_clear_lineend(INFO_VALS_H_OFFSET,INFO_VOUT_V_OFFSET);
  vd_print_string(INFO_VALS_H_OFFSET,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,VideoMode[str_select]);

  // Color Depth
  str_select = (sysconfig->cfg_word_def[MISC]->cfg_word_val & CFG_15BITMODE_GETMASK) >> CFG_15BITMODE_OFFSET;
  vd_clear_lineend(INFO_VALS_H_OFFSET,INFO_COL_V_OFFSET);
  vd_print_string(INFO_VALS_H_OFFSET,INFO_COL_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,VideoColor[str_select]);

  // Video Format
  if (sysconfig->cfg_word_def[VIDEO]->cfg_word_val & CFG_YPBPR_GETMASK)
    str_select = 2;
  else
    str_select = (sysconfig->cfg_word_def[VIDEO]->cfg_word_val & CFG_RGSB_GETMASK) >> CFG_RGSB_OFFSET;
  vd_clear_lineend(INFO_VALS_H_OFFSET,INFO_FORMAT_V_OFFSET);
  vd_print_string(INFO_VALS_H_OFFSET,INFO_FORMAT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,VideoFormat[str_select]);

  // 240p DeBlur
  vd_clear_lineend(INFO_VALS_H_OFFSET, INFO_DEBLUR_V_OFFSET);
  if (info_data & INFO_480I_GETMASK) {
    str_select = 2;
    vd_print_string(INFO_VALS_H_OFFSET,INFO_DEBLUR_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_GREY,DeBlur[str_select]);
  } else {
    str_select = (info_data & INFO_DODEBLUR_GETMASK) >> INFO_DODEBLUR_OFFSET;
    vd_print_string(INFO_VALS_H_OFFSET, INFO_DEBLUR_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,OffOn[str_select]);
    str_select = (((sysconfig->cfg_word_def[MISC]->cfg_word_val & CFG_DEBLUR_GETMASK) >> CFG_DEBLUR_OFFSET) > 0);
    vd_print_string(INFO_VALS_H_OFFSET + 4,INFO_DEBLUR_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,DeBlur[str_select]);
  }

  // Filter Add-on
  if (info_data & INFO_USEVGA_GETMASK)
    str_select = 0;
  else if (info_data & INFO_FILTERNBYPASS_GETMASK)
    str_select = video_sd_ed + 1;
  else
    str_select = 3;
  vd_clear_lineend(INFO_VALS_H_OFFSET,INFO_FAO_V_OFFSET);
  vd_print_string(INFO_VALS_H_OFFSET,INFO_FAO_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE, FilterAddOn[str_select]);

  return 0;
}


int update_cfg_screen(menu_t* current_menu)
{
  if (current_menu->type != CONFIG) return -1;

  alt_u8 h_l_offset, h_r_offset;
  alt_u8 v_run, v_offset;
  alt_u8 background_color, font_color;
  alt_u16 val_select;

  for (v_run = 0; v_run < current_menu->number_selections; v_run++) {
    h_l_offset = current_menu->leaves[v_run].arrow_desc->larrow_hpos + 2;
    h_r_offset = current_menu->leaves[v_run].arrow_desc->rarrow_hpos - 2;
    v_offset   = current_menu->leaves[v_run].id;

//    if (current_menu->current_selection == v_run) {
//      background_color = OPT_WINDOWCOLOR_BG;
//      font_color = OPT_WINDOWCOLOR_FONT;
//    } else {
      background_color = BACKGROUNDCOLOR_STANDARD;
      font_color = FONTCOLOR_WHITE;
//    }

    if (is_cfg_screen(current_menu) && ((v_run == 1) || (v_run == 2)) &&
        (!cfg_get_value(current_menu->leaves[0].config_value))    )
      font_color = FONTCOLOR_GREY;

    if (v_run == current_menu->current_selection)
      vd_clear_area(h_l_offset,h_r_offset,v_offset,v_offset);
    val_select = cfg_get_value(current_menu->leaves[v_run].config_value);
    vd_print_string(h_l_offset,v_offset,background_color,font_color,current_menu->leaves[v_run].config_value->value_string[val_select]);
  }

  return 0;
}