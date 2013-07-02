class TasklistsController < ApplicationController

  def list
    @tasklists = Tasklist.all
  end
  
  def show
    @tasklist = Tasklist.find(params[:id])
  end
  
  def new
    @tasklist = Tasklist.new
  end
  
  def create
    @tasklist = Tasklist.new(params[:tasklist])
    #saves creation of Estimate
    if @tasklist.save
      #if save succeeds, redirect to list action
      redirect_to(:action => 'list')
    else
      #if save fails, redisplay form to user can fix problems
      render('new')
    end
  end
  
  def edit
    @tasklist = Tasklist.find(params[:id])
  end
  
  def update
    #Find object using form parameters
    @tasklist = Tasklist.find(params[:id])
    #Update subject
    if @tasklist.update_attributes(params[:tasklist])
      #if save succeeds, redirect to list action
      redirect_to(:action => 'list')
    else
      #if save fails, redisplay form to user can fix problems
      render('edit')
    end
  end

  def delete
    @tasklist = Tasklist.find(params[:id])
  end

  def destroy
    Tasklist.find(params[:id]).destroy
    redirect_to(:action => 'list')
  end
end
