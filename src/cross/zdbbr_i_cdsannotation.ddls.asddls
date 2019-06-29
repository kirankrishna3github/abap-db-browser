@AbapCatalog.sqlViewName: 'ZDBBRICDSANNO'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Annotations for CDS Views'
define view ZDBBR_I_CdsAnnotation
  as select from ddfieldanno
{
  strucobjn                       as EntityId,
  lfieldname                      as FieldName,
  name                            as Name,
  value						 	  as Value
}
union select from ddheadanno
{
  strucobjn                       as EntityId,
  ''                              as FieldName,
  name                            as Name,
  value                           as Value
}