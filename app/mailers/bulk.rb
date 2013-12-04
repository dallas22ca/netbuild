class Bulk < ActionMailer::Base
  helper ActionView::Helpers::UrlHelper
  
  def sender(message_id, membership_id)
    membership = Membership.find(membership_id)
    message = Message.find(message_id)
    from = message.user.email
    @plain = Liquid::Template.parse(message.plain).render(membership.to_liquid).html_safe
    @domain = membership.website.domain
    @one_line_address = membership.website.one_line_address
    @subscription = public_page_url("subscriptions", membership.token)
    
    if mail({
        to: membership.name_and_email,
        from: from,
        subject: message.subject
      })
      Delivery.create(message_id: message_id, membership_id: membership_id)
    end
  end
end
