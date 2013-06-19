class CourseSystem < ActiveRecord::Base
  belongs_to :account
  belongs_to :job_position
  belongs_to :course

  MANDATORY   = 'mandatory'
  OPTIONAL    = 'optional'
  RECOMMENDED = 'recommended'

  RANKS = [ MANDATORY, OPTIONAL, RECOMMENDED ].freeze

  attr_accessible :account, :job_position, :course, :rank
  validates_inclusion_of :rank, :in => RANKS
  validates_presence_of :course, :account, :rank

  named_scope :with_rank, lambda { |rank|
    { :conditions => ["rank = ?", rank] }
  }

  named_scope :of_course_category, lambda { |category|
    { :joins => :course, :conditions => {:courses => {:course_category_id => category}} }
  }

  named_scope :of_account, lambda { |account|
    { :conditions => {:account_id => account} }
  }

  named_scope :of_job_position, lambda { |job_position|
    { :conditions => {:job_position_id => job_position} }
  }

  named_scope :of_user_account, lambda { |user, account|
    account_ids = account.root_account.self_and_all_sub_accounts
    { :include => {:job_position => :user_account_associations},
      :order => 'course_systems.id',
      :conditions => [<<-SQL, account_ids, account_ids, user.id] }
        course_systems.job_position_id IS NULL AND course_systems.account_id IN (?)
        OR course_systems.account_id IN (?) AND user_account_associations.account_id = course_systems.account_id
        AND user_account_associations.user_id = ?
      SQL
  }

  named_scope :of_user, lambda { |user|
    { :joins => {:account => :user_account_associations},
      :conditions => ["user_account_associations.user_id = ?", user.id] }
  }

  set_policy do
    given { |user, session| account.grants_right? user, session, :manage_course_systems }
    can :read and can :update
  end

  # return courses grouped by rank
  #
  # course_systems - course_system array
  #
  # return a hash with key for rank, value for courses array
  def self.group_courses_by_rank course_systems
    grouped_course_systems = course_systems.group_by &:rank
    RANKS.inject({}) do |hash, rank|
      hash[rank] = (grouped_course_systems[rank] || []).map &:course
      hash
    end
  end

  # i18n for ranks
  def self.ranks
    {
      MANDATORY   => t('ranks.mandatory', "Mandatory"),
      OPTIONAL    => t('ranks.optional', "Optional"),
      RECOMMENDED => t('ranks.recommended', "Recommended")
    }
  end

  # only use course_system with courses of highest priority rank
  #
  # Examples:
  #
  #     course = Course.new
  #     array = [
  #       cs1 = CourseSystem.new(course: course, rank: 'mandatory'),
  #       cs2 = CourseSystem.new(course: course, rank: 'optional')
  #     ]
  #
  #     CourseSystem.uniq array
  #     # => [cs1]
  #
  # cs_array - course_systems array
  #
  # return a new array by removing course with lower priority rank
  def self.uniq cs_array
    CourseSystemArray.new(cs_array).uniq
  end
end

# for select CourseSystem with rank
class CourseSystemArray < DelegateClass(Array)
  def initialize a
    super
  end

  def uniq
    self.inject({}) do |hash, e|
      if old = hash[e.course_id] # if exists
        hash[e.course_id] = e if old.rank > e.rank     # replace with higher rank
      else
        hash[e.course_id] = e unless hash[e.course_id] # otherwise add it
      end
      hash
    end.values
  end

  def uniq!
    __setobj__ uniq
  end
end
