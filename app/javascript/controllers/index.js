import { application } from "./application"

import CommentsLiveController from "./comments_live_controller"
import CommentSearchController from "./comment_search_controller"
import NotificationsLiveController from "./notifications_live_controller"
import PresenceLiveController from "./presence_live_controller"
import ReplyToggleController from "./reply_toggle_controller"
import SubmitOnEnterController from "./submit_on_enter_controller"
import ThreadController from "./thread_controller"

application.register("comments-live", CommentsLiveController)
application.register("comment-search", CommentSearchController)
application.register("notifications-live", NotificationsLiveController)
application.register("presence-live", PresenceLiveController)
application.register("reply-toggle", ReplyToggleController)
application.register("submit-on-enter", SubmitOnEnterController)
application.register("thread", ThreadController)
