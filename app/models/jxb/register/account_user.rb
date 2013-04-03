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
            ['institute_admin'     , t('role.institute_admin'     , 'Institute Admin')]     ,
            ['training_management' , t('role.training_management' , 'Training Management')] ,
            ['technical_support'   , t('role.technical_support'   , 'Technical Support')]   ,
            ['teacher'             , t('role.teacher'             , 'Teacher')]             ,
            ['student'             , t('role.student'             , 'Student')]             ,
            ['other'               , t('role.other'               , 'Other')]               ,
          ]
        end
      end
    end
  end
end
