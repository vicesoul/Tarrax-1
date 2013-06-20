module Jxb
  module CourseSystem
    module User
      def course_systems_for_account(account)
        course_systems = ::CourseSystem.of_user_account(self, account)
        ::CourseSystem.uniq(course_systems)
      end

      def course_systems
        @course_systems ||= begin
          course_systems = ::CourseSystem.of_user(self)
          ::CourseSystem.uniq(course_systems).sort_by(&:rank)
        end
      end
    end
  end
end
