module LearningPlansHelper
  def search_params
    prepare_search_params params, :search
  end

  def roles_for_account account
    roles = []
    Role.all_enrollment_roles_for_account(@account).map do |r|
      roles << [ r[:plural_label], r[:name] ]
      r[:custom_roles].each do |cr|
        roles << [ cr[:label], cr[:name] ]
      end
    end
    roles
  end

  def user_accounts(user, account)
    account_ids = account.sub_accounts_recursive(1000, 0).map &:id
    user.user_account_associations.filter_by_account_id(account_ids).map &:account
  end

  def job_positions_from_user_accounts(user, account)
    user.user_account_associations.of_root_account(account).map(&:job_position).compact
  end

  def format_learning_plan_state state
    label = case state
    when 'published'
      'label-success'
    when 'reverted'
      'label-warning'
    when 'deleted'
      'inverse'
    end

    content_tag :span, :class => "label #{label}" do
      LearningPlan.states[state]
    end
  end
end
