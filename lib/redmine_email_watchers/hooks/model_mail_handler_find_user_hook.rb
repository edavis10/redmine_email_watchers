module RedmineEmailWatchers
  module Hooks
    class ModelMailHandlerFindUserHook < Redmine::Hook::ViewListener
      # Search which addresses in the EmailWatcherUser to find any email_watchers
      # who should be given access to the issue
      def model_mail_handler_find_user(context={})

        if context[:user].nil? && context[:sender_email].present? && context[:email].in_reply_to.present?
          sender = context[:sender_email]

          # Duplicate from MailHandler
          # -- In-Reply-To: <redmine.issue-100.....>
          # -- In-Reply-To: <redmine.journal-200.....>
          header_match = context[:email].in_reply_to.first.match(MailHandler::MESSAGE_ID_RE)

          issue_id = nil

          if header_match
            if header_match[1] == 'issue'
              # Reply to issue
              issue_id = header_match[2]
            elsif header_match[1].match(/journal/i)
              # Reply to journal, find issue
              if journal = Journal.find_by_id(header_match[2])
                if defined?(ChilliProject) && ChiliProject::Compatibility.using_acts_as_journalized?
                  issue_id = journal.journaled_id
                else
                  issue_id = journal.journalized_id
                end
              end
            end
          end
          
          if issue_id
            # Scan through watchers looking for matching email_watchers
            watcher = Watcher.first(:conditions =>
                                    ['email_watchers IS NOT NULL AND user_id IN (:user) AND watchable_type = "Issue" AND watchable_id IN (:issue_id)',
                                     {
                                       :user => EmailWatcherUser.default.id,
                                       :issue_id => issue_id
                                     }])

            if watcher && watcher.email_watchers.include?(sender)
              # Email watcher is valid
              user = EmailWatcherUser.default
              # Store the project on the user object
              user.instance_variable_set('@project_id', Issue.find(issue_id).project_id.to_i)
              
              # Mock out allowed_to? for this project only to edit issues
              def user.allowed_to?(permission, project)
                permission == :edit_issues && project.id.to_i == instance_variable_get('@project_id')
              end
              
              return user
            end
          end
          
        end
        
        return []
      end
    end
  end
end
