module Jxb
  module Register
    module AccountUser
      def self.included(base)
        base.extend(ClassModules)

        base.class_eval do
          attr_accessible :mobile, :role
        end
      end

      module ClassModules
        def roles
          [
            ['institute_admin'     , t('#account_user.role.institute_admin'     , 'Institute Admin')]     ,
            ['training_management' , t('#account_user.role.training_management' , 'Training Management')] ,
            ['technical_support'   , t('#account_user.role.technical_support'   , 'Technical Support')]   ,
            ['teacher'             , t('#account_user.role.teacher'             , 'Teacher')]             ,
            ['student'             , t('#account_user.role.student'             , 'Student')]             ,
            ['other'               , t('#account_user.role.other'               , 'Other')]               ,
          ]
        end
      end
    end
  end
end
