classDiagram
direction BT
class assessments {
   text code_module
   text code_presentation
   text assessment_type
   text date
   double precision weight
   integer id_assessment
}
class courses {
   integer module_presentation_length
   text code_module
   text code_presentation
}
class studentassessment {
   integer date_submitted
   integer is_banked
   text score
   integer id_assessment
   integer id_student
}
class studentinfo {
   text gender
   text region
   text highest_education
   text imd_band
   text age_band
   integer num_of_prev_attempts
   text studied_credits
   text disability
   text final_result
   text code_module
   text code_presentation
   integer id_student
}
class studentregistration {
   integer date_registration
   text date_unregistration
   text code_module
   text code_presentation
   integer id_student
}
class studentvle {
   bigint sum_click
   text code_module
   text code_presentation
   integer id_student
   integer id_site
   text date
}
class vle {
   text code_module
   text code_presentation
   text activity_type
   text week_from
   text week_to
   integer id_site
}

assessments  -->  courses : code_module, code_presentation
studentassessment  -->  assessments : id_assessment
studentinfo  -->  courses : code_module, code_presentation
studentregistration  -->  courses : code_module, code_presentation
studentregistration  -->  studentinfo : code_module, code_presentation, id_student
studentvle  -->  courses : code_module, code_presentation
studentvle  -->  studentinfo : code_module, code_presentation, id_student
studentvle  -->  vle : id_site
vle  -->  courses : code_module, code_presentation
