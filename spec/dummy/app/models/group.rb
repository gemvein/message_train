class Group < ActiveRecord::Base
  # Rolify Gem
  resourcify

  # MessageTrain Gem
  message_train only: :recipient,
                valid_senders: :owners,
                name_column: :title,
                slug_column: :slug,
                collectives_for_recipient: :membered_by,
                valid_recipients: :recipients

  # Callbacks
  before_create :set_slug

  scope :membered_by, ->(user) { with_roles([:member, :owner], user).distinct }

  def set_slug
    # Manually generate slug instead of using friendly id, for testing.
    self.slug = title.downcase.gsub(/[^a-z0-9]+/, '-')
  end

  def owners
    User.with_role(:owner, self)
  end

  def recipients
    User.with_role(:member, self)
  end

  def self.fallback_address_book(user)
    Group.with_role(:owner, user)
  end
end
