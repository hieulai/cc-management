module AccountingHelper
  def grouped_category_options(project)
    return [] unless project
    result = []
    original_categories = []
    if project.estimates.any?
      project.estimates.each do |e|
        original_categories+= e.template.categories_templates.sort_by { |c| c.category.name }.map { |c| c.category }
      end
    end
    raw_categories = Category.raw(session[:builder_id]).reject { |c| original_categories.map { |c| c[:name] }.include? c.name }
    result << ['From estimate', original_categories.map { |c| [c.name, c.id] }] if original_categories.any?
    result << ['New', raw_categories.map { |c| [c.name, c.id] }] if raw_categories.any?
    result
  end
end
