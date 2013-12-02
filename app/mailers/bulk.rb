class Bulk < ActionMailer::Base
  def sender(message_id, membership_id)
    membership = Membership.find(membership_id)
    message = Message.find(message_id)
    from = "#{message.user.email.gsub(/@/, "=")}@netbuild.co"
    @plain = Liquid::Template.parse(message.plain).render(membership.to_liquid).html_safe
    @domain = membership.website.domain
    @one_line_address = membership.website.one_line_address
    
    if mail({
      to: membership.name_and_email, 
      reply_to: message.user.name_and_email, 
      from: from,
      sender: from,
      subject: message.subject
    })
      Delivery.create(message_id: message_id, membership_id: membership_id)
    end
  end
end
