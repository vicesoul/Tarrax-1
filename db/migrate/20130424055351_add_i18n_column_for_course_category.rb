class AddI18nColumnForCourseCategory < ActiveRecord::Migration
  tag :predeploy
  def self.up
    add_column :course_categories, :i18n_key, :string 

    init_i18n_data if RAILS_ENV != 'test'
  end

  def self.down
    remove_column :course_categories, :i18n_key
  end

  def self.init_i18n_data
    CourseCategory.update(1, :i18n_key => 'k12')
    CourseCategory.update(2, :i18n_key => 'college')
    CourseCategory.update(3, :i18n_key => 'postgraduate_examinations')
    CourseCategory.update(4, :i18n_key => 'civil_servants')
    CourseCategory.update(5, :i18n_key => 'selfstudy_examination')
    CourseCategory.update(6, :i18n_key => 'adult_college')
    CourseCategory.update(7, :i18n_key => 'foreign_language')
    CourseCategory.update(8, :i18n_key => 'culture_and_arts')
    CourseCategory.update(9, :i18n_key => 'professional_skills')
    CourseCategory.update(10, :i18n_key => 'computer')
  end
end
