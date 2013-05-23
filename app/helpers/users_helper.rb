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

module UsersHelper

  def format_state state
    case state
    when 0
      'Actived'
    when 1
      'Be frozen'
    when 2
      'Frozen'
    end
  end

  def get_user_associated_accounts user, account_id
    user.user_account_associations.select do |a|
      if Account.find(account_id).root_account?
        a.account.parent_account_id.to_s == account_id
      else
        a.account.id.to_s == account_id
      end
    end.map do |b|
      link_to(b.account.name, account_users_url(b.account.id))
    end.join('<br />').html_safe
  end

end
