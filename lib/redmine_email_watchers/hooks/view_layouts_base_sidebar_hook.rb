module RedmineEmailWatchers
  module Hooks
    class ViewLayoutsBaseSidebarHook < Redmine::Hook::ViewListener
      def view_layouts_base_sidebar(context={})

        if context[:request].params['controller'] == 'issues' && context[:request].params['action'] == 'show'

          issue = Issue.visible.find_by_id(context[:request].params['id'])

          if issue
            return context[:controller].send(:render_to_string, {
                                               :partial => 'email_watchers/sidebar',
                                               :locals => {
                                                 :watched => issue
                                               }
                                             })
          end
          
          
        end
        
      end
    end
  end
end
