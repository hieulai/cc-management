class UsersController < ApplicationController

  before_filter :authenticate_user!
  
  layout 'application'
  
  def list
    @user = @builder.users
  end
  
  def show
    @user = User.find(params[:id])
  end
  
  def new
    @user = User.new
  end
  
  def create
    #Instantiate a new object using form parameters
    @builder = Base::Builder.find(session[:builder_id])
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
  
end
