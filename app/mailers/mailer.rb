class Mailer < ActionMailer::Base
  default from: "noreply@constructioncentral.com"

  def send_estimate(to, subject, body, estimate = nil)
    @body = body
    # create an instance of ActionView, so we can use the render method outside of a controller
    av = ActionView::Base.new()
    av.view_paths = ActionController::Base.view_paths
    pdf_html = av.render :template => 'estimates/show.pdf.erb', :layout => 'layouts/pdf.html.erb', :locals => {:estimate => estimate}, :footer => {:center => 'Page [page]'}

    # use wicked_pdf gem to create PDF from the doc HTML
    doc_pdf = WickedPdf.new.pdf_from_string(pdf_html, :page_size => 'Letter')

    attachments["Estimate-#{estimate.project.name}.pdf"] = doc_pdf
    mail :to => to, :subject => subject
  end
end
