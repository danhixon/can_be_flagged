class Post < ActiveRecord::Base
  can_be_flagged :after_add=>:flagged

  private
  def flagged(flag)
    self.flags_count += 1
    self.save
  end
  
end

class User < ActiveRecord::Base
  
end

class Reply < ActiveRecord::Base
  can_be_flagged :roles => [:offensive, :spam]
end