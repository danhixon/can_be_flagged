require 'active_record'
module ActiveRecord
  module FlagThis #:nodoc:

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def can_be_flagged(options = {})
        roles = options.delete(:roles)
        flag_roles = roles.to_a.compact.map(&:to_sym)
				class_attribute :flag_types
				self.flag_types = (flag_roles.blank? ? [:abuse] : flag_roles)

        #options = ((args.blank? or args[0].blank?) ? {} : args[0])

        if !flag_roles.blank?
          flag_roles.each do |role|
            has_many "#{role.to_s}_flags".to_sym,
              { :class_name => "Flag",
                :as => :flaggable,
                :dependent => :destroy,
                :conditions => ["role = ?", role.to_s],
                :before_add => Proc.new { |x, c| c.role = role.to_s }}.merge(options)
          end
        else
          has_many :flags, {:as => :flaggable, :dependent => :destroy}.merge(options)
        end

        flag_types.each do |role|
          method_name = (role == :abuse ? "flags" : "#{role.to_s}_flags").to_s
          class_eval %{
            def self.find_#{method_name}_for(obj)
              flaggable = self.base_class.name
              Flag.find_flags_for_flaggable(flaggable, obj.id, "#{role.to_s}")
            end

            def self.find_#{method_name}_by_user(user) 
              flaggable = self.base_class.name
              Flag.where(["user_id = ? and flaggable_type = ? and role = ?", user.id, flaggable, "#{role.to_s}"]).order("created_at DESC")
            end

            def #{method_name}_ordered_by_submitted
              Flag.find_flags_for_flaggable(self.class.name, id, "#{role.to_s}")
            end

            def add_#{method_name.singularize}(flag)
              flag.role = "#{role.to_s}"
              #{method_name} << flag
            end
          }
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, ActiveRecord::FlagThis)
