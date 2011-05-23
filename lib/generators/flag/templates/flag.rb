class Flag < ActiveRecord::Base

  include FlagThis::Flag

  belongs_to :flaggable, :polymorphic => true

  default_scope :order => 'created_at ASC'

  # Flags belong to a user
  belongs_to :user
end
