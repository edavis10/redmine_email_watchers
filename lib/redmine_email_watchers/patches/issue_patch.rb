module RedmineEmailWatchers
  module Patches
    module IssuePatch
      def self.included(base)
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable

          # Add email_watcher addresses into the watcher_recipients list
          def watcher_recipients_with_email_watchers
            watcher_recipients_without_email_watchers + email_watchers
          end
          alias_method_chain :watcher_recipients, :email_watchers
          
        end
      end

      module ClassMethods
      end

      module InstanceMethods
        def email_watchers
          if email_watcher_record = watchers.find_by_user_id(EmailWatcherUser.default)
            email_watcher_record.email_watchers # Extract emails
          else
            []
          end
          
        end
        
      end
    end
  end
end
