module Jxb
  module CommonBehavior

    def active_assignments_of_ids(ids)
      active_assignments_of_courses( Course.find(ids) )
    end

    def active_assignments_of_courses(kourses = nil, limit = 10)
      Assignment.active.for_context_codes( (kourses || self.courses).map(&:asset_string) ).scoped(:limit => limit, :order => 'created_at DESC')
    end

    def active_discussions_of_ids(ids)
      active_discussions_of_courses( Course.find(ids) )
    end

    def active_discussions_of_courses(kourses = nil, limit = 8)
      DiscussionTopic.active.where(:type => nil).for_context_codes( (kourses || self.courses).map(&:asset_string) ).scoped(:limit => limit, :order => 'created_at DESC')
    end

    def active_announcements_of_ids(ids)
      active_announcements_of_courses( Course.find(ids) )
    end

    def active_announcements_of_courses(kourses = nil, limit = 5)
      Announcement.active.for_context_codes( (kourses || self.courses).map(&:asset_string) ).scoped(:limit => limit, :order => 'created_at DESC')
    end

  end
end
