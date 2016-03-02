class Role < ActiveRecord::Base
  has_and_belongs_to_many :users, join_table: :users_roles
  belongs_to :resource, polymorphic: true

  validates(
    :resource_type,
    inclusion: { in: Rolify.resource_types },
    allow_nil: true
  )

  scopify

  # MessageTrain Gem
  message_train except: :sender,
                valid_senders: :superadmins,
                name_column: :capitalized_name,
                slug_column: :name,
                collectives_for_recipient: :sendable_roles,
                valid_recipients: :recipients

  scope :sendable_roles, (lambda do |_participant|
    where(resource: nil).where.not(name: 'superadmin')
  end)

  def recipients
    User.with_role(name.to_sym)
  end

  def superadmins
    User.with_role(:superadmin)
  end

  def capitalized_name
    name.capitalize
  end
end
