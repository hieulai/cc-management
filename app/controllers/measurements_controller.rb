class MeasurementsController < ApplicationController

  before_filter :confirm_logged_in
  
  def list
    @measurements = Measurement.all
  end
  
  def edit
    @measurement = Measurement.find(params[:id])
  end

  def update
    #Find object using form parameters
    @measurement = Measurement.find(params[:id])
    #Update subject
    if @measurement.update_attributes(params[:measurement])
      #if save succeeds, redirect to list action
      redirect_to(:action => 'list')
    else
      #if save fails, redisplay form to user can fix problems
      render('edit')
    end
  end
  
end
