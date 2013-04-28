module Jxb
  module CommonBehavior

    def active_assignments_of_ids(ids)
      active_assignments_of_courses(filter_concluded_courses Course.find(ids) )
    end

    def active_assignments_of_courses(kourses = nil, limit = 10)
      Assignment.active.for_context_codes(filter_concluded_courses (kourses || self.courses) ).scoped(:limit => limit, :order => 'created_at DESC')
    end

    def active_discussions_of_ids(ids)
      active_discussions_of_courses(filter_concluded_courses Course.find(ids) )
    end

    def active_discussions_of_courses(kourses = nil, limit = 8)
      DiscussionTopic.active.where(:type => nil).for_context_codes(filter_concluded_courses (kourses || self.courses) ).scoped(:limit => limit, :order => 'created_at DESC')
    end

    def active_announcements_of_ids(ids)
      active_announcements_of_courses(filter_concluded_courses Course.find(ids) )
    end

    def active_announcements_of_courses(kourses = nil, limit = 5)
      Announcement.active.for_context_codes(filter_concluded_courses (kourses || self.courses) ).scoped(:limit => limit, :order => 'created_at DESC')
    end

    def filter_concluded_courses courses
        courses.select{|c| c.conclude_at.nil? || c.conclude_at > Time.now}.map(&:asset_string)
    end

  end
end
