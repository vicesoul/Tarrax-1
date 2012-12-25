class Subdomain < ActiveRecord::Base
  PREFIX = 'edu'

  attr_accessible :subdomain, :account

  belongs_to :account

  after_create :create_subdomain_string
  def create_subdomain_string
    update_attribute :subdomain, "#{Subdomain::PREFIX}#{id}"  if subdomain.nil?
  end
  private :create_subdomain_string

  def to_s
    subdomain
  end
end
