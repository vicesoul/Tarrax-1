def learning_plan_model(opts={})
  @learning_plan = factory_with_protected_attributes(LearningPlan, valid_learning_plan_attributes.merge(opts))
end

def valid_learning_plan_attributes
  {
    :account => Account.default,
    :subject => 'subject sample ...',
    :start_on => 1.month.ago,
    :end_on => Date.current
  }
end
