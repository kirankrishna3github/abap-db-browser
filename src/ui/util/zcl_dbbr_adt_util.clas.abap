"! <p class="shorttext synchronized" lang="en">Utilities for ADT navigation</p>
CLASS zcl_dbbr_adt_util DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    "! <p class="shorttext synchronized" lang="en">Create ADT URI for the given entity</p>
    CLASS-METHODS create_adt_uri
      IMPORTING
        iv_type                    TYPE zdbbr_entity_type OPTIONAL
        iv_tadir_type              TYPE tadir-object OPTIONAL
        iv_name                    TYPE zdbbr_entity_id
        iv_name2                   TYPE zdbbr_entity_id OPTIONAL
      RETURNING
        VALUE(rs_object_reference) TYPE sadt_object_reference.
    "! <p class="shorttext synchronized" lang="en">Open Object with ADT Tools</p>
    CLASS-METHODS jump_adt
      IMPORTING
        iv_obj_name     TYPE tadir-obj_name
        iv_obj_type     TYPE tadir-object
        iv_sub_obj_name TYPE tadir-obj_name OPTIONAL
        iv_sub_obj_type TYPE tadir-object OPTIONAL
        iv_line_number  TYPE i OPTIONAL
      RAISING
        zcx_dbbr_adt_error .
    "! <p class="shorttext synchronized" lang="en">Retrieve adt object and names</p>
    CLASS-METHODS get_adt_objects_and_names
      IMPORTING
        iv_obj_name       TYPE tadir-obj_name
        iv_obj_type       TYPE tadir-object
      EXPORTING
        er_adt_uri_mapper TYPE REF TO if_adt_uri_mapper
        er_adt_objectref  TYPE REF TO cl_adt_object_reference
        ev_program        TYPE progname
        ev_include        TYPE progname
      RAISING
        zcx_dbbr_adt_error .
  PROTECTED SECTION.
  PRIVATE SECTION.

    "! <p class="shorttext synchronized" lang="en">Check if jump is possible for given object</p>
    CLASS-METHODS is_adt_jump_possible
      IMPORTING
        !ir_wb_object                  TYPE REF TO cl_wb_object
        !ir_adt                        TYPE REF TO if_adt_tools_core_factory
      RETURNING
        VALUE(rf_is_adt_jump_possible) TYPE abap_bool
      RAISING
        zcx_dbbr_adt_error .

ENDCLASS.



CLASS zcl_dbbr_adt_util IMPLEMENTATION.


  METHOD get_adt_objects_and_names.
    DATA lv_obj_type       TYPE trobjtype.
    DATA lv_obj_name       TYPE trobj_name.
    FIELD-SYMBOLS <lv_uri> TYPE string.

    lv_obj_name = iv_obj_name.
    lv_obj_type = iv_obj_type.

    cl_wb_object=>create_from_transport_key(
      EXPORTING
        p_object    = lv_obj_type
        p_obj_name  = lv_obj_name
      RECEIVING
        p_wb_object = DATA(lr_wb_object)
      EXCEPTIONS
        OTHERS      = 1 ).
    IF sy-subrc <> 0.
      zcx_dbbr_adt_error=>raise_adt_error_with_text( 'ADT Jump Error' ).
    ENDIF.

    DATA(lr_adt_tools) = cl_adt_tools_core_factory=>get_instance( ).


***    IF is_adt_jump_possible( ir_wb_object = lr_wb_object
***                             ir_adt       = lr_adt_tools ) = abap_false.
***      zcx_dbbr_adt_error=>raise_adt_error_with_text( |ADT Jump is not possible for { iv_obj_type } - { iv_obj_name }| ).
***    ENDIF.


    cl_wb_request=>create_from_object_ref(
      EXPORTING
        p_wb_object       = lr_wb_object
      RECEIVING
        p_wb_request      = DATA(lr_wb_request)
      EXCEPTIONS
        illegal_operation = 1
        cancelled         = 2
        OTHERS            = 3 ).

    IF sy-subrc <> 0.
      zcx_dbbr_adt_error=>raise_adt_error_with_text( 'ADT Jump Error' ).
    ENDIF.

    DATA(lo_vit_adt_mapper) = lr_adt_tools->get_uri_mapper_vit( ).

    IF lo_vit_adt_mapper->is_vit_wb_request( lr_wb_request ).
      er_adt_objectref = lo_vit_adt_mapper->map_wb_request_to_objref( wb_request = lr_wb_request ).
    ELSE.
      er_adt_uri_mapper = lr_adt_tools->get_uri_mapper( ).

      er_adt_objectref = er_adt_uri_mapper->map_wb_object_to_objref(
          wb_object          = lr_wb_object
      ).

      IF ev_program IS SUPPLIED.
        er_adt_uri_mapper->map_objref_to_include(
          EXPORTING
            uri                = er_adt_objectref->ref_data-uri
          IMPORTING
            program            = ev_program
            include            = ev_include
        ).
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD is_adt_jump_possible.
    cl_wb_request=>create_from_object_ref(
      EXPORTING
        p_wb_object       = ir_wb_object
      RECEIVING
        p_wb_request      = DATA(lr_wb_request)
      EXCEPTIONS
        illegal_operation = 1
        cancelled         = 2
        OTHERS            = 3 ).

    IF sy-subrc <> 0.
      zcx_dbbr_adt_error=>raise_adt_error_with_text( 'ADT Jump Error' ).
    ENDIF.

    TRY.
        DATA(lr_adt_uri_mapper_vit) = ir_adt->get_uri_mapper_vit( ).
        rf_is_adt_jump_possible = xsdbool( NOT lr_adt_uri_mapper_vit->is_vit_wb_request( wb_request = lr_wb_request ) ).
      CATCH cx_root.
        zcx_dbbr_adt_error=>raise_adt_error_with_text( 'ADT Jump Error' ).
    ENDTRY.
  ENDMETHOD.


  METHOD jump_adt.
    get_adt_objects_and_names(
      EXPORTING
        iv_obj_name        = iv_obj_name
        iv_obj_type        = iv_obj_type
      IMPORTING
        er_adt_uri_mapper = DATA(lr_adt_uri_mapper)
        er_adt_objectref  = DATA(lr_adt_objref)
        ev_program        = DATA(lv_program)
        ev_include        = DATA(lv_include)
    ).

    TRY.
        IF iv_sub_obj_name IS NOT INITIAL.

          IF ( lv_program <> iv_obj_name AND lv_include IS INITIAL ) OR
             ( lv_program = lv_include AND iv_sub_obj_name IS NOT INITIAL ).
            lv_include = iv_sub_obj_name.
          ENDIF.

          DATA(lr_adt_sub_objref) = lr_adt_uri_mapper->map_include_to_objref(
              program            = lv_program
              include            = lv_include
              line               = iv_line_number
              line_offset        = 0
              end_line           = iv_line_number
              end_offset         = 1
          ).

          IF lr_adt_sub_objref IS NOT INITIAL.
            lr_adt_objref = lr_adt_sub_objref.
          ENDIF.

        ENDIF.

        DATA(lv_adt_link) = |adt://{ sy-sysid }{ lr_adt_objref->ref_data-uri }|.

        cl_gui_frontend_services=>execute( EXPORTING  document = lv_adt_link
                                           EXCEPTIONS OTHERS   = 1 ).

        IF sy-subrc <> 0.
          zcx_dbbr_adt_error=>raise_adt_error_with_text( 'ADT Jump Error' ).
        ENDIF.

      CATCH cx_root.
        zcx_dbbr_adt_error=>raise_adt_error_with_text( 'ADT Jump Error' ).
    ENDTRY.

  ENDMETHOD.

  METHOD create_adt_uri.
    DATA: lv_obj_type LIKE iv_tadir_type.

    IF iv_type IS SUPPLIED.
      lv_obj_type = SWITCH trobjtype(
        iv_type
        WHEN zif_dbbr_c_entity_type=>cds_view THEN 'DDLS'
        WHEN zif_dbbr_c_entity_type=>view THEN 'VIEW'
        WHEN zif_dbbr_c_entity_type=>table THEN 'TABD'
      ).
    ELSEIF iv_tadir_type IS SUPPLIED.
      lv_obj_type = iv_tadir_type.
    ENDIF.

    DATA(lv_name) = SWITCH sobj_name(
      iv_type
      WHEN zif_dbbr_c_entity_type=>cds_view THEN iv_name2
      ELSE                                       iv_name
    ).

    TRY.
        zcl_dbbr_adt_util=>get_adt_objects_and_names(
          EXPORTING
            iv_obj_name       = lv_name
            iv_obj_type       = lv_obj_type
          IMPORTING
            er_adt_objectref  = DATA(lr_adt_objectref)
        ).
        rs_object_reference = lr_adt_objectref->ref_data.
      CATCH zcx_dbbr_adt_error.

    ENDTRY.

  ENDMETHOD.
ENDCLASS.
