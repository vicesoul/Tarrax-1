class CaseTplWidget < ActiveRecord::Base

  attr_accessible :title, :body, :seq

  belongs_to :case_tpl

end
