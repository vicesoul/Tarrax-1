def job_position_model(opts={})
  @job_position = factory_with_protected_attributes(JobPosition, valid_job_position_attributes.merge(opts))
end

def valid_job_position_attributes
  {
    :account => @account || Account.default,
    :job_position_category => @job_position_category || job_position_category_model,
    :rank => 0,
    :code => '0',
    :name => 'job position name'
  }
end

def job_position_category_model(opts={})
  @job_position = factory_with_protected_attributes(JobPositionCategory, valid_job_position_category_attributes.merge(opts))
end

def valid_job_position_category_attributes
  {
    :account => @account || Account.default,
    :name => 'job position category name'
  }
end
