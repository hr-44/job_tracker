class Note < ActiveRecord::Base
  include Queryable

  belongs_to :user
  belongs_to :notable, polymorphic: true

  validates :user, presence: true
  validates :notable, presence: true

  scope :belonging_to_user, -> (user_id) { where(user_id: user_id) }
  scope :sorted, -> { order(updated_at: :desc) }

  class << self
    def belonging_to_user_and_contact(user_id:, contact_id:)
      contact_matches = {
        notable_id: contact_id,
        notable_type: 'Contact'
      }
      belonging_to_user(user_id).where(contact_matches)
    end

    def belonging_to_user_and_job_application(user_id:, job_application_id:)
      job_application_matches = {
        notable_id: job_application_id,
        notable_type: 'JobApplication'
      }
      belonging_to_user(user_id).where(job_application_matches)
    end
  end

  # TODO: Should raise an error if trying to create a note, where the 'noteable'
  # object is not associated with, or owned by, the user attempting to create note.
end
