require 'redmine'

Redmine::Plugin.register :redmine_email_watchers do
  name 'Redmine Email Watchers plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  project_module :issue_tracking do
    permission(:view_issue_email_watchers, {})
    permission(:add_issue_email_watchers, {:email_watchers => :create})
    permission(:delete_issue_email_watchers, {:email_watchers => :destroy})
  end
end

require 'dispatcher'
Dispatcher.to_prepare :redmine_email_watchers do

  require_dependency 'issue'
  Issue.send(:include, RedmineEmailWatchers::Patches::IssuePatch)

  require_dependency 'watcher'
  Watcher.send(:include, RedmineEmailWatchers::Patches::WatcherPatch)
end
require 'redmine_email_watchers/hooks/view_layouts_base_sidebar_hook'
require 'redmine_email_watchers/hooks/model_mail_handler_find_user_hook'
