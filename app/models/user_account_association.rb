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

  attr_accessible :account_id, :depth, :enrollment_type, :fake, :job_number, :source, :external

  before_save :make_sure_only_one_fake_association_each_account

  acts_as_taggable_on :tags

  named_scope :filter_by_account_id, lambda { |account_id| {:conditions => ['account_id = ?', account_id]} }

  private

  def make_sure_only_one_fake_association_each_account
    raise 'Only one fake association each account' if self.new_record? && self.fake && self.class.find_by_user_id_and_account_id(self.user_id, self.account_id)
  end

end
