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

  def self.group_courses_by_rank course_systems
    grouped_course_systems = course_systems.group_by &:rank
    RANKS.inject({}) do |hash, rank|
      hash[rank] = (grouped_course_systems[rank] || []).map &:course
      hash
    end
  end

  def self.ranks
    {
      MANDATORY   => t('ranks.mandatory', "Mandatory"),
      OPTIONAL    => t('ranks.optional', "Optional"),
      RECOMMENDED => t('ranks.recommended', "Recommended")
    }
  end

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
        hash[e.course_id] = e if old.rank > e.rank     # replace with lower rank
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
