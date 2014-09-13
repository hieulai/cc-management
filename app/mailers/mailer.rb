class Mailer < ActionMailer::Base
  default from: "noreply@constructioncentral.com"

  def send_estimate(to, subject, body, estimate = nil)
    @body = body
    # create an instance of ActionView, so we can use the render method outside of a controller
    av = PDFRender.new
    av.view_paths = ActionController::Base.view_paths
    pdf_html = av.render :template => 'estimates/show.pdf.erb',
                         :layout => 'layouts/pdf.html.erb',
                         :locals => {:estimate => estimate}

    # use wicked_pdf gem to create PDF from the doc HTML
    doc_pdf = WickedPdf.new.pdf_from_string(pdf_html, :page_size => 'A4', :footer => {:center => 'Page [page]'})

    attachments["Estimate-#{estimate.project.name}.pdf"] = doc_pdf
    mail :to => to, :subject => subject
  end

  def send_invoice(to, subject, body, invoice = nil)
    @body = body
    # create an instance of ActionView, so we can use the render method outside of a controller
    av = PDFRender.new
    av.view_paths = ActionController::Base.view_paths
    pdf_html = av.render :template => 'accounting/invoice.pdf.erb',
                         :layout => 'layouts/pdf.html.erb',
                         :locals => {:invoice => invoice}

    # use wicked_pdf gem to create PDF from the doc HTML
    doc_pdf = WickedPdf.new.pdf_from_string(pdf_html, :page_size => 'A4', :footer => {:center => 'Page [page]'})

    attachments["Invoice-#{invoice.id}.pdf"] = doc_pdf
    mail :to => to, :subject => subject
  end

  def send_co(to, subject, body, change_order = nil)
    @body = body
    # create an instance of ActionView, so we can use the render method outside of a controller
    av = PDFRender.new
    av.view_paths = ActionController::Base.view_paths
    pdf_html = av.render :template => 'projects/show_change_order.pdf.erb',
                         :layout => 'layouts/pdf.html.erb',
                         :locals => {:change_order => change_order}

    # use wicked_pdf gem to create PDF from the doc HTML
    doc_pdf = WickedPdf.new.pdf_from_string(pdf_html, :page_size => 'A4', :footer => {:center => 'Page [page]'})

    attachments["ChangeOrder-#{change_order.name}.pdf"] = doc_pdf
    mail :to => to, :subject => subject
  end

  def send_account(to, subject, body, object = nil, project = nil)
    @body = body
    type = object.class.name
    balance = object.balance({project_id: project.try(:id)}).to_f
    transactions = object.transactions({project_id: project.try(:id)})
    # create an instance of ActionView, so we can use the render method outside of a controller
    av = PDFRender.new
    av.view_paths = ActionController::Base.view_paths
    pdf_html = av.render :template => 'accounting/accounts/pdf/show_account.pdf.erb',
                         :layout => 'layouts/pdf.html.erb',
                         :locals => {:object => object, :type => type, :project => project, :transactions => transactions, :balance => balance}

    # use wicked_pdf gem to create PDF from the doc HTML
    doc_pdf = WickedPdf.new.pdf_from_string(pdf_html, :page_size => 'A4', :footer => {:center => 'Page [page]'})

    attachments["#{type}-#{object.id}-Ledgers.pdf"] = doc_pdf
    mail :to => to, :subject => subject
  end
end
