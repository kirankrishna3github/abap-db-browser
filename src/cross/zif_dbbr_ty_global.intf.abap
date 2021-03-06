"! <p class="shorttext synchronized" lang="en">Global Type definitions for DB Browser</p>
INTERFACE zif_dbbr_ty_global
  PUBLIC .
  TYPES:
    "! <p class="shorttext synchronized" lang="en">Text Field status</p>
    BEGIN OF ty_s_text_field,
      alv_fieldname TYPE fieldname,
      visible       TYPE abap_bool,
      new_field     TYPE abap_bool,
    END OF ty_s_text_field,
    ty_t_text_field TYPE STANDARD TABLE OF ty_s_text_field WITH EMPTY KEY.

  TYPES:
    BEGIN OF ty_s_sel_option,
      sign   TYPE ddsign,
      option TYPE ddoption,
      icon   TYPE c LENGTH 40,
      text   TYPE iconquick,
    END OF ty_s_sel_option,

    ty_t_sel_option TYPE STANDARD TABLE OF ty_s_sel_option WITH EMPTY KEY.
ENDINTERFACE.
