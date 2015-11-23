class Role < ActiveRecord::Base
  has_and_belongs_to_many :users, :join_table => :users_roles
  belongs_to :resource, :polymorphic => true

  validates :resource_type,
            :inclusion => { :in => Rolify.resource_types },
            :allow_nil => true

  scopify

  # MessageTrain Gem
  message_train except: :sender,
                valid_senders: :superadmins,
                name_column: :name,
                slug_column: :name,
                collectives_for_recipient: :sendable_roles,
                valid_recipients: :recipients

  scope :sendable_roles, ->(user) { where(resource: nil).where.not(name: 'superadmin') }

  def recipients
    User.with_role(self.name.to_sym)
  end

  def superadmins
    User.with_role(:superadmin)
  end
end
