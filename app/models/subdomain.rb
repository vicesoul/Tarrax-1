class Subdomain < ActiveRecord::Base
  PREFIX = 'edu'

  belongs_to :account

  after_save :create_subdomain_string
  def create_subdomain_string
    self.subdomain = "#{PREFIX}#{id}"  if subdomain.nil?
  end
  private :create_subdomain_string
end
