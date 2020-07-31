# frozen_string_literal: false

class Message < ApplicationRecord

  scope :read, -> { where read_at: nil }
  scope :short, -> { select('id, sender_id, recipient_id, sender_deleted, recipient_deleted, subject, read_at, created_at') }

  belongs_to :sender,
    :class_name => 'Resident',
    :foreign_key => 'sender_id'
  belongs_to :recipient,
    :class_name => 'Resident',
    :foreign_key => 'recipient_id'

  has_one :sender_user,
          -> { select('users.id, email, status').where(status: User::ACTIVE_STATUS) },
          :through => :sender,
          :source => :user,
          :class_name => "User"

  validates :sender_id, presence: true
  validates :recipient_id, presence: true
  validates :subject, presence: true, length: { maximum: 255 }
  validates :body,    length: { maximum: 4000 }

  def self.search(search)
    where("subject ilike ? OR body ilike?", "%#{search}%", "%#{search}%")
  end

  # marks a message as deleted by either the sender or the recepient, which ever the user that was passed is.
  # When both sender and recepient marks it deleted, it is destroyed.
  def mark_message_deleted(id, resident_id)
    self.sender_deleted = true if self.sender_id == resident_id and self.id=id
    self.recipient_deleted = true if self.recipient_id == resident_id and self.id=id
    self.sender_deleted && self.recipient_deleted ? self.destroy : save!
  end

  # Read message and if it is read by recepient then mark it is read
  def readingmessage(reader)
    if !self.read? && self.recipient.id==reader
      self.read_at = Time.now
      self.save!
    end
  end

  # Based on if a message has been read by it's recepient returns true or false.
  def read?
    self.read_at.nil? ? false : true
  end

  def can_auth(user)
    return false if user.nil?
    return true if user == sender.user
    return true if user == recipient.user
    false
  end

end
