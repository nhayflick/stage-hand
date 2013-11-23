class Reply < ActiveRecord::Base
  validates_presence_of :body

  belongs_to :booking
  belongs_to :recepient, class_name: "User", foreign_key: "recepient_id"
  belongs_to :sender, class_name: "User", foreign_key: "sender_id"
end
