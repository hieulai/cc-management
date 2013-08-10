class ApplicationController < ActionController::Base
  before_filter :find_builder

  protect_from_forgery

  def after_sign_in_path_for(resource)
    session[:user_id] = current_user.id
    session[:username] = current_user.full_name
    session[:builder_id] = current_user.builder_id
    @builder = Builder.find(current_user.builder_id)
    session[:builder_name] = @builder.company_name
    url_for(:controller => 'leads', :action => 'list_current_leads')
  end

  def after_sign_out_path_for(resource)
    session[:user_id] = nil
    session[:builder_id] = nil
    root_url
  end

  protected

  def find_builder
    @builder = Builder.find(session[:builder_id]) if session[:builder_id]
  end

end