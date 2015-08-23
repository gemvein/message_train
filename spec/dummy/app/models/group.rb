class Group < ActiveRecord::Base
  # Rolify Gem
  resourcify

  # NightTrain Gem
  night_train only: :recipient, valid_senders: :owners, name_column: :title, slug_column: :slug

  # Callbacks
  before_create :set_slug

  def set_slug
    # Manually generate slug instead of using friendly id, for testing.
    self.slug = title.downcase.gsub(/[^a-z0-9]+/, '-')
  end

  def owners
    User.with_role(:owner, self)
  end
end