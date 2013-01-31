class Subdomain < ActiveRecord::Base
  PREFIX = 'edu'

  attr_accessible :name, :account

  belongs_to :account

  after_create :create_name
  def to_s
    name
  end

  private
  def create_name
    update_attribute :name, "#{Subdomain::PREFIX}#{id}"  if name.nil?
  end
end
