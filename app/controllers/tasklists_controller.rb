class TasklistsController < ApplicationController

  before_filter :authenticate_user!

  def list
    @tasklists = @builder.tasklists
  end
  
  def show
    @tasklist = @builder.tasklists.find(params[:id])
    respond_to do |format|
      format.html
      format.csv { send_data @tasklist.to_csv, filename: "Tasklist-#{@tasklist.name}.csv"  }
      format.xls { send_data @tasklist.tasks.to_xls(:headers => Task::HEADERS, :columns => [:name, :completed, :time_to_complete, :department]), content_type: 'application/vnd.ms-excel', filename: "Tasklist-#{@tasklist.name}.xls" }
    end
  end
  
  def new
    @tasklist = @builder.tasklists.new
    @tasklist.tasks.build
  end

  def create
    @tasklist = @builder.tasklists.new(params[:tasklist])
    if @tasklist.save
      redirect_to(:action => 'list')
    else
      render('new')
    end
  end
  
  def edit
    @tasklist = @builder.tasklists.find(params[:id])
  end
  
  def update
    @tasklist = @builder.tasklists.find(params[:id])
    if @tasklist.update_attributes(params[:tasklist])
      redirect_to(:action => 'list')
    else
      render('edit')
    end
  end

  def show_import
    @tasklist = @builder.tasklists.new
  end

  def import
    if params[:tasklist].nil? || params[:tasklist][:data].nil?
      redirect_to action: 'show_import', notice: "No file to import."
    else
      begin
        tasklist = @builder.tasklists.create(name: params[:tasklist][:name])
        result = Task.import(params[:tasklist][:data])
        tasklist.tasks << result[:objects]
        msg = "Tasklist imported."
        unless result[:errors].empty?
          msg = result[:errors].join(",")
        end
        redirect_to action: 'list', notice: msg
      rescue StandardError => e
        redirect_to action: 'show_import', notice: e
      end
    end
  end

  def delete
    @tasklist = @builder.tasklists.find(params[:id])
  end

  def destroy
    @tasklist = @builder.tasklists.find(params[:id]).destroy
    redirect_to(:action => 'list')
  end
end
