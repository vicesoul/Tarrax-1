# encoding: UTF-8
class AddCourseCategoryData < ActiveRecord::Migration
    tag :predeploy

    def self.up
        down
        CourseCategory.create([
            {
                :name => '中小学'
            },
            {
                :name => '大中专'
            },
            {
                :name => '考研'
            },
            {
                :name => '公务员考试'
            },
            {
                :name => '自学考试'
            },
            {
                :name => '成人高考'
            },
            {
                :name => '外语留学'
            },
            {
                :name => '文化艺术'
            },
            {
                :name => '职业技能'
            },
            {
                :name => '计算机'
            }
            ])
    end

    def self.down
        CourseCategory.delete_all
    end
end
