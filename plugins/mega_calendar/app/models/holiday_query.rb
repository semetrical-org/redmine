# frozen_string_literal: true

class HolidayQuery < Query
  unloadable

  self.queried_class = Holiday
  # self.view_permission = :search_project

  def initialize(attributes=nil, *args)
    super(attributes)
    self.filters ||= {}
  end

  def initialize_available_filters
    add_available_filter(
      "user_id",
      :type => :list, :values => lambda { User.where(type: 'User').order(:login).map { |user| [user.login, user.id.to_s] } }
    )
    add_available_filter "start", :type => :date_past
    add_available_filter "end", :type => :date_past
  end

  def default_sort_criteria
    [[]]
  end

  def base_scope
    Holiday.includes(:user).where(statement)
  end

  def results_scope(options={})
    order_option = [group_by_sort_order, (options[:order] || sort_clause)].flatten.reject(&:blank?)

    order_option << "#{Holiday.table_name}.start ASC"
    scope = base_scope.
      order(order_option).
      joins(joins_for_order_statement(order_option.join(',')))

    scope
  end
end
