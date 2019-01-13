"! <p class="shorttext synchronized" lang="en">Controller for data selection screen</p>
CLASS zcl_dbbr_selscreen_controller DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC

  GLOBAL FRIENDS zcl_dbbr_selscreen_util .

  PUBLIC SECTION.
    INTERFACES zif_uitb_screen_controller .

    ALIASES load_context_menu
      FOR zif_uitb_screen_controller~load_context_menu .
    ALIASES pbo
      FOR zif_uitb_screen_controller~pbo .
    ALIASES set_status
      FOR zif_uitb_screen_controller~set_status .

    METHODS call_alv_variant_f4 .
    METHODS call_f4_help
      IMPORTING
        !if_for_low TYPE boolean .
    METHODS call_table_f4
      IMPORTING
        !iv_dynp_field_name TYPE devparname
      CHANGING
        !cv_table           TYPE tabname .
    METHODS check_alv_variant .
    METHODS check_edit_mode .
    "! <p class="shorttext synchronized" lang="en">Check the entered Entity</p>
    METHODS check_entity .
    METHODS constructor
      IMPORTING
        !iv_mode                TYPE zdbbr_selscreen_mode
        !ir_selection_table     TYPE REF TO zcl_dbbr_selscreen_table
        !is_settings            TYPE zdbbr_selscreen_settings OPTIONAL
        !if_from_central_search TYPE abap_bool OPTIONAL .
    METHODS handle_option_selection .
    "! <p class="shorttext synchronized" lang="en">Load current entity into selection screen</p>
    METHODS load_entity
      IMPORTING
        !iv_entity_id    TYPE zdbbr_entity_id OPTIONAL
        !iv_entity_type  TYPE zdbbr_entity_type OPTIONAL
        !if_fill_history TYPE abap_bool DEFAULT abap_true .
    METHODS reset_flags .
    METHODS show_multi_select .
  PROTECTED SECTION.

  PRIVATE SECTION.

    ALIASES mf_first_call
      FOR zif_uitb_screen_controller~mf_first_call .
    ALIASES get_report_id
      FOR zif_uitb_screen_controller~get_report_id .
    ALIASES get_screen_id
      FOR zif_uitb_screen_controller~get_screen_id .

    DATA mf_object_navigator TYPE abap_bool .
    "! <p class="shorttext synchronized" lang="en">Function Code Table</p>
    DATA mf_from_central_search TYPE abap_bool .
    DATA mf_group_fields_updated TYPE boolean .
    DATA mf_join_tables_updated TYPE boolean .
    DATA mf_search_successful TYPE boolean .
    DATA mf_skipped_start TYPE abap_bool .
    DATA mf_table_was_changed TYPE boolean .
    DATA mr_altcoltext_f TYPE REF TO zcl_dbbr_altcoltext_factory .
    " attributes for data output
    DATA mr_cursor TYPE REF TO zcl_uitb_cursor .
    DATA mr_data TYPE REF TO zcl_dbbr_selscreen_data .
    DATA mr_favmenu_f TYPE REF TO zcl_dbbr_favmenu_factory .
    "! <p class="shorttext synchronized" lang="en">History View for Selection Screen</p>
    DATA mr_entity_history_view TYPE REF TO zcl_dbbr_selscreen_hist_view .
    "! <p class="shorttext synchronized" lang="en">Navigation Control in Selection Screen</p>
    DATA mr_navigator TYPE REF TO zcl_dbbr_object_navigator .
    DATA mr_selection_table TYPE REF TO zcl_dbbr_selscreen_table .
    DATA mr_toolbar_cont TYPE REF TO cl_gui_custom_container .
    DATA mr_usersettings_f TYPE REF TO zcl_dbbr_usersettings_factory .
    DATA mr_util TYPE REF TO zcl_dbbr_selscreen_util .
    DATA:
      BEGIN OF ms_entity_update,
        error_ref  TYPE REF TO zcx_dbbr_validation_exception,
        is_new     TYPE abap_bool,
        is_initial TYPE abap_bool,
      END OF ms_entity_update .
    DATA mt_multi_or_all TYPE zdbbr_or_seltab_itab .
    DATA mv_current_function TYPE sy-ucomm .
    DATA mv_default_option_button TYPE zdbbr_button .
    DATA mv_default_push_button TYPE zdbbr_button .
    DATA mv_tab_size_text TYPE string .

    METHODS choose_other_entity .
    METHODS clear_edit_flags .
    METHODS create_table_header
      IMPORTING
        !iv_tablename          TYPE tabname
      RETURNING
        VALUE(rs_table_header) TYPE zdbbr_selfield .
    METHODS define_join_relations .
    METHODS define_subqueries .
    METHODS delete_aggregations .
    METHODS delete_f4_helps .
    METHODS delete_variant .
    METHODS determine_optional_text_fields .
    METHODS edit_alternative_col_texts .
    METHODS execute_selection
      IMPORTING
        !if_count_lines_only TYPE boolean OPTIONAL
        !if_no_grouping      TYPE boolean OPTIONAL .
    METHODS get_variant_info
      RETURNING
        VALUE(rs_variant) TYPE disvariant .
    "! <p class="shorttext synchronized" lang="en">Handles pressed function for possible parameter field</p>
    METHODS handle_parameter_line
      RETURNING
        VALUE(rf_continue) TYPE abap_bool .
    "! <p class="shorttext synchronized" lang="en">Handler for Attr changed event</p>
    "!
    METHODS on_aggr_attr_changed
        FOR EVENT aggregation_attr_changed OF zcl_dbbr_selscreen_table .
    "! <p class="shorttext synchronized" lang="en">Handler for selection of favorite entry</p>
    "!
    "! @parameter !ev_entity_id | <p class="shorttext synchronized" lang="en"></p>
    "! @parameter !ev_entity_type | <p class="shorttext synchronized" lang="en"></p>
    METHODS on_faventry_selected
          FOR EVENT entity_chosen OF zcl_dbbr_selscr_nav_events
      IMPORTING
          !ev_entity_id
          !ev_entity_type .
    "! <p class="shorttext synchronized" lang="en">Handler for favorites tree event</p>
    "!
    "! @parameter !er_handler | <p class="shorttext synchronized" lang="en"></p>
    METHODS on_fav_tree_event
          FOR EVENT favtree_event OF zcl_dbbr_selscr_nav_events
      IMPORTING
          !er_handler .
    "! <p class="shorttext synchronized" lang="en">Handler for history navigation event</p>
    "!
    "! @parameter !es_history_entry | <p class="shorttext synchronized" lang="en"></p>
    "! @parameter !ev_current_index | <p class="shorttext synchronized" lang="en"></p>
    METHODS on_history_navigation
          FOR EVENT navigated OF zcl_dbbr_selscreen_history
      IMPORTING
          !es_history_entry
          !ev_current_index .
    "! <p class="shorttext synchronized" lang="en">Event handler for requesting new entity for screen</p>
    METHODS on_request_new_entity
          FOR EVENT request_new_entity OF zcl_dbbr_selscreen_util
      IMPORTING
          !ev_id
          !ev_type .
    "! <p class="shorttext synchronized" lang="en">Event Handler for requesting new object search</p>
    "!
    "! @parameter ev_object_type | <p class="shorttext synchronized" lang="en"></p>
    "! @parameter ev_search_query | <p class="shorttext synchronized" lang="en"></p>
    "! @parameter ef_close_popup | <p class="shorttext synchronized" lang="en"></p>
    METHODS on_request_object_search
          FOR EVENT request_object_search OF zcl_dbbr_selscr_nav_events
      IMPORTING
          ev_object_type
          ev_search_query
          ef_close_popup.
    "! <p class="shorttext synchronized" lang="en">Handler for Toolbar button press event</p>
    "!
    "! @parameter !ev_function | <p class="shorttext synchronized" lang="en"></p>
    METHODS on_toolbar_button_pressed
          FOR EVENT toolbar_button_pressed OF zcl_dbbr_toolbar_util
      IMPORTING
          !ev_function .
    "! <p class="shorttext synchronized" lang="en">Handler for variant favorites entry selection</p>
    "!
    "! @parameter !ev_entity_id | <p class="shorttext synchronized" lang="en"></p>
    "! @parameter !ev_entity_type | <p class="shorttext synchronized" lang="en"></p>
    "! @parameter !ev_variant_id | <p class="shorttext synchronized" lang="en"></p>
    "! @parameter !ef_go_to_result | <p class="shorttext synchronized" lang="en"></p>
    METHODS on_variant_faventry_selected
          FOR EVENT variant_entry_chosen OF zcl_dbbr_selscr_nav_events
      IMPORTING
          !ev_entity_id
          !ev_entity_type
          !ev_variant_id
          !ef_go_to_result .
    "! <p class="shorttext synchronized" lang="en">Performs extended Entity Search</p>
    METHODS perform_extended_search .
    "! <p class="shorttext synchronized" lang="en">Performs pick navigation (F2/Double Click)</p>
    "!
    METHODS pick_navigate .
    "! <p class="shorttext synchronized" lang="en">Reads Variant</p>
    "!
    METHODS read_variant .
    METHODS refresh_alternative_texts
      IMPORTING
        !ir_tablist TYPE REF TO zcl_dbbr_tabfield_list .
    METHODS save_built_in_f4 .
    METHODS save_query .
    METHODS save_variant .
    METHODS search .
    METHODS search_next .
    "! <p class="shorttext synchronized" lang="en">Perform object browser search via popup</p>
    "!
    METHODS search_objects .
    METHODS set_cursor
      RETURNING
        VALUE(rf_curser_set) TYPE abap_bool .
    METHODS set_focus_to_1st_selfield .
    METHODS set_focus_to_navigator .
    METHODS set_select_option
      IMPORTING
        !iv_current_line TYPE sy-tabix
        !iv_option       TYPE char2
        !iv_sign         TYPE char1 .
    METHODS show_formula_manager .
    "! <p class="shorttext synchronized" lang="en">Shows/hides navigation history</p>
    METHODS show_history
      IMPORTING
        !if_force_hide TYPE abap_bool OPTIONAL .
    METHODS show_multi_or .
    "! <p class="shorttext synchronized" lang="en">Shows the object list for the current object</p>
    "!
    METHODS show_object_list .
    "! <p class="shorttext synchronized" lang="en">Display/Hide Object navigator</p>
    METHODS show_object_navigator .
    METHODS update_aggrgtd_tabfield_list .
    METHODS update_alv_variant .
    METHODS update_util
      IMPORTING
        !iv_mode TYPE zdbbr_selscreen_mode OPTIONAL .
ENDCLASS.



CLASS zcl_dbbr_selscreen_controller IMPLEMENTATION.


  METHOD call_alv_variant_f4.
*&---------------------------------------------------------------------*
*& Description: Calls value help for alv variant
*&---------------------------------------------------------------------*
    DATA: lf_exit     TYPE abap_bool,
          lt_dynpread TYPE TABLE OF dynpread
          .

    DATA(ls_variant) = get_variant_info( ).

    CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
      EXPORTING
        is_variant    = ls_variant
        i_save        = 'A'
      IMPORTING
        e_exit        = lf_exit
        es_variant    = ls_variant
      EXCEPTIONS
        not_found     = 1
        program_error = 2
        OTHERS        = 3.

    IF sy-subrc = 0 AND lf_exit = abap_false.
      mr_data->mr_s_global_data->alv_variant = ls_variant-variant.
      mr_data->mr_s_global_data->alv_varianttext = ls_variant-text.

      lt_dynpread = VALUE #( ( fieldname  = 'GS_DATA-VARIANTTEXT'
                               fieldvalue = mr_data->mr_s_global_data->alv_varianttext ) ).
      CALL FUNCTION 'DYNP_VALUES_UPDATE'
        EXPORTING
          dyname     = zif_dbbr_c_report_id=>main
          dynumb     = sy-dynnr
        TABLES
          dynpfields = lt_dynpread.
    ELSE.
      IF sy-subrc = 1.
        MESSAGE s073(0k).
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD call_f4_help.
*& Description: Calls value help for low/high values
*&---------------------------------------------------------------------*
    DATA(lv_current_line) = mr_selection_table->get_current_line( ).

    TRY.
        DATA(ls_selfield) = mr_data->mr_t_table_data->*[ lv_current_line ].
        DATA(ls_selfield_save) = ls_selfield.

        zcl_dbbr_f4_helper=>call_selfield_f4(
          EXPORTING
            if_low           = if_for_low
            iv_repid         = zif_dbbr_c_report_id=>main
            iv_selfield_name = 'GS_SELFIELDS'
            iv_current_line  = lv_current_line
            ir_custom_f4_map = mr_data->mr_custom_f4_map
          CHANGING
            cs_selfield      = ls_selfield
        ).

        IF ls_selfield_save-low <> ls_selfield-low OR
           ls_selfield_save-high <> ls_selfield-high.
          mr_data->mr_s_current_line->* = ls_selfield.
        ENDIF.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

  ENDMETHOD.


  METHOD call_table_f4.
*&---------------------------------------------------------------------*
*& Description: Calls f4 help for table name
*&---------------------------------------------------------------------*
    DATA: lt_dynpfields TYPE TABLE OF dynpread.

    lt_dynpfields = VALUE #( ( fieldname = iv_dynp_field_name ) ).
    CALL FUNCTION 'DYNP_VALUES_READ'
      EXPORTING
        dyname             = zif_dbbr_c_report_id=>main
        dynumb             = sy-dynnr
        translate_to_upper = abap_true
      TABLES
        dynpfields         = lt_dynpfields.

    DATA(ls_dynpfield) = lt_dynpfields[ 1 ].
    cv_table = ls_dynpfield-fieldvalue.
    IF cv_table = space.
      cv_table = '*'.
    ENDIF.

    DATA(lv_table_temp) = cv_table.

    CALL FUNCTION 'F4_DD_TABLES'
      EXPORTING
        object             = lv_table_temp
        suppress_selection = 'X'
      IMPORTING
        result             = lv_table_temp.

    cv_table = lv_table_temp.
  ENDMETHOD.


  METHOD check_alv_variant.
*&---------------------------------------------------------------------*
*& Description: Validation of ALV variant.
*&---------------------------------------------------------------------*
    DATA: ls_variant TYPE disvariant.

    ASSIGN mr_data->mr_s_global_data->* TO FIELD-SYMBOL(<ls_global_data>).

    " Only check if there really is a variant
    IF <ls_global_data>-alv_variant = space.
      CLEAR <ls_global_data>-alv_varianttext.
    ENDIF.

    CHECK: <ls_global_data>-alv_variant <> space.

    mr_util->get_entity_information(
      IMPORTING
        ev_entity      = DATA(lv_entity)
        ev_type        = DATA(lv_type)
    ).

    ls_variant = VALUE disvariant(
        report     = |{ zif_dbbr_c_report_id=>main }{ lv_type }{ lv_entity }|
        handle     = abap_true
        username   = sy-uname
        variant    = <ls_global_data>-alv_variant
        text       = <ls_global_data>-alv_varianttext
    ).

    CALL FUNCTION 'REUSE_ALV_VARIANT_EXISTENCE'
      EXPORTING
        i_save        = 'A'
      CHANGING
        cs_variant    = ls_variant
      EXCEPTIONS
        wrong_input   = 1
        not_found     = 2
        program_error = 3
        OTHERS        = 4.
    IF sy-subrc <> 0.
      MESSAGE e213(ga).
    ELSE.
      <ls_global_data>-alv_variant = ls_variant-variant.
      <ls_global_data>-alv_varianttext = ls_variant-text.
    ENDIF.
  ENDMETHOD.


  METHOD check_edit_mode.
    mr_util->check_edit_mode( ).
  ENDMETHOD.


  METHOD check_entity.
    DATA: lv_msg TYPE string.
    DATA(lv_entity_id_field) = CONV dynfnam( |{ zif_dbbr_main_report_var_ids=>c_s_entity_info }-ENTITY_ID| ).

    ASSIGN mr_data->mr_s_entity_info->* TO FIELD-SYMBOL(<ls_entity_info>).

    IF <ls_entity_info>-entity_id IS INITIAL.
      ms_entity_update-is_initial = abap_true.
      RETURN.
    ENDIF.

    TRY.
        CASE <ls_entity_info>-entity_type.

          WHEN zif_dbbr_c_entity_type=>table.

            zcl_dbbr_dictionary_helper=>validate_table_name(
              iv_table_name               = <ls_entity_info>-entity_id
              if_customizing_view_allowed = abap_false
              iv_dynpro_fieldname         = lv_entity_id_field
            ).

          WHEN zif_dbbr_c_entity_type=>cds_view.

            IF NOT zcl_dbbr_cds_view_factory=>exists( <ls_entity_info>-entity_id ).
              MESSAGE e072(zdbbr_info) WITH <ls_entity_info>-entity_id INTO lv_msg.
              zcx_dbbr_validation_exception=>raise_from_sy(
                 iv_parameter = lv_entity_id_field
              ).
            ENDIF.

          WHEN zif_dbbr_c_entity_type=>query.

            " Validate the query name
            DATA(lr_query_f) = NEW zcl_dbbr_query_factory( ).
            DATA(ls_query) = lr_query_f->get_query(
                iv_query_name     = <ls_entity_info>-entity_id
                if_load_completely = abap_false
            ).

            IF ls_query IS INITIAL.
              MESSAGE e035(zdbbr_info) WITH <ls_entity_info>-entity_id INTO lv_msg.
              zcx_dbbr_validation_exception=>raise_from_sy(
                 iv_parameter = lv_entity_id_field
              ).
            ENDIF.

        ENDCASE.

        ms_entity_update-is_new = abap_true.
        CLEAR ms_entity_update-error_ref.
      CATCH zcx_dbbr_validation_exception INTO ms_entity_update-error_ref.
    ENDTRY.

  ENDMETHOD.


  METHOD choose_other_entity.

    mr_cursor->set_field( |{ zif_dbbr_main_report_var_ids=>c_s_entity_info }-ENTITY_TYPE| ).
    mr_cursor->request_update( ).

  ENDMETHOD.


  METHOD clear_edit_flags.
    CLEAR: mr_data->mr_s_global_data->edit,
           mr_data->mr_s_global_data->delete_mode.
  ENDMETHOD.


  METHOD constructor.
    mr_data = NEW zcl_dbbr_selscreen_data( ir_selection_table = ir_selection_table ).
    mr_data->mr_f_from_central_search->* = if_from_central_search.
    mr_selection_table = ir_selection_table.

    update_util( iv_mode ).

    mf_from_central_search = if_from_central_search.
    mr_data->mr_s_settings->* = is_settings.

    mr_usersettings_f = NEW zcl_dbbr_usersettings_factory( ).

*... register for events of selection table
    SET HANDLER:
      on_aggr_attr_changed FOR mr_selection_table,
      on_history_navigation,
      on_toolbar_button_pressed,
      on_fav_tree_event,
      on_variant_faventry_selected,
      on_faventry_selected,
      on_request_object_search.

    mr_favmenu_f = NEW #( ).
    mr_altcoltext_f = NEW zcl_dbbr_altcoltext_factory( ).
  ENDMETHOD.


  METHOD create_table_header.
    rs_table_header = VALUE zdbbr_selfield(
      tabname              = iv_tablename
      is_table_header      = abap_true
      description          = |Table { iv_tablename }|
      fieldname            = iv_tablename
      ddic_order           = 0 ).
  ENDMETHOD.


  METHOD define_join_relations.
    mr_data->mr_s_join_def->primary_table = mr_data->mr_s_global_data->primary_table.

    " cache current join definition
    mr_data->store_old_join( ).

    DATA(lr_join_manager) = NEW zcl_dbbr_join_manager(
      iv_primary_table = mr_data->mr_s_global_data->primary_table
      ir_s_join_ref    = mr_data->mr_s_join_def
    ).
    lr_join_manager->zif_uitb_view~show( ).

    CHECK lr_join_manager->was_updated( ).
    MESSAGE |Join Definitions were updated| TYPE 'S'.
    mr_util->update_join_definition( ).
  ENDMETHOD.


  METHOD define_subqueries.

  ENDMETHOD.


  METHOD delete_aggregations.
    mr_selection_table->delete_aggregations( ).
  ENDMETHOD.


  METHOD delete_f4_helps.
*&---------------------------------------------------------------------*
*& Description: Deletes all F4 helps for current field
*&---------------------------------------------------------------------*
    DATA: lv_field(40).
    GET CURSOR FIELD lv_field.

    IF lv_field CP 'GS_SELFIELDS-*'.

      TRY.
          DATA(lv_current_line_index) = mr_selection_table->get_current_line( ).
          DATA(lr_current_line) = REF #( mr_data->mr_t_table_data->*[ lv_current_line_index ] ).
          " only possible for field of primary table
          IF lr_current_line->tabname <> mr_data->mr_s_global_data->primary_table.
            RETURN.
          ENDIF.
***          lcl_custom_f4_controller=>get_instance( )->delete_f4_from_field( lr_current_line ).
        CATCH cx_sy_itab_line_not_found.
          RETURN.
      ENDTRY.
    ENDIF.
  ENDMETHOD.


  METHOD delete_variant.
    DATA(lr_variant_controller) = NEW zcl_dbbr_variant_controller(
        iv_screen_mode    = mr_data->get_mode( )
        iv_mode           = zcl_dbbr_variant_controller=>mc_modes-delete
        is_query_info    = mr_data->mr_s_query_info->*
        ir_multi_or_itab  = REF #( mt_multi_or_all )
        ir_tabfields      = mr_data->mr_tabfield_list
        ir_tabfields_grpd = mr_data->mr_tabfield_aggr_list
    ).

    lr_variant_controller->zif_uitb_screen_controller~call_screen( ).
  ENDMETHOD.


  METHOD determine_optional_text_fields.
*&---------------------------------------------------------------------*
*& Description: Determines columns which possess optional text columns in
*& other tables.
*&---------------------------------------------------------------------*
    DATA(lt_table_selopt) = zcl_dbbr_appl_util=>build_selopt_tab_from_table(
        it_table_data       = mr_data->mr_tabfield_list->get_table_list( )
        iv_compname_for_low = 'TABNAME'
    ).

    NEW zcl_dbbr_addtext_manager( lt_table_selopt )->show( ).
  ENDMETHOD.


  METHOD edit_alternative_col_texts.
    DATA(lr_tabfield_list) = mr_data->mr_tabfield_list.

    DATA(lr_altcoltext_table) = NEW zcl_dbbr_altcoltext_table( ).
    DATA(lr_altcoltext_controller) = NEW zcl_dbbr_altcoltxt_controller(
        ir_altcoltext_table = lr_altcoltext_table
        ir_tabfield_list = lr_tabfield_list
    ).

    lr_altcoltext_controller->zif_uitb_screen_controller~call_screen( ).

    CHECK lr_altcoltext_controller->zif_uitb_screen_controller~was_not_cancelled( ).

    " refresh selection table
    lr_tabfield_list->initialize_iterator( ).

    WHILE lr_tabfield_list->has_more_lines( ).
      DATA(lr_field) = lr_tabfield_list->get_next_entry( ).

      ASSIGN mr_data->mr_t_table_data->*[ tabname   = lr_field->tabname
                                          fieldname = lr_field->fieldname ] TO FIELD-SYMBOL(<ls_selfield>).
      IF sy-subrc = 0.
        IF lr_field->alt_long_text IS NOT INITIAL.
          <ls_selfield>-description = lr_field->alt_long_text.
        ELSE.
          IF lr_field->std_long_text IS INITIAL.
            <ls_selfield>-description = lr_field->field_ddtext.
          ELSE.
            <ls_selfield>-description = lr_field->std_long_text.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDWHILE.
  ENDMETHOD.


  METHOD execute_selection.
    FIELD-SYMBOLS: <lr_tabfields>     TYPE REF TO zcl_dbbr_tabfield_list,
                   <lr_tabfields_all> TYPE REF TO zcl_dbbr_tabfield_list.

    DATA(lr_formula) = mr_data->get_formula( ).

    refresh_alternative_texts( mr_data->mr_tabfield_list ).
    ASSIGN mr_data->mr_tabfield_list TO <lr_tabfields_all>.

    IF mr_selection_table->aggregation_is_active( ) AND if_no_grouping = abap_false.
      ASSIGN mr_data->mr_tabfield_aggr_list TO <lr_tabfields>.
      refresh_alternative_texts( <lr_tabfields> ).
    ELSE.
      ASSIGN mr_data->mr_tabfield_list TO <lr_tabfields>.

      " check if there is at least one formula field that will be shown
      DATA(lr_table_searcher) = NEW zcl_uitb_table_func_executor( ir_table = <lr_tabfields>->get_fields_ref( ) ).
      IF lr_formula IS BOUND AND lr_formula->is_valid( ).
        DATA(lv_form_field_output_count) = lr_table_searcher->count_lines(
          it_field_selopts = VALUE #(
            ( fieldname   = 'IS_FORMULA_FIELD'
              selopt_itab = VALUE #( ( sign = 'I' option = 'EQ' low = abap_true ) ) )
            ( fieldname   = 'OUTPUT_ACTIVE'
              selopt_itab = VALUE #( ( sign = 'I' option = 'EQ' low = abap_true ) ) )
          )
        ).

        DATA(lr_valid_formula) = COND #( WHEN lv_form_field_output_count > 0 OR
                                            lr_formula->has_executable_code( ) THEN lr_formula ).
      ENDIF.
    ENDIF.

    DATA(lt_selfields) = mr_selection_table->get_data( ).

    TRY.
        NEW zcl_dbbr_pre_sel_validator(
            it_selection_fields   = lt_selfields
            ir_tabfields          = <lr_tabfields>
            is_join_definition    = mr_data->mr_s_join_def->*
            it_table_to_alias_map = mr_data->mr_t_table_to_alias_map->*
            is_technical_infos    = CORRESPONDING #( mr_data->mr_s_global_data->* )
        )->validate( ).
      CATCH zcx_dbbr_validation_exception INTO DATA(lr_validation_exc).
        lr_validation_exc->zif_dbbr_exception_message~print( ).
        RETURN.
    ENDTRY.

    mr_util->get_entity_information(
      IMPORTING
        ev_entity      = DATA(lv_entity_id)
    ).
    TRY.
        DATA(lr_controller) = zcl_dbbr_selection_controller=>create_controller(
            iv_entity_type        = mr_data->get_mode( )
            iv_entity_id          = lv_entity_id
            it_selection_fields   = lt_selfields
            if_no_grouping        = if_no_grouping
            it_multi_or           = mt_multi_or_all
            is_technical_infos    = CORRESPONDING #( mr_data->mr_s_global_data->* )
            iv_alv_varianttext    = mr_data->mr_s_global_data->alv_varianttext
            if_edit               = mr_data->mr_s_global_data->edit
            if_delete_mode_active = mr_data->mr_s_global_data->delete_mode
            it_selfields_multi    = mr_data->mr_t_selfields_multi->*
            ir_tabfields          = <lr_tabfields>->copy( )
            ir_tabfields_all      = <lr_tabfields_all>->copy( )
            it_table_to_alias_map = mr_data->mr_t_table_to_alias_map->*
            is_join_def           = mr_data->mr_s_join_def->*
            ir_formula            = lr_valid_formula
        ).

        lr_controller->execute_selection( if_count_lines_only ).

        IF lr_controller->layout_was_transferred( ).
          <lr_tabfields>->overwrite( lr_controller->get_updated_tabfields( ) ).
        ENDIF.

      CATCH cx_root INTO DATA(lx_selection_error).
        MESSAGE lx_selection_error->get_text( ) TYPE 'I' DISPLAY LIKE 'E'.
    ENDTRY.

  ENDMETHOD.


  METHOD get_variant_info.
    mr_util->get_entity_information(
      IMPORTING
        ev_entity      = DATA(lv_entity)
        ev_type        = DATA(lv_type)
    ).

    rs_variant-username = sy-uname.
    rs_variant-variant = mr_data->mr_s_global_data->alv_variant.
    rs_variant-handle = abap_true.
    rs_variant-report = |{ zif_dbbr_c_report_id=>main }{ lv_type }{ lv_entity }|.

  ENDMETHOD.


  METHOD handle_option_selection.
    DATA(lv_current_line) = mr_selection_table->get_current_line( ).

    TRY .
        DATA(ls_current_line) = mr_data->mr_t_table_data->*[ lv_current_line ].
      CATCH cx_sy_itab_line_not_found.
        RETURN.
    ENDTRY.

    " get user selection
    DATA(ls_chosen_option) = zcl_dbbr_selscreen_util=>choose_sel_option( ).
    IF ls_chosen_option IS INITIAL.
      RETURN.
    ENDIF.

    ls_current_line-sign   = ls_chosen_option-sign.
    ls_current_line-option = ls_chosen_option-option.
    " GT_sel_init contains info if low and/or high are allowed for
    " the selected option
    TRY .
        DATA(ls_sel_init) = mr_data->mr_t_sel_init_table->*[ option = ls_chosen_option-option ].
        IF ls_sel_init-high <> abap_true.
          CLEAR ls_current_line-high.
        ENDIF.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    MODIFY mr_data->mr_t_table_data->* FROM ls_current_line INDEX lv_current_line.
  ENDMETHOD.


  METHOD handle_parameter_line.
    rf_continue = abap_true.
    DATA(lv_current_line) = mr_selection_table->get_current_line( ).
    CHECK lv_current_line <> 0.
    CHECK lv_current_line <= lines( mr_data->mr_t_table_data->* ).

    DATA(lr_current_line) = REF #( mr_data->mr_t_table_data->*[ lv_current_line ] ).

    CASE mv_current_function.
      WHEN zif_dbbr_c_selscreen_functions=>show_multi_select_dialog OR
           zif_dbbr_c_selscreen_functions=>show_option_dialog OR
           zif_dbbr_c_selscreen_functions=>select_option_equal OR
           zif_dbbr_c_selscreen_functions=>select_option_not_equal.
        rf_continue = xsdbool( lr_current_line->is_parameter = abap_false ).
      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.


  METHOD load_entity.
    DATA: lv_new_query_name TYPE zdbbr_query_name,
          lf_is_query       TYPE abap_bool,
          lf_cds_mode       TYPE abap_bool,
          lv_cds_name       TYPE zdbbr_cds_view_name,
          lv_new_tab_name   TYPE tabname16.

    IF iv_entity_id IS NOT INITIAL AND
       iv_entity_type IS NOT INITIAL.
      CHECK NOT mr_util->is_entity_loaded(
            iv_entity_id   = iv_entity_id
            iv_entity_type = iv_entity_type
        ).

      mr_util->clear( ).

      CASE iv_entity_type.
        WHEN zif_dbbr_c_entity_type=>table OR
             zif_dbbr_c_entity_type=>view.
          mr_data->mr_s_global_data->primary_table = iv_entity_id.
          update_util( zif_dbbr_c_selscreen_mode=>table ).

        WHEN zif_dbbr_c_entity_type=>cds_view.
          mr_data->mr_s_global_data->primary_table = iv_entity_id.
          update_util( zif_dbbr_c_selscreen_mode=>cds_view ).

        WHEN zif_dbbr_c_entity_type=>query.
          CLEAR: mr_data->mr_s_global_data->primary_table.
          mr_data->mr_s_global_data->query_name = iv_entity_id.
          update_util( zif_dbbr_c_selscreen_mode=>query ).

      ENDCASE.

      mr_util->load_entity( ).

      mr_usersettings_f->update_start_settings(
        iv_entity_id   = iv_entity_id
        iv_entity_type = iv_entity_type
      ).

      mr_util->get_entity_information(
        IMPORTING ev_entity_raw = DATA(lv_entity_raw)
                  ev_type       = DATA(lv_entity_type)
                  ev_description = DATA(lv_entity_description)
      ).

      mr_favmenu_f->refresh_most_used(
          iv_entry     = iv_entity_id
          iv_entry_raw = lv_entity_raw
          iv_type      = lv_entity_type
          iv_text      = lv_entity_description
      ).

    ELSE.
      CHECK mr_util->load_entity( ).
    ENDIF.


*... fill history entry
    CHECK if_fill_history = abap_true.
    CHECK iv_entity_id IS NOT INITIAL OR
          mr_data->mr_s_entity_info->entity_id IS NOT INITIAL.

    mr_util->get_entity_information(
      IMPORTING
        ev_entity      = DATA(lv_entity)
        ev_type        = DATA(lv_type)
        ev_description = DATA(lv_description)
    ).
    zcl_dbbr_selscreen_history=>add_new_entry(
      iv_entity      = lv_entity
      iv_type        = lv_type
      iv_description = lv_description
    ).
  ENDMETHOD.


  METHOD on_aggr_attr_changed.
    mf_group_fields_updated = abap_true.
  ENDMETHOD.


  METHOD on_faventry_selected.
    CHECK ev_entity_id IS NOT INITIAL.

    load_entity(
        iv_entity_id   = ev_entity_id
        iv_entity_type = ev_entity_type
    ).
  ENDMETHOD.


  METHOD on_fav_tree_event.
    " add the current entity to the favorite menu
    mr_util->get_entity_information(
      IMPORTING
        ev_entity      = DATA(lv_entity)
        ev_type        = DATA(lv_type)
        ev_description = DATA(lv_description)
    ).
    er_handler->add_favorite(
        iv_favorite    = lv_entity
        iv_description = lv_description
        iv_type        = lv_type
    ).
  ENDMETHOD.


  METHOD on_history_navigation.
    load_entity(
        iv_entity_id    = es_history_entry-entity_id
        iv_entity_type  = es_history_entry-entity_type
        if_fill_history = abap_false
    ).
  ENDMETHOD.


  METHOD on_request_new_entity.
    load_entity(
        iv_entity_id    = ev_id
        iv_entity_type  = ev_type
    ).
  ENDMETHOD.


  METHOD on_request_object_search.
    IF mf_object_navigator = abap_false.
      show_object_navigator( ).
    ENDIF.

    mr_navigator->update_view( zcl_dbbr_object_navigator=>c_view-object_browser ).
    zcl_dbbr_selscr_nav_events=>raise_object_search(
      iv_object_type  = ev_object_type
      iv_search_query = ev_search_query
      if_close_popup  = ef_close_popup
    ).
  ENDMETHOD.


  METHOD on_toolbar_button_pressed.
    zif_uitb_screen_controller~handle_user_command(
        CHANGING cv_function_code = ev_function
    ).
  ENDMETHOD.


  METHOD on_variant_faventry_selected.
    IF ef_go_to_result = abap_true.
      DATA(lr_variant_starter) = zcl_dbbr_variant_starter_fac=>create_variant_starter(
         iv_variant_id        = ev_variant_id
         iv_entity_type       = ev_entity_type
         iv_variant_entity_id = CONV #( ev_entity_id )
     ).

      lr_variant_starter->initialize( ).
      lr_variant_starter->execute_variant( ).
    ELSE.
*... first check if entity is already loaded
      IF NOT mr_util->is_entity_loaded( iv_entity_id   = CONV #( ev_entity_id )
                                        iv_entity_type = ev_entity_type ).
**... Load the entity before loading the variant
        load_entity(
            iv_entity_id   = CONV #( ev_entity_id )
            iv_entity_type = ev_entity_type
        ).
      ENDIF.

*... fill the selection screen with the information from the variant
      DATA(ls_variant) = NEW zcl_dbbr_variant_loader(
          iv_variant_id        = ev_variant_id
          iv_entity_type       = ev_entity_type
          iv_entity_id         = CONV #( ev_entity_id )
          ir_t_multi_or        = REF #( mt_multi_or_all )
          ir_t_selfields       = mr_data->mr_t_table_data
          ir_t_selfields_multi = mr_data->mr_t_selfields_multi
          ir_tabfields         = mr_data->mr_tabfield_list
          ir_s_global_data     = mr_data->mr_s_global_data
          ir_tabfields_grouped = mr_data->mr_tabfield_aggr_list
      )->load_variant( ).

*... fill the global parameters for the variant description
      IF ls_variant IS NOT INITIAL.
        mr_data->mr_v_variant_name->* = ls_variant-variant_name.
        mr_data->mr_v_variant_description->* = ls_variant-description.
      ENDIF.
*.... Check if aggregation fields were added from variant
      IF mr_selection_table->aggregation_is_active( ).
        update_aggrgtd_tabfield_list( ).
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD perform_extended_search.
    DATA(lv_entity_type) = mr_data->get_mode( ).
*.. There is no search control for querys yet
    CHECK lv_entity_type <> zif_dbbr_c_entity_type=>query.
    DATA(lf_specific) = abap_true.

    DATA(lr_entity_browser) = NEW zcl_dbbr_object_central_search(
      if_specific_search      = abap_true
      iv_entity_type          = lv_entity_type
      iv_initial_search_value = |{ mr_data->mr_s_entity_info->entity_id }|
    ).
    lr_entity_browser->zif_uitb_view~show( ).
    lr_entity_browser->get_chosen_entity(
      IMPORTING
        ev_entity_id   = DATA(lv_search_entity_id)
        ev_entity_type = DATA(lv_search_entity_type)
    ).
    IF lv_search_entity_id IS NOT INITIAL.
      load_entity(
          iv_entity_id    = lv_search_entity_id
          iv_entity_type  = lv_search_entity_type
      ).
    ENDIF.
  ENDMETHOD.


  METHOD pick_navigate.
    CHECK mr_cursor->get_field( ) = lif_selfield_names=>c_fieldname OR
          mr_cursor->get_field( ) = lif_selfield_names=>c_scrtext_l OR
          mr_cursor->get_field( ) = lif_selfield_names=>c_description OR
          mr_cursor->get_field( ) = lif_selfield_names=>c_scrtext_m.

    DATA(ldo_current_line) = CAST zdbbr_selfield( mr_selection_table->zif_uitb_table~get_current_line_ref( ) ).

    CALL FUNCTION 'RS_DD_DTEL_SHOW'
      EXPORTING
        objname = ldo_current_line->rollname
      EXCEPTIONS
        OTHERS  = 4.
  ENDMETHOD.


  METHOD read_variant.

    DATA(lr_variant_controller) = NEW zcl_dbbr_variant_controller(
        iv_screen_mode    = mr_data->get_mode( )
        iv_mode           = zcl_dbbr_variant_controller=>mc_modes-read
        is_query_info    = mr_data->mr_s_query_info->*
        ir_multi_or_itab  = REF #( mt_multi_or_all )
        ir_tabfields      = mr_data->mr_tabfield_list
        ir_tabfields_grpd = mr_data->mr_tabfield_aggr_list
    ).

    lr_variant_controller->zif_uitb_screen_controller~call_screen( ).

  ENDMETHOD.


  METHOD refresh_alternative_texts.
    DATA(lr_altcoltext_f) = NEW zcl_dbbr_altcoltext_factory( ).

    ir_tablist->initialize_iterator( ).

    WHILE ir_tablist->has_more_lines( ).
      DATA(lr_current_entry) = ir_tablist->get_next_entry( ).

      DATA(ls_altcoltext) = lr_altcoltext_f->find_alternative_text(
          iv_tabname   = lr_current_entry->tabname
          iv_fieldname = lr_current_entry->fieldname
      ).

      lr_current_entry->alt_long_text = ls_altcoltext-alt_long_text.
      lr_current_entry->alt_medium_text = ls_altcoltext-alt_short_text.
    ENDWHILE.
  ENDMETHOD.


  METHOD reset_flags.
    CLEAR: mf_join_tables_updated,
           mf_table_was_changed,
           mf_group_fields_updated.
  ENDMETHOD.


  METHOD save_built_in_f4.
*&---------------------------------------------------------------------*
*& Description: Calls view to save built-in F4 help for this field
*&---------------------------------------------------------------------*
    DATA: lv_field(40).
    GET CURSOR FIELD lv_field.

    CASE lv_field.
      WHEN 'GS_SELFIELDS-LOW' OR 'GS_SELFIELDS-HIGH'.
        TRY.
            DATA(ls_current_line) = mr_data->mr_t_table_data->*[ mr_selection_table->get_current_line( ) ].
            " only possible for field of primary table
            IF ls_current_line-tabname <> mr_data->mr_s_global_data->primary_table.
              RETURN.
            ENDIF.

            DATA(lr_f4_screen_controller) = NEW zcl_dbbr_built_in_f4_sc(
                iv_display_mode  = zif_dbbr_global_consts=>gc_display_modes-create
                iv_current_table = ls_current_line-tabname
                iv_current_field = ls_current_line-fieldname
            ).

            lr_f4_screen_controller->zif_uitb_screen_controller~call_screen( ).
          CATCH cx_sy_itab_line_not_found.
            RETURN.
        ENDTRY.
    ENDCASE.

  ENDMETHOD.


  METHOD save_query.
    DATA(lr_formula) = mr_data->get_formula( ).

    IF lr_formula IS BOUND.
      TRY .
          NEW zcl_dbbr_fe_validator(
              iv_formula   = lr_formula->get_formula_string( )
              ir_tabfields = mr_data->mr_tabfield_list
          )->validate( ).

          mr_data->mr_s_query_info->formula = lr_formula->get_formula_string( ).
        CATCH zcx_dbbr_formula_exception.
          MESSAGE i043(zdbbr_exception) DISPLAY LIKE 'E'.
          RETURN.
      ENDTRY.
    ELSE.
      CLEAR mr_data->mr_s_query_info->formula.
    ENDIF.

    DATA(lr_save_query_controller) = NEW zcl_dbbr_save_query_ctrl(
      ir_tabfield_list        = mr_data->mr_tabfield_list->copy( )
      is_query_info          = mr_data->mr_s_query_info->*
      is_join_def             = mr_data->mr_s_join_def->*
      ir_t_multi_or           = mr_data->get_multi_or_all( )
      ir_t_multi_selfields    = mr_data->mr_t_selfields_multi
      ir_t_selfields          = mr_data->mr_t_table_data
    ).

    lr_save_query_controller->show( ).

    CHECK lr_save_query_controller->was_saved( ).

*.. load the saved query
    load_entity(
        iv_entity_id    = lr_save_query_controller->get_query_name( )
        iv_entity_type  = zif_dbbr_c_entity_type=>query
    ).
  ENDMETHOD.


  METHOD save_variant.
*&---------------------------------------------------------------------*
*& Description: Saves the current layout
*&---------------------------------------------------------------------*
*...if there is an active join-saving is prevented
    IF mr_data->get_mode( ) = zif_dbbr_c_selscreen_mode=>table AND
       mr_data->is_join_active( ).
      MESSAGE e044(zdbbr_exception) DISPLAY LIKE 'I'.
      RETURN.
    ENDIF.

    DATA(lr_variant_controller) = NEW zcl_dbbr_variant_controller(
        iv_screen_mode    = mr_data->get_mode( )
        iv_mode           = zcl_dbbr_variant_controller=>mc_modes-save
        is_query_info    = mr_data->mr_s_query_info->*
        ir_multi_or_itab  = REF #( mt_multi_or_all )
        ir_tabfields      = mr_data->mr_tabfield_list
        ir_tabfields_grpd = mr_data->mr_tabfield_aggr_list
    ).

    lr_variant_controller->zif_uitb_screen_controller~call_screen( ).

  ENDMETHOD.


  METHOD search.
    IF mr_navigator IS BOUND AND mr_navigator->has_focus( ).
      mr_navigator->search( ).
    ELSE.
      mf_search_successful = mr_selection_table->search_value( mv_current_function ).
    ENDIF.
  ENDMETHOD.


  METHOD search_next.
    IF mr_navigator IS BOUND AND mr_navigator->has_focus( ).
      mr_navigator->search_next( ).
    ELSE.
      mf_search_successful = mr_selection_table->search_value( mv_current_function ).
    ENDIF.
  ENDMETHOD.


  METHOD search_objects.
    DATA(lr_object_search_view) = NEW zcl_dbbr_obj_brws_search_sc( ).
    lr_object_search_view->show( ).
  ENDMETHOD.


  METHOD set_cursor.
    CONSTANTS: lc_low_field_name   TYPE char30 VALUE 'GS_SELFIELDS-LOW'.

    DATA: lv_index TYPE sy-tabix.

    CHECK NOT mr_cursor->is_updated( ).

    IF mr_cursor->is_update_requested( ).
      zcl_uitb_cursor=>refresh_cursor( ).
      RETURN.
    ENDIF.

    ASSIGN mr_data->mr_t_table_data->* TO FIELD-SYMBOL(<lt_selection_fields>).

    lv_index = mr_selection_table->zif_uitb_table~get_current_loop_line( ).

    IF mv_current_function = 'PAGE_UP' OR
       mv_current_function = 'PAGE_TOP' OR
       mv_current_function = 'PAGE_DOWN'.

      zcl_uitb_cursor=>set_cursor(
        iv_field = |{ lc_low_field_name }|
        iv_line  = COND syst_tabix( WHEN mr_data->is_join_active( ) THEN 2 ELSE 1 )
      ).

      RETURN.
    ENDIF.

    IF mv_current_function = 'PAGE_END'.
      " get max looplines of table
      DATA(lv_lastindex) = mr_selection_table->get_loop_lines( ).
      IF lv_lastindex > lines( <lt_selection_fields> ).
        lv_lastindex = lines( <lt_selection_fields> ).
      ENDIF.
      zcl_uitb_cursor=>set_cursor( iv_field = |{ lc_low_field_name }| iv_line = lv_lastindex ).
      RETURN.
    ENDIF.

    IF mf_search_successful = abap_true.
      zcl_uitb_cursor=>set_cursor( iv_field = |{ lc_low_field_name }| iv_line = 1 ).
      CLEAR mf_search_successful.
      RETURN.
    ENDIF.

    " check if current cursor position is inside selection table
    IF mr_cursor IS NOT INITIAL AND mr_cursor->get_field( ) CP 'GS_SELFIELDS*'.
      IF lv_index > 0.
        zcl_uitb_cursor=>set_cursor( iv_field = |{ mr_cursor->get_field( ) }| iv_line = lv_index ).
        RETURN.
      ENDIF.
    ENDIF.

    IF mv_current_function = zif_dbbr_c_selscreen_functions=>show_multi_select_dialog OR
       mv_current_function = zif_dbbr_c_selscreen_functions=>show_option_dialog.
      IF lv_index > 0.
        zcl_uitb_cursor=>set_cursor( iv_field = |{ lc_low_field_name }| iv_line = lv_index ).
        RETURN.
      ENDIF.
    ENDIF.

*... set cursor to current field
    mr_cursor->refresh( ).

  ENDMETHOD.


  METHOD set_focus_to_1st_selfield.
    DATA(lv_top_line) = mr_data->mr_s_tableview->top_line.
    LOOP AT mr_data->mr_t_table_data->* ASSIGNING FIELD-SYMBOL(<ls_selfield>) FROM lv_top_line WHERE is_table_header = abap_false.
      mr_cursor->set_field( lif_selfield_names=>c_low ).
      IF lv_top_line > 1.
        DATA(lv_new_index) = sy-tabix - lv_top_line + 1.
        mr_cursor->set_line( lv_new_index ).
      ELSE.
        mr_cursor->set_line( sy-tabix ).
      ENDIF.

      mr_cursor->request_update( ).
      EXIT.
    ENDLOOP.
  ENDMETHOD.


  METHOD set_focus_to_navigator.
    CHECK mf_object_navigator = abap_true.

    mr_navigator->focus( ).
    mr_cursor->set_is_updated( ).
  ENDMETHOD.


  METHOD set_select_option.
    CHECK iv_current_line > 0.

    mr_data->mr_t_table_data->*[ iv_current_line ]-option = iv_option.
    mr_data->mr_t_table_data->*[ iv_current_line ]-sign = iv_sign.
  ENDMETHOD.


  METHOD show_formula_manager.

    DATA(lr_tabfields) = mr_data->mr_tabfield_list.
    lr_tabfields->update_tables( ).
    DATA(lr_formula) = mr_data->get_formula( ).

    DATA(lr_formula_editor) = NEW zcl_dbbr_formula_editor(
      ir_tabfield_list = lr_tabfields
      is_join_def      = mr_data->mr_s_join_def->*
      iv_display_mode  = zif_dbbr_global_consts=>gc_display_modes-edit
      iv_formula       = COND #( WHEN lr_formula IS BOUND THEN lr_formula->get_formula_string( ) )
    ).

    lr_formula_editor->zif_uitb_view~show( ).

    IF lr_formula_editor->has_formula_been_activated( ).
      lr_formula = lr_formula_editor->get_formula( ).
      TRY.
          zcl_dbbr_formula_helper=>update_tabflds_from_formula(
              ir_tabfields = lr_tabfields
              ir_formula   = lr_formula
          ).
        CATCH zcx_dbbr_formula_exception INTO DATA(lr_exception).
*........ should not happen at this point at all because formula has just been activated
          lr_exception->zif_dbbr_exception_message~print( ).
      ENDTRY.
    ELSEIF lr_formula_editor->has_formula_been_deleted( ).
      CLEAR lr_formula.
      lr_tabfields->delete_formula_fields( ).
      lr_tabfields->clear_calculation_flag( ).
    ENDIF.

    mr_data->set_formula( lr_formula ).

  ENDMETHOD.


  METHOD show_history.
    IF if_force_hide = abap_true.
      IF mr_entity_history_view IS INITIAL.
        RETURN.
      ELSEIF mr_entity_history_view->is_visible( ).
        mr_entity_history_view->dispose( ).
      ENDIF.
    ENDIF.

    IF mr_entity_history_view IS INITIAL.
      mr_entity_history_view = NEW #( ).
    ENDIF.

    IF mr_entity_history_view->is_visible( ).
      mr_entity_history_view->dispose( ).
    ELSE.
      mr_entity_history_view->show( ).
    ENDIF.
  ENDMETHOD.


  METHOD show_multi_or.
    " create table and view controller for screen handling
    DATA(lr_multi_or_table) = NEW zcl_dbbr_multi_or_table( ).

    DATA(lr_multi_or_controller) = NEW zcl_dbbr_multi_or_controller(
        ir_custom_f4_map      = mr_data->mr_custom_f4_map
        it_multi_selfield_all = mr_data->mr_t_selfields_multi->*
        ir_multi_or_table     = lr_multi_or_table
        it_multi_or_all       = mt_multi_or_all
    ).

    " call the screen
    lr_multi_or_controller->zif_uitb_screen_controller~call_screen( ).

    " Was a data transfer requested?
    IF lr_multi_or_controller->should_data_be_transferred( ).
      mt_multi_or_all = lr_multi_or_controller->get_multi_or_values( ).
    ENDIF.

  ENDMETHOD.


  METHOD show_multi_select.
    zcl_dbbr_app_starter=>show_multi_select(
      EXPORTING
        iv_current_line   = mr_selection_table->get_current_line( )
        ir_custom_f4_map  = mr_data->mr_custom_f4_map
      CHANGING
        ct_selfield       = mr_data->mr_t_table_data->*
        ct_selfield_multi = mr_data->mr_t_selfields_multi->*
    ).
  ENDMETHOD.


  METHOD show_object_list.

    mr_util->get_entity_information(
      IMPORTING
        ev_entity      = DATA(lv_entity_id)
        ev_type        = DATA(lv_entity_type)
    ).
    IF lv_entity_id IS INITIAL.
      MESSAGE |Please enter a { SWITCH #( lv_entity_type WHEN 'C' THEN 'CDS View' WHEN 'T' THEN 'Table' WHEN 'Q' THEN 'Query' ) } first!| TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.

    IF mf_object_navigator = abap_false.
      show_object_navigator( ).
    ENDIF.

    mr_navigator->update_view( zcl_dbbr_object_navigator=>c_view-object_browser ).
    zcl_dbbr_selscr_nav_events=>raise_display_object_list(
        iv_entity_id   = lv_entity_id
        iv_entity_type = lv_entity_type
    ).

    mr_navigator->focus( ).
  ENDMETHOD.


  METHOD show_object_navigator.
    mf_object_navigator = xsdbool( mf_object_navigator = abap_false ).

    IF mf_object_navigator = abap_true.
      IF mr_navigator IS INITIAL.
        mr_navigator = NEW #( ).
      ENDIF.
      mr_navigator->show( ).
      mr_cursor->set_is_updated( ).

*.... force navigation history to hide and then to show
      show_history( if_force_hide = abap_true ).
    ELSE.
      mr_navigator->hide( ).
    ENDIF.
  ENDMETHOD.


  METHOD update_aggrgtd_tabfield_list.
    DATA: lt_tab_range TYPE zdbbr_tabname_range_itab.

    mr_data->mr_tabfield_aggr_list->clear( ).

*.. Fetch table list from ungrouped tabfield list
    DATA(lt_tables) = mr_data->mr_tabfield_list->get_table_list( ).

    LOOP AT mr_data->mr_t_table_data->* ASSIGNING FIELD-SYMBOL(<ls_selfield>) WHERE group_by = abap_true
                                                                              OR aggregation <> space.

      " get existing field in ungrouped tabfield list
      DATA(ls_tabfield) = mr_data->mr_tabfield_list->get_field( iv_tabname   = <ls_selfield>-tabname
                                                                iv_fieldname = <ls_selfield>-fieldname ).

      IF ls_tabfield IS INITIAL.
        CONTINUE.
      ENDIF.

      ls_tabfield-output_order = sy-tabix.
      ls_tabfield-output_active = abap_true.

      IF <ls_selfield>-group_by = abap_true.
        ls_tabfield-sort_active = abap_true.
        ls_tabfield-sort_order = sy-tabix.
        ls_tabfield-sort_direction = zif_dbbr_global_consts=>gc_sort_direction-ascending.
      ELSEIF <ls_selfield>-aggregation <> space.
        CLEAR: ls_tabfield-sort_active,
               ls_tabfield-sort_order,
               ls_tabfield-sort_direction.
      ENDIF.

      lt_tab_range = VALUE #( BASE lt_tab_range ( sign = 'I' option = 'EQ' low = ls_tabfield-tabname ) ).

      mr_data->mr_tabfield_aggr_list->add( REF #( ls_tabfield ) ).

      IF ls_tabfield-has_text_field = abap_true.
        DATA(lr_text_tabfield) = mr_data->mr_tabfield_list->get_field_ref(
           iv_tabname_alias       = <ls_selfield>-tabname
           iv_fieldname     = <ls_selfield>-fieldname
           if_is_text_field = abap_true
        ).
        DATA(ls_text_tabfield) = lr_text_tabfield->*.
        ls_text_tabfield-output_active = abap_false.
        ls_text_tabfield-output_order = 0.

        mr_data->mr_tabfield_aggr_list->add( REF #( ls_text_tabfield ) ).
      ENDIF.
    ENDLOOP.

    SORT lt_tab_range BY low.
    DELETE ADJACENT DUPLICATES FROM lt_tab_range.

    DELETE lt_tables WHERE tabname NOT IN lt_tab_range.

    mr_data->mr_tabfield_aggr_list->set_table_list( lt_tables ).
  ENDMETHOD.


  METHOD update_alv_variant.
    CLEAR: mr_data->mr_s_global_data->alv_variant,
           mr_data->mr_s_global_data->alv_varianttext.
  ENDMETHOD.


  METHOD update_util.
    DATA(lv_mode) = COND #( WHEN iv_mode IS NOT INITIAL THEN iv_mode
                                                        ELSE mr_data->mr_s_entity_info->entity_type ).
    mr_data->set_mode( lv_mode ).

    IF mr_util IS BOUND.
      mr_util->free_resources( ).
      SET HANDLER: on_request_new_entity FOR mr_util ACTIVATION abap_false.
    ENDIF.

    mr_util = zcl_dbbr_selscreen_util_fac=>create_util_instance( mr_data ).

    SET HANDLER: on_request_new_entity FOR mr_util.
  ENDMETHOD.


  METHOD zif_uitb_screen_controller~call_screen.
    mf_first_call = abap_true.

    zcl_uitb_screen_util=>call_screen(
        iv_screen_id    = get_screen_id( )
        iv_report_id    = get_report_id( )
    ).

  ENDMETHOD.


  METHOD zif_uitb_screen_controller~cancel.
    IF iv_function_code = zif_dbbr_global_consts=>gc_function_codes-quit_program.
      zcl_dbbr_screen_helper=>quit_program( ).
    ELSE.
      zif_uitb_screen_controller~free_screen_resources( ).
      zcl_dbbr_screen_helper=>leave_screen( ).
    ENDIF.
  ENDMETHOD.


  METHOD zif_uitb_screen_controller~free_screen_resources.
    IF mr_navigator IS BOUND.
      mr_navigator->free( ).
      CLEAR: mr_navigator.
    ENDIF.

    IF mr_entity_history_view IS BOUND.
      mr_entity_history_view->dispose( ).
      CLEAR mr_entity_history_view.
    ENDIF.

    mr_util->free_resources( ).
    CLEAR mr_util.

    SET HANDLER:
      on_toolbar_button_pressed ACTIVATION abap_false,
      on_faventry_selected ACTIVATION abap_false,
      on_variant_faventry_selected ACTIVATION abap_false,
      on_fav_tree_event ACTIVATION abap_false,
      on_request_object_search ACTIVATION abap_false.

    zcl_dbbr_toolbar_util=>free_selscreen_entity_tb( ).
  ENDMETHOD.


  METHOD zif_uitb_screen_controller~get_report_id.
    result = zif_dbbr_c_report_id=>main.
  ENDMETHOD.


  METHOD zif_uitb_screen_controller~get_screen_id.
    result = zif_dbbr_screen_ids=>c_selection_screen.
  ENDMETHOD.


  METHOD zif_uitb_screen_controller~handle_user_command.
    TRY .
        " save current user function
        mv_current_function = cv_function_code.

        CLEAR: cv_function_code.

        IF mf_group_fields_updated = abap_true.
          update_aggrgtd_tabfield_list( ).
        ENDIF.

        " always get the current line in the selection table
        DATA(lv_current_index) = mr_selection_table->get_current_line( ).
        mr_cursor = zcl_uitb_cursor=>get_cursor( ).

*...... Handle changed entity type
        IF mv_current_function = zif_dbbr_c_selscreen_functions=>change_entity_type.
          CLEAR: mr_data->mr_s_entity_info->entity_id.
          CLEAR ms_entity_update.
          ms_entity_update-is_initial = abap_true.
*........ update the entity type in the entity id search help program
          mr_util->update_entity_type_sh( ).
          mr_cursor->set_field( |{ zif_dbbr_main_report_var_ids=>c_s_entity_info }-ENTITY_ID| ).
          mr_cursor->request_update( ).
          update_util( ).
        ENDIF.

*...... Handle the entered value of a new entity
        IF ms_entity_update-is_new = abap_true.
*........ Load the new entity
          load_entity(
              iv_entity_id    = mr_data->mr_s_entity_info->entity_id
              iv_entity_type  = mr_data->mr_s_entity_info->entity_type
          ).
          CLEAR ms_entity_update.
        ELSEIF ms_entity_update-is_initial = abap_true.
          mr_util->clear( ).
          CLEAR ms_entity_update.
          RETURN.
        ELSEIF ms_entity_update-error_ref IS BOUND.
*........ Raise the error
          RAISE EXCEPTION ms_entity_update-error_ref.
        ENDIF.

*...... handle parameter lines
        CHECK handle_parameter_line( ).

        IF mv_current_function = zif_dbbr_c_selscreen_functions=>count_lines OR
           mv_current_function = zif_dbbr_c_selscreen_functions=>execute_selection OR
           mv_current_function = zif_dbbr_c_selscreen_functions=>exec_selection_without_grp OR
           mv_current_function = zif_dbbr_c_selscreen_functions=>save_variant.

          mr_selection_table->expand_all_table_fields( mr_data->mr_tabfield_list  ).
          mr_util->check_mandatory_fields( ).
        ENDIF.

        CASE mv_current_function.
          WHEN zif_dbbr_c_selscreen_functions=>edit_alternative_coltexts.
            edit_alternative_col_texts( ).

          WHEN zif_dbbr_c_selscreen_functions=>select_option_equal.
            set_select_option( iv_current_line = lv_current_index
                               iv_option       = zif_dbbr_global_consts=>gc_options-eq
                               iv_sign         = zif_dbbr_global_consts=>gc_options-i ).

          WHEN zif_dbbr_c_selscreen_functions=>select_option_not_equal.
            set_select_option( iv_current_line = lv_current_index
                               iv_option       = zif_dbbr_global_consts=>gc_options-ne
                               iv_sign         = zif_dbbr_global_consts=>gc_options-i ).

          WHEN zif_dbbr_c_selscreen_functions=>show_formula_manager.
            show_formula_manager( ).

          WHEN zif_dbbr_c_selscreen_functions=>multi_or_selection.
            show_multi_or( ).

          WHEN zif_dbbr_c_selscreen_functions=>control_sort_fields.
            mr_util->choose_sort_fields( ).

          WHEN zif_dbbr_c_selscreen_functions=>control_output_fields.
            mr_util->choose_tabfields( zif_dbbr_global_consts=>gc_field_chooser_modes-output ).

          WHEN zif_dbbr_c_selscreen_functions=>control_sel_fields.
            IF mr_util->choose_tabfields( zif_dbbr_global_consts=>gc_field_chooser_modes-selection ).
              update_aggrgtd_tabfield_list( ).
            ENDIF.

          WHEN zif_dbbr_c_selscreen_functions=>save_query.
            save_query( ).

          WHEN zif_dbbr_c_selscreen_functions=>show_option_dialog.
            handle_option_selection( ).

          WHEN zif_dbbr_c_selscreen_functions=>show_multi_select_dialog.
            show_multi_select( ).

          WHEN zif_dbbr_c_selscreen_functions=>search_table.
            search( ).

          WHEN zif_dbbr_c_selscreen_functions=>search_table_continue.
            search_next( ).

          WHEN zif_dbbr_c_selscreen_functions=>delete_line_input.
            mr_selection_table->zif_uitb_table~delete_current_line( ).

          WHEN zif_dbbr_c_selscreen_functions=>select_additional_texts.
            determine_optional_text_fields( ).

          WHEN zif_dbbr_c_selscreen_functions=>activate_tech_view.
            IF mr_data->mr_s_global_data->tech_view = abap_true.
              mr_data->mr_s_global_data->tech_view = abap_false.
              MESSAGE s080(zdbbr_info) WITH 'off'(008).
            ELSE.
              mr_data->mr_s_global_data->tech_view = abap_true.
              MESSAGE s080(zdbbr_info) WITH 'on'(009).
            ENDIF.

          WHEN zif_dbbr_c_selscreen_functions=>count_lines.
            execute_selection( if_count_lines_only = abap_true ).

          WHEN zif_dbbr_c_selscreen_functions=>execute_selection.
            execute_selection( ).

          WHEN zif_dbbr_c_selscreen_functions=>exec_selection_without_grp.
            execute_selection( if_no_grouping = abap_true ).

          WHEN zif_dbbr_c_selscreen_functions=>delete_joins.
            mr_util->delete_join_definition( ).

          WHEN zif_dbbr_c_selscreen_functions=>define_joins.
            define_join_relations( ).

          WHEN zif_dbbr_global_consts=>gc_function_codes-quit_program.
            zcl_dbbr_screen_helper=>quit_program( ).

          WHEN zif_dbbr_global_consts=>gc_function_codes-leave_screen OR
               zif_dbbr_global_consts=>gc_function_codes-cancel_screen.
            zif_uitb_screen_controller~free_screen_resources( ).
            zcl_dbbr_screen_helper=>leave_screen( ).

          WHEN zif_dbbr_c_selscreen_functions=>show_technical_settings.
            DATA(lv_previous_language) = mr_data->mr_s_global_data->description_language.
            zcl_dbbr_app_starter=>show_user_settings( CHANGING cs_settings = mr_data->mr_s_global_data->settings ).
            IF zcl_dbbr_appl_util=>get_description_language( ) <> lv_previous_language.
              mr_util->update_description_texts( ).
            ENDIF.

          WHEN zif_dbbr_c_selscreen_functions=>save_variant.
            save_variant( ).

          WHEN zif_dbbr_c_selscreen_functions=>get_variant.
            read_variant( ).

          WHEN zif_dbbr_c_selscreen_functions=>delete_variant.
            delete_variant( ).

          WHEN zif_dbbr_c_selscreen_functions=>delete_all_input.
            mr_selection_table->zif_uitb_table~delete_all( ).

          WHEN zif_dbbr_c_selscreen_functions=>go_to_next_table.
            mr_selection_table->scroll_to_next_table( mr_data->mr_tabfield_list->get_table_list( if_include_only_active = abap_true ) ).

          WHEN zif_dbbr_c_selscreen_functions=>go_to_previous_table.
            mr_selection_table->scroll_to_previous_table( mr_data->mr_tabfield_list->get_table_list( if_include_only_active = abap_true ) ).

          WHEN zif_dbbr_c_selscreen_functions=>check_edit_option.
            IF mr_data->mr_s_global_data->edit = abap_true.
              CLEAR: mr_data->mr_s_global_data->delete_mode.
              mr_util->delete_join_definition( ).
            ENDIF.

          WHEN zif_dbbr_c_selscreen_functions=>maintain_value_helps.
            NEW zcl_dbbr_f4_manager( )->zif_uitb_view~show( ).

          WHEN zif_dbbr_c_selscreen_functions=>save_f4_at_field.
            save_built_in_f4( ).

          WHEN zif_dbbr_c_selscreen_functions=>delete_f4_from_field.
            delete_f4_helps( ).

          WHEN zif_dbbr_global_consts=>gc_function_codes-scroll_to_top.
            mr_selection_table->zif_uitb_page_scroller~scroll_page_top( ).

          WHEN zif_dbbr_global_consts=>gc_function_codes-scroll_page_up.
            mr_selection_table->zif_uitb_page_scroller~scroll_page_up( ).

          WHEN zif_dbbr_global_consts=>gc_function_codes-scroll_page_down.
            mr_selection_table->zif_uitb_page_scroller~scroll_page_down( ).

          WHEN zif_dbbr_global_consts=>gc_function_codes-scroll_to_bottom.
            mr_selection_table->zif_uitb_page_scroller~scroll_page_bottom( ).

          WHEN zif_dbbr_c_selscreen_functions=>delete_aggregations.
            delete_aggregations( ).

          WHEN zif_dbbr_c_selscreen_functions=>delete_all_or_tuple.
            CLEAR mt_multi_or_all.

          WHEN zif_dbbr_c_selscreen_functions=>define_sub_queries.
            define_subqueries( ).

          WHEN zif_dbbr_c_selscreen_functions=>expand_collapse_table_fields.
            mr_selection_table->expand_collapse_table_fields( mr_data->mr_tabfield_list ).

          WHEN zif_dbbr_c_selscreen_functions=>expand_all_tables.
            mr_selection_table->expand_all_table_fields( mr_data->mr_tabfield_list  ).

          WHEN zif_dbbr_c_selscreen_functions=>collapse_all_tables.
            mr_selection_table->collapse_all_table_fields( mr_data->mr_tabfield_list ).

          WHEN zif_dbbr_c_selscreen_functions=>display_entity_navigator.
            show_object_navigator( ).

          WHEN zif_dbbr_c_selscreen_functions=>delete_mode.
            IF mr_data->mr_s_global_data->delete_mode = abap_true.
              CLEAR mr_data->mr_s_global_data->edit.
              " delete existing join
              mr_util->delete_join_definition( ).
            ENDIF.

          WHEN zif_dbbr_c_selscreen_functions=>pick_navigation.
            pick_navigate( ).

          WHEN zif_dbbr_c_selscreen_functions=>set_focus_to_navigator.
            set_focus_to_navigator( ).

          WHEN zif_dbbr_c_selscreen_functions=>set_focus_to_1st_selfield.
            set_focus_to_1st_selfield( ).

          WHEN zif_dbbr_c_selscreen_functions=>manage_associations.
            CHECK mr_usersettings_f->is_experimental_mode_active( ).
            NEW zcl_dbbr_association_manager( )->zif_uitb_view~show( ).

          WHEN zif_dbbr_c_selscreen_functions=>choose_different_entity.
            choose_other_entity( ).

          WHEN zif_dbbr_c_selscreen_functions=>show_query_catalog.
            CALL TRANSACTION 'ZDBBR_QUERYCATALOG'.

          WHEN zif_dbbr_c_selscreen_functions=>navigate_back.
            zcl_dbbr_selscreen_history=>navigate_back( ).

          WHEN zif_dbbr_c_selscreen_functions=>navigate_forward.
            zcl_dbbr_selscreen_history=>navigate_forward( ).

          WHEN zif_dbbr_c_selscreen_functions=>show_navigation_history.
            show_history( ).

          WHEN zif_dbbr_c_selscreen_functions=>import_favorites.
            NEW zcl_dbbr_favmenu_importer( )->import_data( ).

          WHEN zif_dbbr_c_selscreen_functions=>export_favorites.
            NEW zcl_dbbr_export_favmenu_ctrl( )->zif_uitb_screen_controller~call_screen( ).

          WHEN zif_dbbr_c_selscreen_functions=>open_specific_extended_search.
            perform_extended_search( ).

          WHEN zif_dbbr_c_selscreen_functions=>set_field_lowercase.
            mr_selection_table->set_lowercase_setting( ).

          WHEN zif_dbbr_c_selscreen_functions=>display_object_list.
            show_object_list( ).

          WHEN zif_dbbr_c_selscreen_functions=>object_browser_search.
            search_objects( ).

          WHEN zif_dbbr_c_selscreen_functions=>goto_next_obj_navigator_view.
            zcl_dbbr_selscr_nav_events=>raise_goto_nxt_view_in_objnav( ).

          WHEN zif_dbbr_c_selscreen_functions=>display_db_browser_version.
            zcl_dbbr_version=>show_version( ).

          WHEN zcl_dbbr_help_repository=>c_help_ucomm.
            zcl_dbbr_help_repository=>show_help( zcl_dbbr_help_repository=>c_help_id-main_entry ).

*........ if function code code not be found try the util for enitity specific
*........ function handlers.
          WHEN OTHERS.
            mr_util->zif_dbbr_screen_util~handle_ui_function( CHANGING cv_function = mv_current_function ).

        ENDCASE.

      CATCH zcx_dbbr_validation_exception INTO DATA(lr_valid_exc).
*        CLEAR ms_entity_update.
        IF lr_valid_exc->parameter_name IS NOT INITIAL.
          mr_cursor->set_line( lr_valid_exc->loop_line ).
          mr_cursor->set_field( lr_valid_exc->parameter_name ).
          mr_cursor->request_update( ).
        ENDIF.
        lr_valid_exc->print_message( iv_msg_type = 'S' iv_display_type = 'E' ).
    ENDTRY.
  ENDMETHOD.


  METHOD zif_uitb_screen_controller~load_context_menu.
    DATA: ls_current_line TYPE zdbbr_selfield.

    cl_ctmenu=>load_gui_status(
      program = get_report_id( )
      status  = '0100_CTX_SELFIELD'
      menu    = ir_menu
    ).

    mr_util->get_entity_information(
      IMPORTING ev_type        = DATA(lv_entity_type)
    ).

    DATA(lr_s_current_line) = CAST zdbbr_selfield( mr_selection_table->zif_uitb_table~get_current_line_ref( ) ).

    IF lr_s_current_line->convexit = space.

      IF ( lr_s_current_line->inttype = cl_abap_typedescr=>typekind_char OR
           lr_s_current_line->inttype = cl_abap_typedescr=>typekind_string ).
        ir_menu->add_separator( ).
        ir_menu->add_function(
          fcode   = zif_dbbr_c_selscreen_functions=>set_field_lowercase
          text    = 'Allow Case Sensitive Input'(010)
          checked = lr_s_current_line->lowercase
        ).
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD zif_uitb_screen_controller~pbo.
    DATA ls_screen TYPE screen.

    IF mf_first_call = abap_true.
      mr_cursor = zcl_uitb_cursor=>get_cursor( ).
      CLEAR: mf_first_call.

      mr_navigator = NEW #( ).

      IF mr_data->mr_s_global_data->settings-object_navigator_open = abap_true.
        show_object_navigator( ).
      ENDIF.
    ENDIF.

    IF mv_current_function = zif_dbbr_c_selscreen_functions=>goto_next_obj_navigator_view OR
       mv_current_function = zif_dbbr_c_selscreen_functions=>display_object_list.
      mr_navigator->focus( ).
    ELSE.
      set_cursor( ).
    ENDIF.


    LOOP AT SCREEN.
      IF screen-name = 'BTN_EXTENDED_SEARCH'.
        IF mf_from_central_search = abap_true.
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDIF.

      IF screen-group4 = 'EDT'.
        screen-input = COND #( WHEN mr_data->is_join_active( ) OR mr_data->mr_s_settings->disable_edit = abap_true THEN
                                    0
                                  ELSE
                                    1 ).
        MODIFY SCREEN.
      ENDIF.

      IF screen-name = 'GS_DATA-DELETE_MODE'.
        IF mr_data->mr_s_global_data->advanced_mode = abap_false.
          screen-active = 0.
        ELSE.
          screen-active = 1.
        ENDIF.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.

    mr_util->handle_pbo( ).

    DATA(lr_table_func_exec) = NEW zcl_uitb_table_func_executor( mr_data->mr_t_table_data ).

    DATA(lv_count) = lr_table_func_exec->count_lines(
        it_field_selopts = VALUE #(
            ( fieldname = 'IS_TABLE_HEADER' selopt_itab = VALUE #( ( sign = 'I' option = 'EQ' low = abap_false ) ) )
        )
    ).
    DATA(lv_current_index) = mr_selection_table->get_current_line( if_reset_index = abap_false ).
    mr_data->mr_v_seltable_counter_text->* = COND #( WHEN lv_count > 0 THEN |{ mr_data->mr_s_tableview->top_line } / { lv_count }| ELSE '' ) .

    zif_uitb_screen_controller~set_status( ).
  ENDMETHOD.


  METHOD zif_uitb_screen_controller~set_status.
    DATA: lt_func_codes TYPE TABLE OF sy-ucomm.

    mr_util->set_custom_functions( ).

    IF mr_data->mr_s_settings->disable_joins = abap_true.
      lt_func_codes = VALUE #( BASE lt_func_codes ( zif_dbbr_c_selscreen_functions=>define_joins ) ).
    ENDIF.

    " set dynamic gui status texts
    mr_data->mr_v_seltext_gui->text = 'Select Additional Fields'(001).

    IF mr_data->mr_s_join_def->tables IS INITIAL.
      APPEND zif_dbbr_c_selscreen_functions=>delete_joins TO lt_func_codes.
    ENDIF.

    mr_data->mr_v_multi_or_icon->icon_text = 'More'(003).
    mr_data->mr_v_multi_or_icon->quickinfo = 'Multiple Selection with OR Tuples'(002).

    IF mt_multi_or_all IS NOT INITIAL.
      mr_data->mr_v_multi_or_icon->icon_id = zif_dbbr_c_icon=>display_more.
    ELSE.
      mr_data->mr_v_multi_or_icon->icon_id = zif_dbbr_c_icon=>enter_more.
    ENDIF.

    IF NOT mr_selection_table->aggregation_is_active( ).
      APPEND zif_dbbr_c_selscreen_functions=>exec_selection_without_grp TO lt_func_codes.
    ENDIF.

*... handle navigate forward function activation
    IF NOT zcl_dbbr_selscreen_history=>has_next( ).
      lt_func_codes = VALUE #( BASE lt_func_codes ( zif_dbbr_c_selscreen_functions=>navigate_forward ) ).
    ENDIF.
*... handle navigate back function activation
    IF NOT zcl_dbbr_selscreen_history=>has_previous( ).
      lt_func_codes = VALUE #( BASE lt_func_codes ( zif_dbbr_c_selscreen_functions=>navigate_back ) ).
    ENDIF.

    IF mf_object_navigator = abap_false.
      lt_func_codes = VALUE #( BASE lt_func_codes
        ( zif_dbbr_c_selscreen_functions=>set_focus_to_navigator )
        ( zif_dbbr_c_selscreen_functions=>goto_next_obj_navigator_view )
      ).
    ENDIF.

    " add deactivated functions depending on current entity type
    lt_func_codes = VALUE #( BASE lt_func_codes ( LINES OF mr_util->get_deactivated_functions( ) ) ).

    SET PF-STATUS '0100' EXCLUDING lt_func_codes OF PROGRAM zif_dbbr_c_report_id=>main.

    DATA(lv_title) = mr_util->get_title( ).

    SET TITLEBAR 'PROGTITLE' OF PROGRAM zif_dbbr_c_report_id=>main WITH lv_title.
  ENDMETHOD.
ENDCLASS.