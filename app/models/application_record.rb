class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def downcase_name
    self.name.downcase!
  end
end
