module Jxb
  module Register
    module Account
      def self.included(base)
        base.extend(ClassModules)

        base.class_eval do
          apply_simple_captcha :message => :invalid_code

          attr_accessor :require_presence_of_name
          attr_accessor :user_role, :user_mobile # for validing new account form
          attr_accessible :user_role, :user_mobile, :school_category, :school_scale, :captcha, :captcha_key

          validates_presence_of :name, :if => :require_presence_of_name
          validates_uniqueness_of :name, :scope => [:parent_account_id, :workflow_state], :on => :create
          validate :validate_user_mobile
        end
      end

      def validate_user_mobile
        errors.add(:user_mobile, 'invalid_mobile') unless user_mobile =~ /^1[0-9]{10}$/ unless captcha.nil? # account new form only
      end

      def default_setting
        self.default_time_zone = 'Beijing'
        self.default_locale = 'zh-CN'
        self.settings[:teachers_can_create_courses] = true
      end

      module ClassModules
        def school_categories
          [
            [:open        , t('#account.school_category.open'        , 'Open School') ] ,
            [:k12         , t('#account.school_category.k12'         , 'K12') ]         ,
            [:higher_ed   , t('#account.school_category.higher_ed'   , 'Higher Ed') ]   ,
            [:corporate   , t('#account.school_category.corporate'   , 'Corporate') ]   ,
            [:other       , t('#account.school_category.other'       , 'Other') ]       ,
          ]
        end

        def school_scale
          [
            ['0-500'       , '0 - 500']       ,
            ['501-2000'    , '501 - 2000']    ,
            ['2001-5000'   , '2001 - 5000']   ,
            ['5001-10000'  , '5001 - 10000']  ,
            ['10001-30000' , '10001 - 30000'] ,
            ['30000+'      , '30000+']        ,
          ]
        end
      end
    end
  end
end
