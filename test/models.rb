class Post < ActiveRecord::Base
  can_be_flagged
end

class User < ActiveRecord::Base
end

class Reply < ActiveRecord::Base
  can_be_flagged :offensive, :spam
end
