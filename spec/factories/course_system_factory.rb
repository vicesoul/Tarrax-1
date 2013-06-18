def course_system_model(opts={})
  @course_system = factory_with_protected_attributes(CourseSystem, valid_course_system_attributes.merge(opts))
end

def valid_course_system_attributes
  {
    :account      => @account,
    :job_position => @job_position,
    :course       => @course,
    :rank         => "mandatory"
  }
end
