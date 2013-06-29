class EstimatesController < ApplicationController

    before_filter :confirm_logged_in
    
    def list_current
      #add condition to filter leads by lead_status
      @estimates = Estimate.where(:status => "Current Estimate")
    end

    def list_past
      #add condition to filter leads by lead_status
      @estimates = Estimate.where(:status => "Past Estimate")
    end

    def list_templates
      @templates = Template.all
    end

    def list_itesm
      @items = Item.all
    end

    def show
      @estimate = Estimate.find(params[:id])
    end

    def new
      @estimate = Estimate.new
    end

    def create
      #Reads in the project ID selected by the User
      @project = Project.find(params[:project][:id])
      #Assigns the estimate to the correct Project
      @estimate = @project.estimates.new(params[:estimate])
      #saves creation of Estimate
      if @estimate.save
        #Assigns all appropriate measurements to the Estimate
        @measurements = Measurement.all
        @measurements.each do |m|
          @estimate.measurements << m
        end
        #if save succeeds, redirect to list action
        redirect_to(:action => 'list_current')
      else
        #if save fails, redisplay form to user can fix problems
        render('new')
      end
    end

    def edit
      @estimate = Estimate.find(params[:id])
    end

    def update
      #Find object using form parameters
      @estimate = Estimate.find(params[:id])
      #Update subject
      if @estimate.update_attributes(params[:estimate])
        #if save succeeds, redirect to list action
        redirect_to(:action => 'list_current')
      else
        #if save fails, redisplay form to user can fix problems
        render('edit')
      end
    end

    def edit_measurements
      @estimate = Estimate.find(params[:id])
      @measurements = @estimate.measurements
    end

    def update_measurements
      #Find object using form parameters
      @estimate = Estimate.find(params[:id])
      #Update subject
      if @estimate.update_attributes(params[:estimate])
        #if save succeeds, redirect to list action
        redirect_to(:action => 'list_current')
      else
        #if save fails, redisplay form to user can fix problems
        render('edit')
      end
    end

    def edit_templates
      @estimate = Estimate.find(params[:id])
      @measurements = @estimate.measurements
    end

    def update_templates
      #Find object using form parameters
      @estimate = Estimate.find(params[:id])
      #Update subject
      if @estimate.update_attributes(params[:estimate])
        #if save succeeds, redirect to list action
        redirect_to(:action => 'list_current')
      else
        #if save fails, redisplay form to user can fix problems
        render('edit')
      end
    end

    def convert
      @estimate = Estimate.find(params[:id])
    end

    def conversion
      #Find object using form parameters
      @estimate = Estimate.find(params[:id])
      #Update subject
      if @estimate.update_attributes(params[:estimate])
        #if save succeeds, redirect to list action
        redirect_to(:action => 'list_current')
      else
        #if save fails, redisplay form to user can fix problems
        render('convert')
      end
    end

    def delete
      @estimate = Estimate.find(params[:id])
    end

    def destroy
      Estimate.find(params[:id]).destroy
      redirect_to(:action => 'list_current')
    end

end
