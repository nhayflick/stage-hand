class Reply < ActiveRecord::Base
  validates_presence_of :body

  belongs_to :booking
  belongs_to :recipient, class_name: "User", foreign_key: "recipient_id"
  belongs_to :sender, class_name: "User", foreign_key: "sender_id"
end
