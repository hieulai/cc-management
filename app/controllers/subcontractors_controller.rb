class SubcontractorsController < ApplicationController
  def list
    @subcontractors = Subcontractor.all
  end
  
  def show
    @subcontractor = Subcontractor.find(params[:id])
  end
  
  def new
    @subcontractor =  Subcontractor.new
  end
  
  def create
    #Instantiate a new object using form parameters
    @subcontractor = Subcontractor.new(params[:subcontractor])
    #save subject
    if @subcontractor.save
      #if save succeeds, redirect to list action
      redirect_to(:action => 'list')
    else
      #if save fails, redisplay form to user can fix problems
      render('new')
    end
  end
  
  def edit
    @subcontractor = Subcontractor.find(params[:id])
  end
  
  def update
    #Find object using form parameters
    @subcontractor = Subcontractor.find(params[:id])
    #Update subject
    if @subcontractor.update_attributes(params[:subcontractor])
      #if save succeeds, redirect to list action
      redirect_to(:action => 'list')
    else
      #if save fails, redisplay form to user can fix problems
      render('edit')
    end
  end
  
  def delete
    @subcontractor = Subcontractor.find(params[:id])
  end

  def destroy
    Subcontractor.find(params[:id]).destroy
    redirect_to(:action => 'list')
  end
end
