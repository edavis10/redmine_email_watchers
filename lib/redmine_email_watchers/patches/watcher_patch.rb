module RedmineEmailWatchers
  module Patches
    module WatcherPatch
      def self.included(base)
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
          serialize :email_watchers
        end
      end

      module ClassMethods
      end

      module InstanceMethods
      end
    end
  end
end
