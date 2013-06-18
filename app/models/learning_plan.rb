class LearningPlan < ActiveRecord::Base
  include Workflow

  attr_accessible :subject, :start_on, :end_on, :notify_on, :workflow_state, :learning_plan_users_attributes, :learning_plan_courses_attributes
  validates_presence_of :subject

  belongs_to :account
  has_many :learning_plan_users, :dependent => :destroy
  has_many :learning_plan_courses, :dependent => :destroy
  has_many :users, :through => :learning_plan_users
  has_many :courses, :through => :learning_plan_courses
  has_many :enrollments

  accepts_nested_attributes_for :learning_plan_users, :allow_destroy => true
  accepts_nested_attributes_for :learning_plan_courses, :allow_destroy => true

  named_scope :active, :conditions => ['learning_plans.workflow_state != ?', 'deleted']

  named_scope :of_account, lambda { |account|
    {:conditions => {:account_id => account.id}}
  }

  set_policy do
    given { |user, session| account.grants_right? user, session, :manage_learning_plans }
    can :read and can :update and can :delete and can :publish and can :revert
  end

  workflow do
    state :initial do
      event :publish, :transitions_to => :published do
        enroll_users
        touch :published_at
      end
    end

    state :published do
      event :revert, :transitions_to => :reverted do
        revert_enrollments
      end
    end

    state :reverted do
      event :publish, :transitions_to => :published do
        enroll_users
        touch :published_at
      end
    end

    state :deleted
  end

  def self.states
    {
      'initial'   => t('states.initial', 'Initial'),
      'published' => t('states.published', 'Published'),
      'reverted'  => t('states.reverted', 'Reverted'),
      'deleted'   => t('states.deleted', 'Deleted'),
    }
  end

  alias_method :destroy!, :destroy
  def destroy
    self.workflow_state = 'deleted'
    self.save
  end

  # return enrollment_type by role name
  def enrollment_type_for_name role_name
    @enrollment_type_mappings ||= Hash.new do |hash, key|
      hash[key] = if Role.is_base_role?(key)
        {:type => key}
      else
        if custom_role = account.get_course_role(key)
          {:type => custom_role.base_role_type, :name => key}
        else
          raise t('errors.role_not_found', "No role named '%{role}' exists.", :role => key)
        end
      end
    end

    @enrollment_type_mappings[role_name]
  end

  def enroll_users
    learning_plan_users.each do |lpu|
      next unless lpu.enrollable?

      count = 0
      role = enrollment_type_for_name(lpu.role_name)
      self.courses.each do |c|
        enrollment = c.enroll_user lpu.user, role[:type], {:role_name => role[:name], :learning_plan => self}
        count += 1 if enrollment.learning_plan_id
      end

      if count == self.courses.size
        lpu.enroll!
      elsif count > 0
        lpu.part_enroll!
      end
    end
  end

  def revert_enrollments
    enrollments.active.each &:destroy
    learning_plan_users.each do |lpu|
      lpu.revert! if lpu.revertable?
    end
  end
end
