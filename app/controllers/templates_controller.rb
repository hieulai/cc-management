class TemplatesController < ApplicationController
      def list
        @templates = Template.all
      end
  
      def new
        @template = Template.new
        @categories = Category.all
        @items = Item.all
      end
  
      def create
        @category = Category.find(params[:category][:id])
        @item = Item.find(params[:item][:id])
        @template = Template.new(params[:template])
        
        if @template.save
            @template.categories << @category
            @template.items << @item
          redirect_to(:action => 'list')
        else
          #if save fails, redisplay form to user can fix problems
          render('new')
        end
      end
  
      def edit
        @categories = Category.all
        @items = Item.all
        @template = Template.find(params[:id])
      end
  
      def update
        @template = Template.find(params[:id])
        @category = Category.find(params[:category][:id])
        @item = Item.find(params[:item][:id])
        #Find object using form parameters
        
        #Update subject
        if @template.update_attributes(params[:template])
            @category.items << @item
            @template.categories << @category
          #if save succeeds, redirect to list action
          redirect_to(:action => 'list')
        else
          #if save fails, redisplay form to user can fix problems
          render('edit')
        end
      end
  
      def delete
        @template= Template.find(params[:id])
      end
  
      def destroy
        Template.find(params[:id]).destroy
        redirect_to(:action => 'list')
      end

end
