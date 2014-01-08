namespace :project do

  #Clone whole estimate
  #Estimate (kind = "Cost Plus Bid")
  #  | Template
  #     |Category Template
  #        | Category
  #          | Change Order Category
  #            | Change Order
  #              | Item (change_order)
  #          | Bid
  #            | Bids Item
  #              | Item
  #        | Item
  #        | Purchase Order
  #           | Bill
  #              | Payment Bill
  #                 | Payment
  #           | Purchase Orders Item
  #             | Item
  #           | Item (purchased)
  #        | Bill
  #            | Bills Item
  #              | Item
  #            | Payment Bill
  #               | Payment
  #            | Item (purchased)
  #        | Invoice
  #            | Invoice Item
  #            | Receipt Invoice
  #              | Receipt
  #              | Receipt Deposit
  #                 | Deposit
  desc "Clone project's estimate to cost plus bid one"
  task :clone_cost_plus_bid, [:id] => :environment do |t, args|
    puts "Project: Converting project Id: #{args[:id]} to cost plus bid one"
    if Project.exists?(args[:id])
      project = Project.find(args[:id])
      estimate = project.estimates.first
      if estimate
        cloned_payments = []
        cloned_receipts = []
        cloned_deposits = []
        cloned_items = []
        puts "  Estimate: Cloning estimate Id: #{estimate.id}"
        estimate_dup = estimate.dup
        estimate_dup.save
        estimate_dup.update_attribute(:kind, "Cost Plus Bid")
        estimate_dup.template = estimate.template.dup
        estimate_dup.template.save
        estimate.template.categories_templates.each do |ct|
          puts "    Cloning categories_template Id: #{ct.id}"
          ct_dup = ct.dup
          ct_dup.save
          estimate_dup.template.categories_templates << ct_dup

          puts "      Cloning category Id: #{ct.category.id}, category name #{ct.category.name}"
          category_dup = ct.category.dup
          category_dup.save
          ct_dup.update_attribute(:category_id, category_dup.id)

          ct.items.each do |i|
            puts "      Cloning item Id: #{i.id}, item name #{i.name}"
            i_dup = i.dup
            i_dup.save
            # Set duplicated item's description to item's id for reference
            i_dup.update_attribute(:description, i.id.to_s )
            ct_dup.items << i_dup
            cloned_items << i_dup
          end

          ct.category.bids.each do |b|
            puts "      Cloning bid Id: #{b.id}"
            b_dup = b.dup
            b_dup.save
            ct_dup.category.bids << b_dup
            b.bids_items.each do |bi|
              puts "        Cloning bids item Id: #{bi.id}"
              bi_dup = bi.dup
              bi_dup.save
              i_dup = cloned_items.select {|i| i.description == bi.item_id.to_s }.first
              bi_dup.update_attributes(:bid_id => b_dup.id, :item_id => i_dup.id)
            end
          end

          ct.category.change_orders_categories.each do |cc|
            puts "        Cloning change_orders_categories Id: #{cc.id}, change order Id: #{cc.change_order.id}, change order name #{cc.change_order.name}"
            cc_dup = cc.dup
            co_dup = cc.change_order.dup
            co_dup.save
            cc_dup.update_attributes(:category_id => category_dup.id, :change_order_id => co_dup.id)
            cc.items.each do |i|
              puts "          Cloning changed item Id: #{i.id}, item name #{i.name}"
              i_dup = i.dup
              i_dup.save
              cc_dup.items << i_dup
              cloned_items << i_dup
            end
          end

          ct.purchase_orders.each do |po|
            puts "      Cloning purchase order Id: #{po.id}"
            po_dup = po.dup
            ct_dup.purchase_orders << po_dup
            if po_dup.bill
              puts "        Cloned bill Id: #{po_dup.bill.id}"
              po.bill.payments_bills.each do |pb|
                puts "          Cloning payments bill Id: #{pb.id}"
                pb_dup = pb.dup
                pb_dup.save
                # Set duplicated payment's memo to payment's id for reference
                payment_dup = Payment.where(:memo => pb.payment.id).first
                unless payment_dup
                  puts "            Cloning payment Id: #{pb.payment.id}"
                  payment_dup = pb.payment.dup
                  payment_dup.update_attribute(:memo, pb.payment.id)
                  cloned_payments << payment_dup
                end
                pb_dup.update_attributes(:bill_id => po_dup.bill.id, :payment_id => payment_dup.id)
              end
            end

            po.purchase_orders_items.each do |poi|
              puts "          Cloning purchase orders item Id: #{poi.id}"
              poi_dup = poi.dup
              poi_dup.save
              i_dup = cloned_items.select {|i| i.description == poi.item_id.to_s }.first
              poi_dup.update_attributes(:purchase_order_id => po_dup.id, :item_id => i_dup.id)
            end

            po.items.each do |i|
              puts "        Cloning purchased item Id: #{i.id}"
              i_dup = i.dup
              i_dup.save
              i_dup.update_attribute(:description, i.id.to_s )
              po_dup.items << i_dup
              cloned_items << i_dup
            end
          end

          ct.bills.where(:purchase_order_id => nil).each do |b|
            puts "      Cloning bill Id: #{b.id}"
            b_dup = b.dup
            ct_dup.bills << b_dup
            b.bills_items.each do |bi|
              puts "        Cloning bills item Id: #{bi.id}"
              bi_dup = bi.dup
              bi_dup.save
              i_dup = cloned_items.select {|i| i.description == bi.item_id.to_s }.first
              bi_dup.update_attributes(:bill_id => b_dup.id, :item_id => i_dup.id)
            end

            b.payments_bills.each do |pb|
              puts "          Cloning payments bill Id: #{pb.id}"
              pb_dup = pb.dup
              pb_dup.save
              # Set duplicated payment's memo to payment's id for reference
              payment_dup = Payment.where(:memo => pb.payment.id.to_s).first
              unless payment_dup
                puts "            Cloning payment Id: #{pb.payment.id}"
                payment_dup = pb.payment.dup
                payment_dup.update_attribute(:memo, pb.payment.id)
                cloned_payments << payment_dup
              end
              pb_dup.update_attributes(:bill_id => b.id, :payment_id => payment_dup.id)
            end

            b.items.each do |i|
              puts "        Cloning purchased item Id: #{i.id}"
              i_dup = i.dup
              i_dup.save
              i_dup.update_attribute(:description, i.id.to_s )
              b_dup.items << i_dup
              cloned_items << i_dup
            end
          end
        end

        estimate.invoices.each do |invoice|
          puts "    Cloning invoice Id: #{invoice.id}"
          invoice_dup = invoice.dup
          invoice_dup.save
          estimate_dup.invoices << invoice_dup
          invoice.invoices_items.each do |ii|
            puts "    Cloning invoice item Id: #{ii.id}"
            ii_dup = ii.dup
            ii_dup.save
            i_dup = cloned_items.select {|i| i.description == ii.item_id.to_s }.first
            ii_dup.update_attributes(:invoice_id => invoice_dup.id, :item_id => i_dup.id )
          end

          invoice.receipts_invoices.each do |ri|
            ri_dup = ri.dup
            ri_dup.save
            receipt_dup = Receipt.where(:notes => ri.receipt.id.to_s).first
            unless receipt_dup
              puts "    Cloning receipt Id: #{ri.receipt.id}"
              receipt_dup = ri.receipt.dup
              receipt_dup.save
              receipt_dup.update_attribute(:notes, ri.receipt.id)
              cloned_receipts << receipt_dup

              ri.receipt.deposits_receipts.each do |dr|
                dr_dup = dr.dup
                dr_dup.save
                deposit_dup = Deposit.where(:notes => dr.deposit.id.to_s).first
                unless deposit_dup
                  puts "    Cloning deposit Id: #{dr.deposit.id}"
                  deposit_dup = dr.deposit.dup
                  deposit_dup.save
                  deposit_dup.update_attribute(:notes, dr.deposit.id)
                  cloned_deposits << deposit_dup
                end
                dr_dup.update_attributes(:receipt_id => receipt_dup.id, :deposit_id => deposit_dup.id )
              end
            end
            ri_dup.update_attributes(:invoice_id => invoice_dup.id, :receipt_id => receipt_dup.id )
          end
        end


        # Set back original values
        puts "Setting back items' description"
        cloned_items.each do |i|
          if Item.exists?(i.description)
            item = Item.find(i.description)
            i.update_attribute(:description, item.description)
          end
        end

        puts "Setting back payments' memo"
        cloned_payments.each do |p|
          payment = Payment.find(p.memo)
          p.update_attribute(:memo, payment.memo)
        end

        puts "Setting back receipts' notes"
        cloned_receipts.each do |r|
          receipt = Receipt.find(r.notes)
          r.update_attribute(:notes, receipt.notes)
        end

        puts "Setting back deposits' notes"
        cloned_deposits.each do |d|
          deposit = Deposit.find(d.notes)
          d.update_attribute(:notes, deposit.notes)
        end

        puts "Created new estimate #{estimate_dup.id} for project #{args[:id]}"
      end
    end
  end
end