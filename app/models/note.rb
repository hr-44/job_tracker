class Note < ActiveRecord::Base
  include Queryable

  belongs_to :user
  belongs_to :notable, polymorphic: true

  validates :user, presence: true
  validates :notable, presence: true

  scope :belonging_to_user, -> (user_id) { where(user_id: user_id) }
  scope :sorted, -> { order(updated_at: :desc) }

  # TODO: Should raise an error if trying to create a note, where the 'noteable'
  # object is not associated with, or owned by, the user attempting to create note.
end
