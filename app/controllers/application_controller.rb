class ApplicationController < ActionController::Base

  before_filter :find_builder
  after_filter :put_params

  protect_from_forgery

  def after_sign_in_path_for(resource)
    session[:user_id] = current_user.id
    session[:username] = current_user.full_name
    session[:builder_id] = current_user.builder_id
    @builder = Base::Builder.find(current_user.builder_id)
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
    @builder = Base::Builder.find(session[:builder_id]) if session[:builder_id]
  end

  def put_params
    @original_url = params[:original_url]
  end

  private
  def assign_company(person)
    result = true
    person.company = "#{person.class.name}Company".constantize.lookup(params["#{person.class.name.underscore}_company".to_sym])
    if person.company && !person.company.valid?
      result = false
      person.company.attributes = params["#{person.class.name.underscore}_company".to_sym]
      person.company.errors.full_messages.each do |msg|
        person.errors[:base] << msg
      end
    end
    result
  end
end