#
# Copyright (C) 2012 - 2013 Instructure, Inc.
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

module Canvas::AccountReports
  class SisExporter
    include Api
    include Canvas::ReportHelpers::DateHelper

    SIS_CSV_REPORTS = ["users", "accounts", "terms", "courses", "sections", "enrollments", "groups", "group_membership", "xlist"]

    def initialize(account_report, params = {})
      @account_report = account_report
      @account = @account_report.account
      @domain_root_account = @account.root_account
      @term = api_find(@domain_root_account.enrollment_terms, @account_report.parameters["enrollment_term"]) if @account_report.parameters["enrollment_term"].presence
      @reports = SIS_CSV_REPORTS & @account_report.parameters.keys
      @sis_format = params[:sis_format]
      @include_deleted = @account_report.parameters["include_deleted"]  if @account_report.has_parameter? "include_deleted"
    end

    def csv
      if @reports.length == 0
        Canvas::AccountReports.message_recipient(@account_report, "SIS export report for #{@account.name} has been successfully generated.")
      elsif @reports.length == 1
        csv = self.send(@reports.first)
        Canvas::AccountReports.message_recipient(@account_report, "SIS export report for #{@account.name} has been successfully generated.", csv)
        csv
      else
        csvs = {}

        @reports.each do |report_name|
          csvs[report_name] = self.send(report_name)
        end
        Canvas::AccountReports.message_recipient(@account_report, "SIS export reports for #{@account.name} have been successfully generated.", csvs)
        csvs
      end
    end

    def users
      list_csv = FasterCSV.generate do |csv|
        if @sis_format
          headers = ['user_id','login_id','password','first_name','last_name','email','status']
        else
          headers = ['jxb_user_id','user_id','login_id','first_name','last_name','email','status']
        end
        csv << headers
        #users = @domain_root_account.pseudonyms.scoped(:include => :user ).scoped(
        users = Pseudonym.of_account(domain_root_account).scoped(:include => :user ).scoped(
          :select => "pseudonyms.id, pseudonyms.sis_user_id, pseudonyms.user_id,
                      pseudonyms.unique_id, pseudonyms.workflow_state")

        if @sis_format
          users = users.scoped(:conditions => 'sis_user_id IS NOT NULL')
        end

        if @include_deleted
          users = users.scoped(:conditions => "( pseudonyms.workflow_state <> 'deleted')
                                               OR
                                               ( pseudonyms.sis_user_id IS NOT NULL)")
        else
          users = users.scoped(:conditions => "pseudonyms.workflow_state <> 'deleted'")
        end

        if @account.id != @domain_root_account.id
          users = users.scoped(:conditions => ["EXISTS (SELECT user_id
                                                        FROM user_account_associations uaa
                                                        WHERE uaa.account_id = ?
                                                        AND uaa.user_id=users.id
                                                        )", @account.id])
        end

        users.find_in_batches do |batch|
          emails = Shard.partition_by_shard(batch.map(&:user_id)) do |user_ids|
            CommunicationChannel.active.scoped(:select => "DISTINCT ON (user_id) user_id, path",
                                               :conditions => ["user_id IN (?)
                                                                AND path_type = 'email'", user_ids],
                                               :order => 'user_id, position')
          end.index_by(&:user_id)

          batch.each do |u|
            row = []
            row << u.user_id unless @sis_format
            row << u.sis_user_id
            row << u.unique_id
            row << nil if @sis_format
            row << u.user.first_name
            row << u.user.last_name
            row << emails[u.user_id].try(:path)
            row << u.workflow_state
            csv << row
          end
        end
      end
      list_csv
    end

    def accounts
      list_csv = FasterCSV.generate do |csv|
        if @sis_format
          headers = ['account_id','parent_account_id', 'name','status']
        else
          headers = ['jxb_account_id','account_id','jxb_parent_id','parent_account_id',
                     'name','status']
        end
        csv << headers
        accounts = @domain_root_account.all_accounts.scoped(
          :select => "accounts.*, pa.id AS parent_id,
                      pa.sis_source_id AS parent_sis_source_id",
          :joins => "INNER JOIN accounts AS pa ON accounts.parent_account_id = pa.id")

        if @sis_format
          accounts = accounts.scoped(:conditions => "accounts.sis_source_id IS NOT NULL")
        end

        if @include_deleted
          accounts = accounts.scoped(:conditions => "( accounts.workflow_state <> 'deleted')
                                                     OR
                                                     ( accounts.sis_source_id IS NOT NULL)")
        else
          accounts = accounts.scoped(:conditions => "accounts.workflow_state <> 'deleted'")
        end

        if @account.id != @domain_root_account.id
          #this does not give the full tree pf sub accounts, just the direct children.
          accounts = accounts.scoped(:conditions => ["accounts.parent_account_id = ?", @account.id])
        end

        accounts.find_each do |a|
          row = []
          row << a.id unless @sis_format
          row << a.sis_source_id
          row << a.parent_id unless @sis_format
          row << a.parent_sis_source_id
          row << a.name
          row << a.workflow_state
          csv << row
        end
      end
      list_csv
    end

    def terms
      list_csv = FasterCSV.generate do |csv|
        headers = ['term_id','name','status', 'start_date', 'end_date']
        headers.unshift 'jxb_term_id' unless @sis_format
        csv << headers
        terms = @domain_root_account.enrollment_terms

        if @sis_format
          terms = terms.scoped(:conditions => "sis_source_id IS NOT NULL")
        end

        if @include_deleted
          terms = terms.scoped(:conditions => "(workflow_state <> 'deleted')
                                               OR
                                               (sis_source_id IS NOT NULL)")
        else
          terms = terms.scoped(:conditions => "workflow_state <> 'deleted'")
        end

        terms.each do |t|
          row = []
          row << t.id unless @sis_format
          row << t.sis_source_id
          row << t.name
          row << t.workflow_state
          row << default_timezone_format(t.start_at)
          row << default_timezone_format(t.end_at)
          csv << row
        end
      end
      list_csv
    end

    def courses
      list_csv = FasterCSV.generate do |csv|
        if @sis_format
          headers = ['course_id','short_name', 'long_name','account_id','term_id','status',
                     'start_date', 'end_date']
        else
          headers = ['jxb_course_id','course_id','short_name','long_name','jxb_account_id',
                     'account_id','jxb_term_id','term_id','status', 'start_date', 'end_date']
        end

        csv << headers
        courses = @domain_root_account.all_courses.scoped(
          :include => [:account, :enrollment_term])
        courses = courses.scoped(:conditions => ["enrollment_term_id=?", @term]) if @term
        courses = courses.scoped(:conditions => "sis_source_id IS NOT NULL") if @sis_format

        if @include_deleted
          courses = courses.scoped(:conditions => "( courses.workflow_state <> 'deleted')
                                                   OR
                                                   ( sis_source_id IS NOT NULL)")
        else
          courses = courses.scoped(:conditions => "courses.workflow_state <> 'deleted'
                                                   AND courses.workflow_state <> 'completed'")
        end

        if @account.id != @domain_root_account.id
          courses = courses.scoped(:conditions => ["EXISTS (SELECT course_id, account_id
                                                            FROM course_account_associations caa
                                                            WHERE caa.account_id = ? 
                                                            AND caa.course_id=courses.id
                                                            )", @account.id])
        end

        course_state_sub = {'claimed' => 'unpublished', 'created' => 'unpublished',
                            'completed' => 'concluded', 'deleted' => 'deleted',
                            'available' => 'active'}

        courses.find_each do |c|
          row = []
          row << c.id unless @sis_format
          row << c.sis_source_id
          row << c.course_code
          row << c.name
          row << c.account_id unless @sis_format
          row << c.account.try(:sis_source_id)
          row << c.enrollment_term_id unless @sis_format
          row << c.enrollment_term.try(:sis_source_id)
          #for sis import format 'claimed', 'created', and 'available' are all considered active
          if @sis_format
            if c.workflow_state == 'deleted' || c.workflow_state == 'completed'
              row << course_state_sub[c.workflow_state]
            else
              row << 'active'
            end
          else
            row << course_state_sub[c.workflow_state]
          end
          if c.restrict_enrollments_to_course_dates
            row << default_timezone_format(c.start_at)
            row << default_timezone_format(c.conclude_at)
          else
            row << nil
            row << nil
          end
          csv << row
        end
      end
      list_csv
    end

    def sections
      list_csv = FasterCSV.generate do |csv|
        if @sis_format
          headers = ['section_id','course_id','name','status','start_date','end_date']
        else
          headers = [ 'jxb_section_id','section_id','jxb_course_id','course_id','name',
                      'status','start_date','end_date','jxb_account_id','account_id']
        end
        csv << headers
        sections = @domain_root_account.course_sections.scoped(
          :select => "course_sections.*, nxc.sis_source_id AS non_x_course_sis_id,
                      rc.sis_source_id AS course_sis_id, nxc.id AS non_x_course_id,
                      ra.id AS r_account_id, ra.sis_source_id AS r_account_sis_id,
                      nxc.account_id AS nx_account_id, nxa.sis_source_id AS nx_account_sis_id",
          :joins => "INNER JOIN courses AS rc ON course_sections.course_id = rc.id
                     INNER JOIN accounts AS ra ON rc.account_id = ra.id
                     LEFT OUTER JOIN courses AS nxc ON course_sections.nonxlist_course_id = nxc.id
                     LEFT OUTER JOIN accounts AS nxa ON nxc.account_id = nxa.id")

        if @term
          sections = sections.scoped(:conditions => ["rc.enrollment_term_id=?", @term])
        end

        if @include_deleted
          sections = sections.scoped(:conditions => "( course_sections.workflow_state <> 'deleted')
                                                     OR
                                                     ( course_sections.sis_source_id IS NOT NULL
                                                       AND (nxc.sis_source_id IS NOT NULL
                                                       OR rc.sis_source_id IS NOT NULL))")
        else
          sections = sections.scoped(:conditions => "course_sections.workflow_state <> 'deleted'")
        end

        if @sis_format
          sections = sections.scoped(:conditions => "course_sections.sis_source_id IS NOT NULL
                                                   AND (nxc.sis_source_id IS NOT NULL
                                                   OR rc.sis_source_id IS NOT NULL)")
        end

        if @account.id != @domain_root_account.id
          sections = sections.scoped(:conditions => ["EXISTS (SELECT course_id
                                                              FROM course_account_associations caa
                                                              WHERE caa.account_id = ?
                                                              AND caa.course_id=rc.id
                                                              )", @account.id])
        end

        sections.find_each do |s|
          row = []
          row << s.id unless @sis_format
          row << s.sis_source_id
          if s.nonxlist_course_id == nil
            row << s.course_id unless @sis_format
            row << s.course_sis_id
          else
            row << s.non_x_course_id unless @sis_format
            row << s.non_x_course_sis_id
          end
          row << s.name
          row << s.workflow_state
          if s.restrict_enrollments_to_section_dates
            row << default_timezone_format(s.start_at)
            row << default_timezone_format(s.end_at)
          else
            row << nil
            row << nil
          end
          unless @sis_format
            if s.nonxlist_course_id == nil
              row << s.r_account_id
              row << s.r_account_sis_id
            else
              row << s.nx_account_id
              row << s.nx_account_sis_id
            end
          end
          csv << row
        end
      end
      list_csv
    end

    def enrollments
      list_csv = FasterCSV.generate do |csv|
        if @sis_format
          headers = ['course_id', 'user_id', 'role', 'section_id', 'status', 'associated_user_id']
        else
          headers = ['jxb_course_id', 'course_id', 'jxb_user_id', 'user_id', 'role',
                     'jxb_section_id', 'section_id', 'status', 'jxb_associated_user_id',
                     'associated_user_id']
        end
        csv << headers
        enrol = @domain_root_account.enrollments.scoped(
          :select => "enrollments.*, courses.sis_source_id AS course_sis_id,
                      nxc.id AS nxc_id, nxc.sis_source_id AS nxc_sis_id,
                      cs.sis_source_id AS course_section_sis_id,
                      pseudonyms.sis_user_id AS pseudonym_sis_id,
                      ob.sis_user_id AS ob_sis_id,
                 CASE WHEN enrollments.workflow_state = 'invited' THEN 'invited'
                      WHEN enrollments.workflow_state = 'active' THEN 'active'
                      WHEN enrollments.workflow_state = 'completed' THEN 'concluded'
                      WHEN enrollments.workflow_state = 'deleted' THEN 'deleted'
                      WHEN courses.workflow_state = 'rejected' THEN 'rejected' END AS enrol_state",
          :joins => "INNER JOIN course_sections cs ON cs.id = enrollments.course_section_id
                     INNER JOIN courses ON courses.id = cs.course_id
                     INNER JOIN pseudonyms ON pseudonyms.user_id=enrollments.user_id
                     INNER JOIN user_account_associations ON pseudonyms.user_id=user_account_associations.user_id
                     LEFT OUTER JOIN courses nxc ON cs.nonxlist_course_id = nxc.id
                     LEFT OUTER JOIN pseudonyms AS ob ON ob.user_id = enrollments.associated_user_id
                       AND ob.account_id = enrollments.root_account_id",
          :conditions => "user_account_associations.account_id = enrollments.root_account_id")

        if @term
          enrol = enrol.scoped(:conditions => ["courses.enrollment_term_id = ?", @term])
        end

        if @include_deleted
          enrol = enrol.scoped(
            :conditions => "( enrollments.workflow_state <> 'deleted')
                            OR
                            ( pseudonyms.sis_user_id IS NOT NULL
                              AND enrollments.workflow_state NOT IN ('rejected', 'invited')
                              AND (courses.sis_source_id IS NOT NULL
                                   OR cs.sis_source_id IS NOT NULL))")
        else
          enrol = enrol.scoped(
            :conditions => "enrollments.workflow_state <> 'deleted'
                            AND enrollments.workflow_state <> 'completed'")
        end

        if @sis_format
          enrol = enrol.scoped(
            :conditions => "pseudonyms.sis_user_id IS NOT NULL
                            AND enrollments.workflow_state NOT IN ('rejected', 'invited')
                            AND (courses.sis_source_id IS NOT NULL
                                 OR cs.sis_source_id IS NOT NULL)")
        end

        if @account.id != @domain_root_account.id
          enrol = enrol.scoped(:conditions => ["EXISTS (SELECT course_id
                                                FROM course_account_associations caa
                                                WHERE caa.account_id = ?
                                                  AND caa.course_id=courses.id
                                                )", @account.id])
        end

        enrol.find_each do |e|
          row = []
          if e.nxc_id == nil
            row << e.course_id unless @sis_format
            row << e.course_sis_id
          else
            row << e.nxc_id unless @sis_format
            row << e.nxc_sis_id
          end
          row << e.user_id unless @sis_format
          row << e.pseudonym_sis_id
          row << e.sis_role
          row << e.course_section_id unless @sis_format
          row << e.course_section_sis_id
          row << e.enrol_state
          row << e.associated_user_id unless @sis_format
          row << e.ob_sis_id
          csv << row
        end
      end
      list_csv
    end

    def groups
      list_csv = FasterCSV.generate do |csv|
        if @sis_format
          headers = ['group_id', 'account_id', 'name', 'status']
        else
          headers = ['jxb_group_id', 'group_id', 'jxb_account_id', 'account_id', 'name',
                     'status']
        end

        csv << headers
        groups = @domain_root_account.all_groups.scoped(
          :select => "groups.*, accounts.sis_source_id AS account_sis_id",
          :joins => "INNER JOIN accounts ON accounts.id = groups.account_id")





        if @sis_format
          groups = groups.scoped(:conditions => "groups.sis_source_id IS NOT NULL")
        end

        if @include_deleted
          groups = groups.scoped(:conditions => "( groups.workflow_state <> 'deleted')
                                                 OR
                                                 ( groups.sis_source_id IS NOT NULL)")
        else
          groups = groups.scoped(:conditions => "groups.workflow_state <> 'deleted'")
        end

        if @account.id != @domain_root_account.id
          groups = groups.scoped(
            :conditions => ["groups.context_id=? AND groups.context_type = 'Account'", @account.id])
        end

        groups.find_each do |g|
          row = []
          row << g.id unless @sis_format
          row << g.sis_source_id
          row << g.account_id unless @sis_format
          row << g.account_sis_id
          row << g.name
          row << g.workflow_state
          csv << row
        end
      end
      list_csv
    end

    def group_membership
      list_csv = FasterCSV.generate do |csv|
        if @sis_format
          headers = ['group_id', 'user_id', 'status']
        else
          headers = ['jxb_group_id', 'group_id','jxb_user_id', 'user_id', 'status']
        end

        csv << headers
        gm = @domain_root_account.all_groups.scoped(
          :select => "groups.*, group_memberships.*, pseudonyms.sis_user_id AS user_sis_id",
          :joins => "INNER JOIN group_memberships ON groups.id = group_memberships.group_id
                     INNER JOIN pseudonyms ON pseudonyms.user_id=group_memberships.user_id
                     INNER JOIN user_account_associations ON pseudonyms.user_id=user_account_associations.user_id",
          :conditions => "user_account_associations.account_id = groups.root_account_id")

        if @sis_format
          gm = gm.scoped(:conditions => "pseudonyms.sis_user_id IS NOT NULL
                                         AND group_memberships.sis_batch_id IS NOT NULL")
        end

        if @include_deleted
          gm = gm.scoped(:conditions => "( groups.workflow_state <> 'deleted'
                                           AND group_memberships.workflow_state <> 'deleted')
                                         OR
                                         ( pseudonyms.sis_user_id IS NOT NULL
                                           AND group_memberships.sis_batch_id IS NOT NULL)")
        else
          gm = gm.scoped(:conditions => "groups.workflow_state <> 'deleted'
                                         AND group_memberships.workflow_state <> 'deleted'")
        end

        if @account.id != @domain_root_account.id
          gm = gm.scoped(:conditions => ["groups.context_id=?
                                          AND groups.context_type = 'Account'", @account.id])
        end

        gm.find_each do |gm|
          row = []
          row << gm.group_id  unless @sis_format
          row << gm.sis_source_id
          row << gm.user_id  unless @sis_format
          row << gm.user_sis_id
          row << gm.workflow_state
          csv << row
        end
      end
      list_csv
    end

    def xlist
      list_csv = FasterCSV.generate do |csv|
        if @sis_format
          headers = ['xlist_course_id', 'section_id', 'status']
        else
          headers = ['jxb_xlist_course_id','xlist_course_id','jxb_section_id','section_id',
                     'status']
        end
        csv << headers
        xl = @domain_root_account.course_sections.scoped(
          :select => "course_sections.*, courses.sis_source_id AS course_sis_id",
          :joins => "INNER JOIN courses ON course_sections.course_id = courses.id
                     INNER JOIN courses nxc ON course_sections.nonxlist_course_id = nxc.id",
          :conditions => "course_sections.nonxlist_course_id IS NOT NULL")

        if @term
          xl = xl.scoped(:conditions => ["courses.enrollment_term_id=?", @term])
        end

        if @sis_format
          xl = xl.scoped(:conditions => "courses.sis_source_id IS NOT NULL
                                         AND course_sections.sis_source_id IS NOT NULL")
        end

        if @include_deleted
          xl = xl.scoped(:conditions => "( courses.workflow_state <> 'deleted'
                                           AND course_sections.workflow_state <> 'deleted')
                                         OR
                                         ( courses.sis_source_id IS NOT NULL
                                           AND course_sections.sis_source_id IS NOT NULL)")
        else
          xl = xl.scoped(:conditions => "courses.workflow_state <> 'deleted'
                                         AND courses.workflow_state <> 'completed'
                                         AND course_sections.workflow_state <> 'deleted'")
        end

        if @account.id != @domain_root_account.id
          xl = xl.scoped(:conditions => ["EXISTS (SELECT course_id
                                          FROM course_account_associations caa
                                          WHERE caa.account_id = ?
                                          AND caa.course_id=course_sections.course_id
                                          AND caa.course_section_id IS NULL
                                          )", @account.id])
        end

        xl.find_each do |x|
          row = []
          row << x.course_id unless @sis_format
          row << x.course_sis_id
          row << x.id unless @sis_format
          row << x.sis_source_id
          row << x.workflow_state
          csv << row
        end
      end
      list_csv
    end
  end
end
