class HolidaysController < ApplicationController
  unloadable
  
  before_action(:check_plugin_right)
  
  def check_plugin_right
    right = (!Setting.plugin_mega_calendar['allowed_users'].blank? && Setting.plugin_mega_calendar['allowed_users'].include?(User.current.id.to_s) ? true : false)
    if !right
      flash[:error] = translate 'no_right'
      redirect_to({:controller => :welcome})
    end
  end

  def index
    @toolbar_params = params.permit(:my, :grouped).select {|_, v| v.present? }

    scope = Holiday.includes(:user).order(start: :desc)
    scope = scope.where(user: User.current) if params[:my]

    if params[:grouped]
      @holidays = Holiday.grouped_holidays_by_user(scope)
                         .transform_values do |holidays|

        Holiday.grouped_holidays_by_year(holidays)
               .transform_keys(&:to_i)
               .transform_values(&:size)
      end

      @users = @holidays.keys.sort_by(&:login)
      @years = @holidays.values.map(&:keys).flatten.sort.uniq
    else

      @holidays_pages = Paginator.new(scope.count, per_page_option, params['page'])
      @holidays = scope.limit(@holidays_pages.per_page)
                       .offset(@holidays_pages.offset)
    end
  end

  def new
    #DO NOTHING
  end

  def create
    @holiday = Holiday.new(holiday_params)
    if @holiday.save
      redirect_to(:controller => 'holidays', :action => 'index')
    else
      respond_to do |format|
        format.html { render :action => 'new' }
        format.api  { render_validation_errors(@holiday) }
      end
    end
  end

  def edit
    @holiday = Holiday.find(params[:id]) rescue nil
    if @holiday.blank?
      redirect_to(:controller => 'holidays', :action => 'index')
    end
  end

  def update
    @holiday = Holiday.find(params[:holiday][:id]) rescue nil
    @holiday.assign_attributes(holiday_params)
    if @holiday.save
      redirect_to(:controller => 'holidays', :action => 'index')
    else
      respond_to do |format|
        format.html { render :action => 'new' }
        format.api  { render_validation_errors(@holiday) }
      end
    end
  end

  def destroy
    holiday = Holiday.where(:id => params[:id]).first rescue nil
    holiday.destroy()
    redirect_to(:controller => 'holidays', :action => 'index')
  end

  private

  def holiday_params
    params.require(:holiday).permit(:start, :end, :user_id)
  end
end
