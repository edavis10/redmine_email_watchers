class EmailWatchersController < ApplicationController
  unloadable
  before_filter :find_project
  before_filter :authorize
  
  def create
    @watcher = Watcher.first(:conditions => {
                               :user_id => EmailWatcherUser.default.id,
                               :watchable_type => params[:object_type].camelcase,
                               :watchable_id => params[:object_id]
                             })
    @watcher ||= Watcher.new(params[:watcher])
    @watcher.email_watchers ||= []
    @watcher.email_watchers << params[:add_email_watcher]
    @watcher.watchable = @watched
    @watcher.user = EmailWatcherUser.default
    @watcher.save if request.post?
    respond_to do |format|
      format.html { redirect_to :back }
      format.js do
        render :update do |page|
          page.replace_html 'email_watchers', :partial => 'email_watchers/list', :locals => {:watched => @watched}
        end
      end
    end
  rescue ::ActionController::RedirectBackError
    render :text => 'Watcher added.', :layout => true
  end
  
  private
  
  def find_project
    klass = Object.const_get(params[:object_type].camelcase)
    return false unless klass.respond_to?('watched_by')
    @watched = klass.find(params[:object_id])
    @project = @watched.project
  rescue
    render_404
  end
end
