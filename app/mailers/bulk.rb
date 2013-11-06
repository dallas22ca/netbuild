class Bulk < ActionMailer::Base
  default from: "no-reply@netbuild.co"

  def sender(message_id, membership_id)
    membership = Membership.find(membership_id)
    message = Message.find(message_id)
    from = "#{message.user.email.gsub(/@/, "=")}@netbuild.co"
    @plain = message.plain
    
    mail({
      to: membership.name_and_email, 
      reply_to: message.user.name_and_email, 
      from: from,
      sender: from,
      subject: message.subject
    })
    
    Delivery.create(message_id: message_id, membership_id: membership_id)
  end
end
