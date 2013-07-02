class ArchitectsController < ApplicationController
  
  before_filter :confirm_logged_in
  
  def list
    @architects = Architect.where("builder_id = ?", session[:builder_id])
  end
  
  def show
    @architect = Architect.find(params[:id])
  end
  
  def new
    @architect =  Architect.new
  end
  
  def create
    #Instantiate a new object using form parameters
    @builder = Builder.find(session[:builder_id])
    @architect = Architect.new(params[:architect])
    #save subject
    if @architect.save
      @builder.architects << @architect
      #if save succeeds, redirect to list action
      redirect_to(:action => 'list')
    else
      #if save fails, redisplay form to user can fix problems
      render('new')
    end
  end
  
  def edit
    @architect = Architect.find(params[:id])
  end
  
  def update
    #Find object using form parameters
    @architect = Architect.find(params[:id])
    #Update subject
    if @architect.update_attributes(params[:architect])
      #if save succeeds, redirect to list action
      redirect_to(:action => 'list')
    else
      #if save fails, redisplay form to user can fix problems
      render('edit')
    end
  end
  
  def delete
    @architect= Architect.find(params[:id])
  end

  def destroy
    Architect.find(params[:id]).destroy
    redirect_to(:action => 'list')
  end
end
