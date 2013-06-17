#
# Copyright (C) 2011 Instructure, Inc.
#
# This file is part of Canvas.
#
# Canvas is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, version 3 of the License.
#
# Canvas is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along
# with this program. If not, see <http://www.gnu.org/licenses/>.
#

#  create_table "user_account_associations", :force => true do |t|
#    t.integer  "user_id",         :limit => 8
#    t.integer  "account_id",      :limit => 8
#    t.integer  "depth"
#    t.datetime "created_at"
#    t.datetime "updated_at"
#    t.string   "enrollment_type"
#    t.boolean  "fake"
#  end
class UserAccountAssociation < ActiveRecord::Base
  belongs_to :user
  belongs_to :account
  belongs_to :job_position
  has_many :user_account_association_change_logs

  validates_presence_of :user_id, :account_id

  attr_accessible :user, :user_id, :account, :account_id, :depth, :enrollment_type, :fake, :job_position, :job_position_id, :job_number, :source, :external, :state, :tag_list

  before_save :make_sure_only_one_fake_association_each_account

  acts_as_taggable_on :tags

  #named_scope for taggable
  scope_procedure :taggable_with_tags, lambda { |tag|
    tagged_with(tag, :on => :tags, :any => true)
  }

  named_scope :active, :conditions => ['state = 0']

  named_scope :filter_by_account_id, lambda { |account_id| {:conditions => ['account_id in (?)', account_id]} }

  named_scope :sort_by_job_position, lambda { |column, direction|
    {
      :joins => "left join job_positions on user_account_associations.job_position_id = job_positions.id",
      :order => "job_positions.#{column} #{direction}"
    }
  }

  named_scope :sort_by_custom, lambda {|column, direction|
    {
      :order => "user_account_associations.#{column} #{direction}"
    }
  }

  named_scope :sort_by_tags, lambda { |column, direction|
    {
      :joins => "left join taggings on user_account_associations.id = taggings.taggable_id left join tags on tags.id = taggings.tag_id",
      :order => "tags.#{column} #{direction}"
    }
  }

  def self.active_or_freeze_user_by_account op_account_id, user_id, state
    flag = true
    account = Account.find(op_account_id)
    begin
      account_and_sub_account_ids = account.sub_accounts_recursive(10000, 0).select{|a| a.workflow_state == 'active'}.map{|s| s.id} | [account.id]
      UserAccountAssociation.find_all_by_account_id_and_user_id(account_and_sub_account_ids, user_id).each do |s|
        UserAccountAssociation.transaction do
          s.state = state
          s.save!

          course_ids = CourseAccountAssociation.find_all_by_account_id(account_and_sub_account_ids, :select => 'distinct course_id').map{|c| c.course_id}
          Enrollment.__send__(state.to_s == '0' ? 'deleted' : 'active').find_all_by_course_id_and_user_id(course_ids, user_id).each{|e| e.__send__(state.to_s == '0' ? 'restore' : 'destroy') }

        end
      end
    rescue => err
      flag = false
    end
    flag
  end

  def self.display_source
    {
      'created' => t('#rails_helper.user_source.created', 'Created'),
      'invited' => t('#rails_helper.user_source.invited', 'Invited'),
      'imported' => t('#rails_helper.user_source.imported', 'Imported'),
      'applied' => t('#rails_helper.user_source.applied', 'Applied')
    }
  end

  private

  def make_sure_only_one_fake_association_each_account
    raise 'Only one fake association each account' if self.new_record? && self.fake && self.class.find_by_user_id_and_account_id(self.user_id, self.account_id)
  end

end
