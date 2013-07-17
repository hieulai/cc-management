class UsersController < ApplicationController
  
  before_filter :confirm_logged_in, :except => [:login, :process_login, :logout, :register, :process_registration]
  
  layout 'application', except: [:login, :register]
  
  def list
    @user = User.where("builder_id = ?", session[:builder_id])
  end
  
  def show
    @user = User.find(params[:id])
  end
  
  def new
    @user = User.new
  end
  
  def create
    #Instantiate a new object using form parameters
    @builder = Builder.find(session[:builder_id])
    @user = @builder.users.new(params[:user])
    #save subject
    if @user.save
      #if save succeeds, redirect to list action
      redirect_to :controller => 'users', :action => 'list'
    else
      #if save fails, redisplay form to user can fix problems
      render('new')
    end
  end
  
  def edit
    @user = User.find(params[:id])
  end
  
  def update
    #Find object using form parameters
    @user = User.find(params[:id])
    #Update subject
    if @user.update_attributes(params[:user])
      #if save succeeds, redirect to list action
      redirect_to(:action => 'list')
    else
      #if save fails, redisplay form to user can fix problems
      render('edit')
    end
  end
  
  def delete
    @user = User.find(params[:id])
  end

  def destroy
    User.find(params[:id]).destroy
    redirect_to(:action => 'list')
  end
    
    
  def register
    layout 'public'
    @builder = Builder.new
    @user =  User.new
  end
  
  def process_registration
    #Instantiate a new object using form parameters
    @builder = Builder.new(params[:builder])
    @user = User.new(params[:user])
    @builder.save
    @user.authority = "Owner"
    @user.save
    
    #save subject
    if @builder.users << @user
      #if save succeeds, redirect to list action
      redirect_to :action => 'process_login'
    else
      #if save fails, redisplay form to user can fix problems
      render('register')
    end
  end
  
  
  def login
    render layout: 'public'
  end
  
  def process_login
    authorized_user = User.authenticate(params[:email],params[:password])
    if authorized_user
      session[:user_id] = authorized_user.id
      session[:username] = authorized_user.full_name
      session[:builder_id] = authorized_user.builder_id
      @builder = Builder.find(authorized_user.builder_id)
      session[:builder_name] = @builder.company_name
      redirect_to(:controller => 'leads', :action => 'list_current_leads')
    else
      flash[:notice] = "Invalid email/password combination."
      redirect_to(:action => 'login')
    end
  end
  
  def logout
    session[:user_id] = nil
    session[:builder_id] = nil
    redirect_to(:controller => 'site', :action => 'index')
  end
  
end
