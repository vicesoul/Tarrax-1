class LearningPlan < ActiveRecord::Base
  include Workflow

  attr_accessible :subject, :start_on, :end_on, :workflow_state, :learning_plan_users_attributes, :learning_plan_courses_attributes
  attr_accessible :section_mappings

  validates_presence_of :subject, :start_on, :end_on

  serialize :section_mappings

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

  # Make destroy logical
  # user destroy! to delete plan phisically
  alias_method :destroy!, :destroy
  def destroy
    self.workflow_state = 'deleted'
    self.save
  end

  # return enrollment_type by role name
  #
  # role_name - role_base_name or custom role name of an account
  #
  # returns {:type => role_type, :name => role_name}
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

  # Enroll users for all plan courses.
  # Skip user who had been enrolled already
  def enroll_users
    learning_plan_users.each do |lpu|
      next unless lpu.enrollable?

      count = 0
      role = enrollment_type_for_name(lpu.role_name)
      self.courses.each do |c|
        # decide a section name for user
        section_name = section_name_from_account_tree lpu.user, self.section_mappings

        # find or create a section if section_name avaliable, otherwise use nil which mean use default section of a course
        section = section_name && c.course_sections.active.find_or_create_by_name(section_name)

        # enroll user
        enrollment = c.enroll_user lpu.user, role[:type], {:section => section, :role_name => role[:name], :learning_plan => self}

        # plus count if we build it
        count += 1 if enrollment.learning_plan_id == self.id # already enrolled or maybe by other plans
      end

      if count == self.courses.size
        # mark it enrolled
        lpu.enroll!
      elsif count > 0
        # mark it part enrolled
        lpu.part_enroll!
      end
    end
  end

  # Revert all enrollments by learning plans
  def revert_enrollments
    enrollments.active.each &:destroy
    learning_plan_users.each do |lpu|
      lpu.revert! if lpu.revertable?
    end
  end

  def publishable?
    %w(initial reverted).include? workflow_state
  end

  def revertable?
    %w(published).include? workflow_state
  end

  def editable?
    %w(initial reverted).include? workflow_state
  end

  def deleteable?
    %w(initial reverted).include? workflow_state
  end

  # return accounts including plan users
  def account_tree
    @account_tree ||= begin
      accounts = account.sub_accounts_recursive(1000, 0).map do |a|
        a unless UserAccountAssociation.find(:all, :conditions => ['account_id = ? AND user_id IN (?)', a.id, users.map(&:id)]).empty?
      end

      accounts << account
      accounts.compact!

      tree = build_tree account, accounts
    end
  end

  private
    # recursive method helper to build an account tree
    # 
    # account - account as parent node of a tree
    # white_list - accounts only in white list will be used to build tree
    # 
    # hash of tree 
    def build_tree account, white_list
      children = []
      account.sub_accounts.each do |a|
        children << build_tree(a, white_list) if white_list.include? a
      end

      {:id => account.id, :name => account.name, :children => children}
    end

    # decide section name for a user with account ids
    #
    # user - User who will attend to a course
    # account_ids - account ids wich be used to decide a section name user will attend to
    #
    # return section name
    def section_name_from_account_tree user, account_ids
      uaa = user.user_account_associations.find_all_by_account_id account_ids
      Account.find(uaa.map(&:account_id).max).name rescue nil # for simple, use max account_id as the deepest account
    end
end
