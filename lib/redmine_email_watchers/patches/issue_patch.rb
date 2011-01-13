module RedmineEmailWatchers
  module Patches
    module IssuePatch
      def self.included(base)
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
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
