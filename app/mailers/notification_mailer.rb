class NotificationMailer < ApplicationMailer
  def new_comment
    @recipient = params[:recipient]
    @sender = params[:sender]
    @comment = params[:comment]
    @reason = params[:reason].to_s
    @preview = @comment.body_preview
    @url = Comment.deep_link_path(@comment)
    @title = Notifications::Presentation.title(@reason)

    mail(
      to: @recipient.email,
      subject: Notifications::Presentation.email_subject(reason: @reason, sender_name: @sender.display_name)
    )
  end
end
