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

module AccountsHelper
  include Jxb::WidgetsHelper

  def show_last_batch
    @last_batch && !(@current_batch && @current_batch.importing?)
  end
    
  def print_messages(batch)
    return '' unless batch
    render :partial => 'accounts/sis_batch_messages', :object => batch
  end
  
  def print_counts(batch)
    return '' unless batch.data && batch.data[:counts]
    render :partial => 'accounts/sis_batch_counts', :object => batch
  end

  def show_code_and_term_for(course)
    show_term = course.enrollment_term && !course.enrollment_term.default_term?
    show_code = course.course_code != course.name
    "#{course.course_code if show_code}#{', ' if show_term && show_code}#{course.enrollment_term.name if show_term}"
  end

  def i18n_for_reports_title(title)
    {
      "Student Competency" => t('#accounts.settings.reports.title.student_competency' , 'Student Competency') ,
      "Grade Export"       => t('#accounts.settings.reports.title.grade_export'       , 'Grade Export')       ,
      "SIS Export"         => t('#accounts.settings.reports.title.sis_export'         , 'SIS Export')         ,
      "Provisioning"       => t('#accounts.settings.reports.title.provisioning'       , 'Provisioning')
    }[title] || title
  end
end
