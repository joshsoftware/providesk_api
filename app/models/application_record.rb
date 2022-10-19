class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def change_case_name
    if self.name.length <= 3
      self.name.upcase!
    else
      self.name.capitalize!
    end
  end
end
