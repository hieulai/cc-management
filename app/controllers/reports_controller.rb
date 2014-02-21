class ReportsController < ApplicationController
  before_filter :authenticate_user!

  def pl_report
    @project_id = params[:project_id]
    @from_date = Date.parse(params[:from_date])
    @to_date = Date.parse(params[:to_date])
    name = "Profit-Loss-Report-#{@from_date}-#{@to_date}"
    if @project_id.present?
      project = @builder.projects.find(@project_id)
      name = "Profit-Loss-Report-#{project.name}-#{@from_date}-#{@to_date}"
    end
    respond_to do |format|
      format.pdf do
        render :pdf => name,
               :layout => 'pdf.html',
               #:show_as_html => true,
               :footer => {:center => 'Page [page]'}
      end
    end
  end
end
