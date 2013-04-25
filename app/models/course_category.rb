
class CourseCategory < ActiveRecord::Base
  has_many :courses

  attr_accessible :name, :used, :i18n_key

  COURSE_CATEGORY_KEY_MAPPING = {
    :k12 => proc {t('#course_category.k12', 'K12')},
    :college => proc { t('#course_category.college', 'College') },
    :postgraduate_examinations => proc { t('#course_category.postgraduate_examinations', 'Postgraduate examinations') },
    :civil_servants => proc { t('#course_category.civil_servants', 'Civil servants') },
    :selfstudy_examination => proc { t('#course_category.selfstudy_examination', 'Self-study examination') },
    :adult_college => proc { t('#course_category.adult_college', 'Adult college') },
    :foreign_language => proc { t('#course_category.foreign_language', 'Foreign language') },
    :culture_and_arts => proc { t('#course_category.culture_and_arts', 'Culture and Arts') },
    :professional_skills => proc { t('#course_category.professional_skills', 'Professional skills') },
    :computer => proc { t('#course_category.computer', 'Computer') }
  }


  def after_find
    i18nlize_obj self
  end

  private

  def i18nlize_obj obj
    if obj && !obj.i18n_key.blank?
      mapping = COURSE_CATEGORY_KEY_MAPPING[obj.i18n_key.to_sym]
      obj.name = !mapping.blank? ? mapping.call : ((I18n.locale == :en) ? obj.i18n_key.titleize : obj.name) 
    end
    obj
  end

  class << self
    def get_all_categories_for_index
      find(:all, :conditions => ['used != 0'], :order => 'used DESC')
    end

    def get_sorted_categories
      find(:all, :order => 'id')
    end
  end
end
