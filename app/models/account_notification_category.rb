
class AccountNotificationCategory < ActiveRecord::Base
  
  has_many :account
  has_many :account_notifications

  attr_accessible :name, :account_id

  validates_presence_of :name

end
