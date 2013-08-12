class CourseColumn < ActiveRecord::Base
  belongs_to :course
  attr_accessible :slug, :name, :content, :position

  before_save :save_show

  def save_show
    self.show = self.content.present?
    true
  end

  named_scope :active, { :conditions => ["show = ?", true] }

  acts_as_list :scope => :course

  COLUMN_INTRO        = "intro"
  COLUMN_GUIDE        = "guide"
  COLUMN_SYLLABUS     = "syllabus"
  COLUMN_CALENDAR     = "calendar"
  COLUMN_MATERIALS    = "materials"
  COLUMN_REQUIRMENTS  = "requirment"
  COLUMN_FACULTY      = "faculty"
  COLUMN_PRODUCE_TEAM = "prodteam"

  def self.columns_for_college
    {
      COLUMN_INTRO        => t("intro"        , 'Introduction') ,
      COLUMN_GUIDE        => t("guide"        , 'Guides')       ,
      COLUMN_SYLLABUS     => t("syllabus"     , 'Syllabus')     ,
      COLUMN_CALENDAR     => t("calendar"     , 'Calendar')     ,
      COLUMN_MATERIALS    => t("materials"    , 'Materials')    ,
      COLUMN_REQUIRMENTS  => t("requirments"  , 'Requirments')  ,
      COLUMN_FACULTY      => t("faculty"      , 'Faculty')      ,
      COLUMN_PRODUCE_TEAM => t("produce_team" , 'Produce Team') ,
    }.freeze
  end
end
