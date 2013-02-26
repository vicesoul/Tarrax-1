module Jxb
  module CommonBehavior

    def active_assignments_of_ids(ids)
      active_assignments_of_courses( Course.find(ids) )
    end

    def active_assignments_of_courses(kourses = nil)
      Assignment.active.for_context_codes( (kourses || self.courses).map(&:asset_string) )
    end

    def active_discussions_of_ids(ids)
      active_discussions_of_courses( Course.find(ids) )
    end

    def active_discussions_of_courses(kourses = nil)
      DiscussionTopic.active.for_context_codes( (kourses || self.courses).map(&:asset_string) )
    end

    def active_announcements_of_ids(ids)
      active_announcements_of_courses( Course.find(ids) )
    end

    def active_announcements_of_courses(kourses = nil)
      Announcement.active.for_context_codes( (kourses || self.courses).map(&:asset_string) )
    end

  end
end
