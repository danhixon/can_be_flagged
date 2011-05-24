module FlagThis
  # including this module into your Flag model will give you finders and named scopes
  # useful for working with Flags.
  module Flag

    def self.included(flag_model)
      flag_model.extend ClassMethods
      flag_model.scope :in_order, flag_model.order('created_at ASC')
      flag_model.scope :recent,   flag_model.order('created_at DESC')
    end

    def is_flag_type?(type)
      type.to_s == role.singularize.to_s
    end
   
    module ClassMethods
      def this_is_a_flag
        #after_create :callback_flaggable
        
      end
      # Helper class method to lookup all flags assigned
      # to all flaggable types for a given user.
      def find_flags_by_user(user, role = "abuse")
        where(["user_id = ? and role = ?", user.id, role]).order("created_at DESC")
      end

      # Helper class method to look up all flags for 
      # flaggable class name and flaggable id.
      def find_flags_for_flaggable(flaggable_str, flaggable_id, role = "abuse")
        where(["flaggable_type = ? and flaggable_id = ? and role = ?", flaggable_str, flaggable_id, role]).order("created_at DESC")
      end

      # Helper class method to look up a flaggable object
      # given the flaggable class name and id 
      def find_flaggable(flaggable_str, flaggable_id)
        model = flaggable_str.constantize
        model.respond_to?(:find_flags_for) ? model.find(flaggable_id) : nil
      end
    end
  end
end
